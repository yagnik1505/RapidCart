# Firebase Database Structure for RapidCart

This document outlines the Firebase Firestore database structure for the RapidCart application, similar to Blinkit's architecture.

## Database Collections

### 1. Users Collection (`users`)

Each user document contains user profile information and subcollections.

```
users/{userId}
├── email: string
├── name: string
├── phone: string
├── createdAt: timestamp
├── lastLoginAt: timestamp
└── orders/ (subcollection)
    └── {orderId}
        ├── id: string
        ├── userId: string
        ├── total: number
        ├── createdAt: string (ISO 8601)
        ├── status: string (pending, confirmed, preparing, outForDelivery, delivered, cancelled)
        ├── deliveryAddress: object
        │   ├── name: string
        │   ├── phone: string
        │   ├── address: string
        │   ├── city: string
        │   ├── state: string
        │   ├── pincode: string
        │   └── landmark: string (optional)
        ├── paymentMethod: object
        │   ├── type: string (cashOnDelivery, onlinePayment, wallet)
        │   ├── transactionId: string (optional)
        │   └── paymentStatus: string
        ├── notes: string (optional)
        └── items: array
            └── [0]
                ├── productId: string
                ├── name: string
                ├── price: number
                ├── quantity: number
                └── subtotal: number
```

### 2. Orders Collection (`orders`)

Global orders collection for admin management and analytics.

```
orders/{orderId}
├── id: string
├── userId: string
├── total: number
├── createdAt: string (ISO 8601)
├── status: string (pending, confirmed, preparing, outForDelivery, delivered, cancelled)
├── deliveryAddress: object
│   ├── name: string
│   ├── phone: string
│   ├── address: string
│   ├── city: string
│   ├── state: string
│   ├── pincode: string
│   └── landmark: string (optional)
├── paymentMethod: object
│   ├── type: string (cashOnDelivery, onlinePayment, wallet)
│   ├── transactionId: string (optional)
│   └── paymentStatus: string
├── notes: string (optional)
├── items: array
│   └── [0]
│       ├── productId: string
│       ├── name: string
│       ├── price: number
│       ├── quantity: number
│       └── subtotal: number
├── assignedDeliveryPerson: string (optional)
├── estimatedDeliveryTime: timestamp (optional)
└── actualDeliveryTime: timestamp (optional)
```

### 3. Products Collection (`products`)

Product catalog with categories and inventory management.

```
products/{productId}
├── id: string
├── name: string
├── description: string
├── imageUrl: string
├── price: number
├── unit: string (pcs, kg, liter, etc.)
├── category: string
├── subcategory: string (optional)
├── brand: string (optional)
├── weight: number (optional)
├── dimensions: object (optional)
│   ├── length: number
│   ├── width: number
│   └── height: number
├── inventory: object
│   ├── available: number
│   ├── reserved: number
│   └── threshold: number
├── isActive: boolean
├── createdAt: timestamp
├── updatedAt: timestamp
├── tags: array (optional)
└── ratings: object (optional)
    ├── average: number
    ├── count: number
    └── reviews: array
```

### 4. Categories Collection (`categories`)

Product categories and subcategories.

```
categories/{categoryId}
├── id: string
├── name: string
├── description: string
├── imageUrl: string
├── parentCategoryId: string (optional)
├── isActive: boolean
├── sortOrder: number
├── createdAt: timestamp
└── updatedAt: timestamp
```

### 5. Delivery Persons Collection (`deliveryPersons`)

Delivery personnel management.

```
deliveryPersons/{deliveryPersonId}
├── id: string
├── name: string
├── phone: string
├── email: string
├── vehicleType: string (bike, car, etc.)
├── vehicleNumber: string
├── licenseNumber: string
├── isActive: boolean
├── currentLocation: object
│   ├── latitude: number
│   └── longitude: number
├── assignedOrders: array
├── completedOrders: number
├── rating: number
├── joinedAt: timestamp
└── lastActiveAt: timestamp
```

### 6. Store Locations Collection (`storeLocations`)

Physical store/warehouse locations.

```
storeLocations/{locationId}
├── id: string
├── name: string
├── address: string
├── city: string
├── state: string
├── pincode: string
├── coordinates: object
│   ├── latitude: number
│   └── longitude: number
├── isActive: boolean
├── operatingHours: object
│   ├── openTime: string
│   └── closeTime: string
├── deliveryRadius: number (in km)
└── createdAt: timestamp
```

## Database Rules (Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can read/write their own orders
      match /orders/{orderId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Orders collection - users can read their own orders, admins can read all
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Products are readable by all authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Categories are readable by all authenticated users
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Delivery persons - admin only
    match /deliveryPersons/{deliveryPersonId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Store locations - admin only
    match /storeLocations/{locationId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Indexes Required

### Composite Indexes for Orders Collection

1. **Orders by User and Status**
   - Collection: `orders`
   - Fields: `userId` (Ascending), `status` (Ascending), `createdAt` (Descending)

2. **Orders by Status and Created Date**
   - Collection: `orders`
   - Fields: `status` (Ascending), `createdAt` (Descending)

3. **Orders by Delivery Address City**
   - Collection: `orders`
   - Fields: `deliveryAddress.city` (Ascending), `createdAt` (Descending)

### Composite Indexes for Products Collection

1. **Products by Category and Active Status**
   - Collection: `products`
   - Fields: `category` (Ascending), `isActive` (Ascending), `name` (Ascending)

2. **Products by Price Range**
   - Collection: `products`
   - Fields: `price` (Ascending), `isActive` (Ascending)

## Sample Data Structure Examples

### Sample Order Document

```json
{
  "id": "order_123456789",
  "userId": "user_abc123",
  "total": 450.50,
  "createdAt": "2024-01-15T10:30:00Z",
  "status": "pending",
  "deliveryAddress": {
    "name": "John Doe",
    "phone": "+919876543210",
    "address": "123 Main Street, Apartment 4B",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001",
    "landmark": "Near Central Mall"
  },
  "paymentMethod": {
    "type": "cashOnDelivery",
    "paymentStatus": "pending"
  },
  "notes": "Please deliver after 6 PM",
  "items": [
    {
      "productId": "prod_001",
      "name": "Fresh Apples",
      "price": 120.00,
      "quantity": 2,
      "subtotal": 240.00
    },
    {
      "productId": "prod_002",
      "name": "Milk 1L",
      "price": 70.25,
      "quantity": 3,
      "subtotal": 210.75
    }
  ]
}
```

### Sample Product Document

```json
{
  "id": "prod_001",
  "name": "Fresh Apples",
  "description": "Premium quality red apples",
  "imageUrl": "https://example.com/apples.jpg",
  "price": 120.00,
  "unit": "kg",
  "category": "fruits",
  "subcategory": "fresh_fruits",
  "brand": "Farm Fresh",
  "inventory": {
    "available": 50,
    "reserved": 5,
    "threshold": 10
  },
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:30:00Z",
  "tags": ["organic", "fresh", "healthy"],
  "ratings": {
    "average": 4.5,
    "count": 128
  }
}
```

## Implementation Notes

1. **Order Status Flow**: Orders progress through statuses: pending → confirmed → preparing → outForDelivery → delivered
2. **Inventory Management**: Products have available, reserved, and threshold quantities
3. **Delivery Tracking**: Orders can be assigned to delivery persons with location tracking
4. **Payment Integration**: Supports multiple payment methods with transaction tracking
5. **Real-time Updates**: Use Firestore listeners for real-time order status updates
6. **Offline Support**: Firestore provides offline persistence for better user experience

This structure provides a scalable foundation for a rapid delivery app similar to Blinkit, with proper separation of concerns and efficient querying capabilities.
