import 'package:cloud_firestore/cloud_firestore.dart';

/// DEV-ONLY utility to populate Firestore's `properties` collection with
/// sample data so the app has something real to query while the actual
/// property-creation flow (item 32, owner side) isn't built yet.
///
/// Run this ONCE (see the debug button wired into the Profile tab, only
/// visible in debug builds) then delete/ignore this file once owners
/// are creating real listings.
Future<void> seedSampleProperties() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final col = db.collection('properties');

  for (final p in _sampleProperties) {
    final doc = col.doc(p['id'] as String);
    batch.set(doc, {...p}..remove('id'));
  }

  await batch.commit();
}

final List<Map<String, dynamic>> _sampleProperties = [
  {
    'id': 'p1',
    'name': "Maria's Boarding House",
    'imageUrl': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    'gallery': [
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
    ],
    'pricePerMonth': 2500,
    'distanceMeters': 650,
    'rating': 4.8,
    'isVerified': true,
    'availableRooms': 3,
    'ownerName': 'Maria Santos',
    'reviewCount': 42,
    'description':
        'A cozy, well-kept boarding house just a short walk from campus. Rooms come furnished with a bed, study desk, and closet. Shared kitchen and common area, with a curfew of 10PM on weekdays for a quiet study environment.',
    'amenities': ['Wi-Fi', 'Study desk', 'Shared kitchen', 'CR per room', 'Laundry area', 'Security guard'],
  },
  {
    'id': 'p2',
    'name': 'Casa Verde Residences',
    'imageUrl': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
    'pricePerMonth': 2200,
    'distanceMeters': 900,
    'rating': 4.5,
    'isVerified': true,
    'availableRooms': 1,
    'ownerName': 'Roberto Cruz',
    'reviewCount': 28,
    'description': 'Modern residence with a homey feel, popular among nursing and engineering students. Backup generator during brownouts.',
    'amenities': ['Wi-Fi', 'Backup power', 'Kitchen', 'Water refill station'],
  },
  {
    'id': 'p3',
    'name': 'Sunrise Student Lodge',
    'imageUrl': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
    'pricePerMonth': 1800,
    'distanceMeters': 1400,
    'rating': 4.3,
    'isVerified': false,
    'availableRooms': 5,
    'ownerName': 'Elena Reyes',
    'reviewCount': 15,
    'description': "Budget-friendly lodge with basic shared amenities — a solid pick if you're prioritizing savings over distance.",
    'amenities': ['Shared CR', 'Kitchen access', 'Study area'],
  },
  {
    'id': 'p4',
    'name': 'The Study Nook',
    'imageUrl': 'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=800',
    'gallery': ['https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800'],
    'pricePerMonth': 2900,
    'distanceMeters': 500,
    'rating': 4.9,
    'isVerified': true,
    'availableRooms': 2,
    'ownerName': 'Grace Villamor',
    'reviewCount': 61,
    'description':
        'The closest premium option to campus. Air-conditioned rooms, quiet hours strictly enforced, and a dedicated study lounge on the ground floor.',
    'amenities': ['Air-conditioning', 'Wi-Fi', 'Study lounge', 'CCTV', 'Laundry service', '24/7 security'],
  },
  {
    'id': 'p5',
    'name': 'Palm View Homestay',
    'imageUrl': 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800',
    'pricePerMonth': 1600,
    'distanceMeters': 1900,
    'rating': 4.1,
    'isVerified': false,
    'availableRooms': 4,
    'ownerName': 'Fernando Diaz',
    'reviewCount': 9,
    'description': 'A family-run homestay with a relaxed, homey atmosphere. Meals available on request for an extra fee.',
    'amenities': ['Home-cooked meals (optional)', 'Garden area', 'Shared CR'],
  },
  {
    'id': 'p6',
    'name': 'Camino Student Suites',
    'imageUrl': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
    'pricePerMonth': 3200,
    'distanceMeters': 750,
    'rating': 4.7,
    'isVerified': true,
    'availableRooms': 1,
    'ownerName': 'Camino Property Group',
    'reviewCount': 33,
    'description':
        'The most premium listing on StayEase near BISU Candijay — private rooms with attached CR, high-speed Wi-Fi, and a rooftop common area.',
    'amenities': ['Attached CR', 'High-speed Wi-Fi', 'Rooftop lounge', 'Air-conditioning', 'CCTV'],
  },
  {
    'id': 'p7',
    'name': "Nena's Place",
    'imageUrl': 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
    'pricePerMonth': 2000,
    'distanceMeters': 1100,
    'rating': 4.4,
    'isVerified': true,
    'availableRooms': 3,
    'ownerName': 'Nena Aquino',
    'reviewCount': 22,
    'description': 'Well-loved by returning tenants for its friendly landlady and strict but fair house rules.',
    'amenities': ['Wi-Fi', 'Kitchen', 'Curfew: 10PM', 'Visitor logbook'],
  },
  {
    'id': 'p8',
    'name': 'Northgate Residences',
    'imageUrl': 'https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800',
    'pricePerMonth': 2650,
    'distanceMeters': 2100,
    'rating': 4.2,
    'isVerified': false,
    'availableRooms': 6,
    'ownerName': 'Northgate Realty',
    'reviewCount': 18,
    'description':
        "Farther from campus but larger rooms and lower density per floor — good for tenants who prefer more personal space and don't mind a short commute.",
    'amenities': ['Parking area', 'Wi-Fi', 'Shared kitchen', 'Common lounge'],
  },
];
