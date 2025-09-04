import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VegetablesRecord extends FirestoreRecord {
  VegetablesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "food_name" field.
  String? _foodName;
  String get foodName => _foodName ?? '';
  bool hasFoodName() => _foodName != null;

  // "calories" field.
  int? _calories;
  int get calories => _calories ?? 0;
  bool hasCalories() => _calories != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "price" field.
  int? _price;
  int get price => _price ?? 0;
  bool hasPrice() => _price != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  void _initializeFields() {
    _foodName = snapshotData['food_name'] as String?;
    _calories = castToType<int>(snapshotData['calories']);
    _imageUrl = snapshotData['image_url'] as String?;
    _price = castToType<int>(snapshotData['price']);
    _category = snapshotData['category'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('vegetables');

  static Stream<VegetablesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VegetablesRecord.fromSnapshot(s));

  static Future<VegetablesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VegetablesRecord.fromSnapshot(s));

  static VegetablesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VegetablesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VegetablesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VegetablesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VegetablesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VegetablesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVegetablesRecordData({
  String? foodName,
  int? calories,
  String? imageUrl,
  int? price,
  String? category,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'food_name': foodName,
      'calories': calories,
      'image_url': imageUrl,
      'price': price,
      'category': category,
    }.withoutNulls,
  );

  return firestoreData;
}

class VegetablesRecordDocumentEquality implements Equality<VegetablesRecord> {
  const VegetablesRecordDocumentEquality();

  @override
  bool equals(VegetablesRecord? e1, VegetablesRecord? e2) {
    return e1?.foodName == e2?.foodName &&
        e1?.calories == e2?.calories &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.price == e2?.price &&
        e1?.category == e2?.category;
  }

  @override
  int hash(VegetablesRecord? e) => const ListEquality()
      .hash([e?.foodName, e?.calories, e?.imageUrl, e?.price, e?.category]);

  @override
  bool isValidKey(Object? o) => o is VegetablesRecord;
}
