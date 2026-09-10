import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

class PropertyService {
  PropertyService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _properties => _firestore.collection('properties');

  /// Live list of the properties this owner has listed, newest first.
  /// The pre-seeded demo properties (p1–p8) have no ownerId, so they
  /// never appear here — expected, they're tenant-browse-only samples.
  Stream<List<PropertyModel>> watchOwnerProperties(String ownerId) {
    return _properties
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PropertyModel.fromMap(d.id, d.data())).toList());
  }

  /// Every property in the marketplace, for tenant browsing — includes
  /// both the seeded demo listings and anything owners have added.
  Stream<List<PropertyModel>> watchAllProperties() {
    return _properties
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PropertyModel.fromMap(d.id, d.data())).toList());
  }

  Future<String> createProperty(PropertyModel property) async {
    final ref = await _properties.add(property.toMap());
    return ref.id;
  }

  /// One-time fetch — used by the payment screen to get the exact price
  /// without keeping a live listener open just for that.
  Future<PropertyModel?> getProperty(String propertyId) async {
    final doc = await _properties.doc(propertyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return PropertyModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> setPropertyStatus(String propertyId, String status) {
    return _properties.doc(propertyId).update({'status': status});
  }
}
