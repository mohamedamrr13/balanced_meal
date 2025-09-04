import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CartRecord extends FirestoreRecord {
  CartRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "calories" field.
  int? _calories;
  int get calories => _calories ?? 0;
  bool hasCalories() => _calories != null;

  // "food_name" field.
  String? _foodName;
  String get foodName => _foodName ?? '';
  bool hasFoodName() => _foodName != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "price" field.
  int? _price;
  int get price => _price ?? 0;
  bool hasPrice() => _price != null;

  // "quanitity" field.
  int? _quanitity;
  int get quanitity => _quanitity ?? 0;
  bool hasQuanitity() => _quanitity != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  void _initializeFields() {
    _calories = castToType<int>(snapshotData['calories']);
    _foodName = snapshotData['food_name'] as String?;
    _imageUrl = snapshotData['image_url'] as String?;
    _price = castToType<int>(snapshotData['price']);
    _quanitity = castToType<int>(snapshotData['quanitity']);
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _category = snapshotData['category'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('cart');

  static Stream<CartRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CartRecord.fromSnapshot(s));

  static Future<CartRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CartRecord.fromSnapshot(s));

  static CartRecord fromSnapshot(DocumentSnapshot snapshot) => CartRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CartRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CartRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CartRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CartRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCartRecordData({
  int? calories,
  String? foodName,
  String? imageUrl,
  int? price,
  int? quanitity,
  DateTime? timestamp,
  String? category,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'calories': calories,
      'food_name': foodName,
      'image_url': imageUrl,
      'price': price,
      'quanitity': quanitity,
      'timestamp': timestamp,
      'category': category,
    }.withoutNulls,
  );

  return firestoreData;
}

class CartRecordDocumentEquality implements Equality<CartRecord> {
  const CartRecordDocumentEquality();

  @override
  bool equals(CartRecord? e1, CartRecord? e2) {
    return e1?.calories == e2?.calories &&
        e1?.foodName == e2?.foodName &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.price == e2?.price &&
        e1?.quanitity == e2?.quanitity &&
        e1?.timestamp == e2?.timestamp &&
        e1?.category == e2?.category;
  }

  @override
  int hash(CartRecord? e) => const ListEquality().hash([
        e?.calories,
        e?.foodName,
        e?.imageUrl,
        e?.price,
        e?.quanitity,
        e?.timestamp,
        e?.category
      ]);

  @override
  bool isValidKey(Object? o) => o is CartRecord;
}
