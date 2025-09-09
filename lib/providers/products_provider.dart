import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  final List<Product> _catalog = [
    const Product(
      id: 'p1',
      name: 'Banana',
      description: 'Fresh bananas',
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=640',
      price: 10,
      unit: '1 pc',
    ),
    const Product(
      id: 'p2',
      name: 'Milk',
      description: '1L toned milk',
      imageUrl: 'https://kj1bcdn.b-cdn.net/media/85648/organic-milk.jpeg',
      price: 35,
      unit: '1 L',
    ),
    const Product(
      id: 'p3',
      name: 'Bread',
      description: 'Whole wheat bread',
      imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=640',
      price: 80,
      unit: '400 g',
    ),
    const Product(
      id: 'p4',
      name: 'Eggs',
      description: 'Farm fresh eggs',
      imageUrl: 'https://www.allrecipes.com/thmb/T1WRI2Jv6Fv5Zri8CSF2yVOnoIA=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/dozen-eggs-in-carton-e0ef92dabf374e5ea9aea7fba2219902.png',
      price: 120,
      unit: '12 pcs',
    ),
  ];

  List<Product> get products => List.unmodifiable(_catalog);

  Product? byId(String id) => _catalog.firstWhere((p) => p.id == id, orElse: () => _catalog.first);
}

