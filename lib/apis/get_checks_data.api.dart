import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/check_model.dart';

final fromFirestoreAPIProvider =
    Provider<FromFirestore>((ref) => FromFirestore());

class FromFirestore {
  Future<QuerySnapshot<Object?>> getChecksData({
    DocumentSnapshot? lastDocument,
  }) async {
    CollectionReference checksDataCollection =
        FirebaseFirestore.instance.collection('checksData');

    Query checksQuery = checksDataCollection.limit(5);

    if (lastDocument != null) {
      checksQuery = checksQuery.startAfterDocument(lastDocument);
    }

    final QuerySnapshot querySnapshot = await checksQuery.get();
    return querySnapshot;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<DocumentReference> addCheck(Check check) {
    return _firestore.collection('checks').add(check.toFirestore());
  }
}
