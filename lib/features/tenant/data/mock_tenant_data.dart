import '../models/tenant_models.dart';

/// TEMPORARY mock data source for tenant dashboard/explore UI development.
///
/// This class is the ONLY place mock data lives. When Firestore is wired
/// up (StayEase progress item 27), replace this with a
/// `TenantDashboardRepository` that reads from `properties/` and
/// `reservations/` collections — the UI layer already consumes plain
/// domain models (see tenant_models.dart) and does not know this data
/// is fake.
class MockTenantData {
  MockTenantData._();

  static const tenantFirstName = 'John';

  // Demo location only: the UI treats this as a generic selected location.
  // Replace this value with the user's chosen/current location when location
  // search is wired to Firestore/Mapbox. BISU Candijay is only the current
  // demo selection; schools are just one type of searchable location.
  static const selectedLocationLabel = 'BISU Candijay';

  static final List<Property> nearbyProperties = [
    const Property(
      id: 'p1',
      name: "Maria's Boarding House",
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      gallery: [
        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      ],
      pricePerMonth: 2500,
      distanceMeters: 650,
      rating: 4.8,
      isVerified: true,
      availableRooms: 3,
      ownerName: 'Maria Santos',
      reviewCount: 42,
      description: 'A cozy, well-kept place to stay in a convenient area. '
          'Rooms come furnished with a bed, desk, and closet. Shared kitchen and '
          'common area, with a quiet-hours policy on weekdays.',
      amenities: ['Wi-Fi', 'Study desk', 'Shared kitchen', 'CR per room', 'Laundry area', 'Security guard'],
    ),
    const Property(
      id: 'p2',
      name: 'Casa Verde Residences',
      imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      pricePerMonth: 2200,
      distanceMeters: 900,
      rating: 4.5,
      isVerified: true,
      availableRooms: 1,
      ownerName: 'Roberto Cruz',
      reviewCount: 28,
      description: 'Modern residence with a homey feel and reliable shared facilities. '
          'Backup generator available during power interruptions.',
      amenities: ['Wi-Fi', 'Backup power', 'Kitchen', 'Water refill station'],
    ),
    const Property(
      id: 'p3',
      name: 'Sunrise Lodge',
      imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      pricePerMonth: 1800,
      distanceMeters: 1400,
      rating: 4.3,
      isVerified: false,
      availableRooms: 5,
      ownerName: 'Elena Reyes',
      reviewCount: 15,
      description: 'Budget-friendly lodge with basic shared amenities — a solid pick '
          'if you\'re prioritizing savings over distance.',
      amenities: ['Shared CR', 'Kitchen access', 'Study area'],
    ),
    const Property(
      id: 'p4',
      name: 'The Nook',
      imageUrl: 'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=800',
      gallery: ['https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800'],
      pricePerMonth: 2900,
      distanceMeters: 500,
      rating: 4.9,
      isVerified: true,
      availableRooms: 2,
      ownerName: 'Grace Villamor',
      reviewCount: 61,
      description: 'A premium option with air-conditioned rooms, '
          'quiet hours strictly enforced, and a dedicated study lounge on the ground floor.',
      amenities: ['Air-conditioning', 'Wi-Fi', 'Study lounge', 'CCTV', 'Laundry service', '24/7 security'],
    ),
    const Property(
      id: 'p5',
      name: 'Palm View Homestay',
      imageUrl: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800',
      pricePerMonth: 1600,
      distanceMeters: 1900,
      rating: 4.1,
      isVerified: false,
      availableRooms: 4,
      ownerName: 'Fernando Diaz',
      reviewCount: 9,
      description: 'A family-run homestay with a relaxed, homey atmosphere. Meals '
          'available on request for an extra fee.',
      amenities: ['Home-cooked meals (optional)', 'Garden area', 'Shared CR'],
    ),
    const Property(
      id: 'p6',
      name: 'Camino Suites',
      imageUrl: 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
      pricePerMonth: 3200,
      distanceMeters: 750,
      rating: 4.7,
      isVerified: true,
      availableRooms: 1,
      ownerName: 'Camino Property Group',
      reviewCount: 33,
      description: 'A premium StayEase listing with private '
          'rooms with attached CR, high-speed Wi-Fi, and a rooftop common area.',
      amenities: ['Attached CR', 'High-speed Wi-Fi', 'Rooftop lounge', 'Air-conditioning', 'CCTV'],
    ),
    const Property(
      id: 'p7',
      name: "Nena's Place",
      imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      pricePerMonth: 2000,
      distanceMeters: 1100,
      rating: 4.4,
      isVerified: true,
      availableRooms: 3,
      ownerName: 'Nena Aquino',
      reviewCount: 22,
      description: 'Well-loved by returning tenants for its friendly landlady and '
          'strict but fair house rules.',
      amenities: ['Wi-Fi', 'Kitchen', 'Curfew: 10PM', 'Visitor logbook'],
    ),
    const Property(
      id: 'p8',
      name: 'Northgate Residences',
      imageUrl: 'https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800',
      pricePerMonth: 2650,
      distanceMeters: 2100,
      rating: 4.2,
      isVerified: false,
      availableRooms: 6,
      ownerName: 'Northgate Realty',
      reviewCount: 18,
      description: 'A little farther out, with larger rooms and lower density per floor — '
          'a good fit for tenants who prefer more personal space.',
      amenities: ['Parking area', 'Wi-Fi', 'Shared kitchen', 'Common lounge'],
    ),
  ];

  static MatchRecommendation get topMatch => MatchRecommendation(
        property: nearbyProperties[0],
        matchScore: 94,
        reason: 'Fits your budget, preferred room type, and selected location.',
      );

  static ActiveReservation? get activeReservation => ActiveReservation(
        propertyName: "Maria's Boarding House",
        roomLabel: 'Room 204',
        checkInDate: DateTime.now().add(const Duration(days: 4)),
        propertyImageUrl: nearbyProperties[0].imageUrl,
      );

  static RentStatus? get rentStatus => RentStatus(
        amount: 2500,
        dueDate: DateTime.now().add(const Duration(days: 4)),
        isPaid: false,
      );

  static final List<TenantNotification> notifications = [
    const TenantNotification(
      kind: NotificationKind.reservationApproved,
      title: 'Your reservation at Maria\'s was approved',
      timeAgo: '2h ago',
    ),
    const TenantNotification(
      kind: NotificationKind.rentReminder,
      title: 'Rent of ₱2,500 due in 4 days',
      timeAgo: '5h ago',
    ),
  ];
}
