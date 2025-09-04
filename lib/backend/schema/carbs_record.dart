import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CarbsRecord extends FirestoreRecord {
  CarbsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "food_name" field.
  String? _foodName;
  String get foodName => _foodName ?? '';
  bool hasFoodName() => _foodName != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "calories" field.
  int? _calories;
  int get calories => _calories ?? 0;
  bool hasCalories() => _calories != null;

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
    _imageUrl = snapshotData['image_url'] as String?;
    _calories = castToType<int>(snapshotData['calories']);
    _price = castToType<int>(snapshotData['price']);
    _category = snapshotData['category'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('carbs');

  static Stream<CarbsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CarbsRecord.fromSnapshot(s));

  static Future<CarbsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CarbsRecord.fromSnapshot(s));

  static CarbsRecord fromSnapshot(DocumentSnapshot snapshot) => CarbsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CarbsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CarbsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CarbsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CarbsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCarbsRecordData({
  String? foodName,
  String? imageUrl,
  int? calories,
  int? price,
  String? category,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'price': price,
      'category': category,
    }.withoutNulls,
  );

  return firestoreData;
}

class CarbsRecordDocumentEquality implements Equality<CarbsRecord> {
  const CarbsRecordDocumentEquality();

  @override
  bool equals(CarbsRecord? e1, CarbsRecord? e2) {
    return e1?.foodName == e2?.foodName &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.calories == e2?.calories &&
        e1?.price == e2?.price &&
        e1?.category == e2?.category;
  }

  @override
  int hash(CarbsRecord? e) => const ListEquality()
      .hash([e?.foodName, e?.imageUrl, e?.calories, e?.price, e?.category]);

  @override
  bool isValidKey(Object? o) => o is CarbsRecord;
}
