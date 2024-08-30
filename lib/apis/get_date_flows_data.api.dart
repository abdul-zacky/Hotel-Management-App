import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/date_flow_model.dart';

final fromFirestoreAPIProvider =
    Provider<FromFirestore>((ref) => FromFirestore());

class FromFirestore {
  Future<QuerySnapshot<Object?>> getDateFlowsData({
    DocumentSnapshot? lastDocument,
  }) async {
    CollectionReference dateFlowsDataCollection =
        FirebaseFirestore.instance.collection('dateFlows');

    Query dateFlowsQuery = dateFlowsDataCollection.limit(5);

    if (lastDocument != null) {
      dateFlowsQuery = dateFlowsQuery.startAfterDocument(lastDocument);
    }

    final QuerySnapshot querySnapshot = await dateFlowsQuery.get();
    return querySnapshot;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<DocumentReference> addCheck(DateFlow dateFlow) {
    return _firestore.collection('dateFlows').add(dateFlow.toFirestore());
  }
}
