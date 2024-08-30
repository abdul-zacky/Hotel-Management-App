import 'package:cloud_firestore/cloud_firestore.dart' hide FromFirestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/apis/get_checks_data.api.dart';
import 'package:wisma1/models/check_model.dart';

class GetChecksData extends StateNotifier<List<Check>> {
  GetChecksData({required this.fromFirestore}) : super([]);

  final FromFirestore fromFirestore;
  DocumentSnapshot? lastDocument;

  Future<List<Check>> getInitialCheckData() async {
    try {
      final data = await fromFirestore.getChecksData();
      lastDocument = data.docs.isNotEmpty ? data.docs.last : null;

      final List<Check> checksData = data.docs
          .map((doc) => Check.fromFireStore(doc))
          .toList();

      state = checksData;
    } catch (e) {
      print("Error fetching initial checks data: $e");
      rethrow;
    }
    return state;
  }

  Future<void> getNextChecksData() async {
    try {
      // Fetch data from Firestore, with pagination if lastDocument is available
      final data = await fromFirestore.getChecksData(lastDocument: lastDocument);

      if (data.docs.isNotEmpty) {
        lastDocument = data.docs.last;
        final List<Check> checksData =
            data.docs.map((doc) => Check.fromFireStore(doc)).toList();
        // Update the state with new checks data
        state = [...state, ...checksData];
      } else {
        // Handle the case where there are no more documents to fetch
        print("No more checks data to fetch");
      }
    } catch (e) {
      // Handle exceptions gracefully
      print("Error fetching next checks data: $e");
      rethrow;
    }
  }

  Future<void> addCheck(Check newCheck) async {
    try {
      final docRef = await fromFirestore.addCheck(newCheck);
      final checkWithId = Check(
        id: newCheck.id,
        guestName: newCheck.guestName,
        roomNumber: newCheck.roomNumber,
        checkDate: newCheck.checkDate,
        checkOutDate: newCheck.checkOutDate,
        status: newCheck.status,
        lastDayPaid: newCheck.lastDayPaid,
        createdAt: newCheck.createdAt,
      );
      state = [...state, checkWithId];
    } catch (e) {
      print("Error adding check: $e");
      rethrow;
    }
  }
}

// Declare the provider at the top-level scope
final getChecksDataProvider = StateNotifierProvider<GetChecksData, List<Check>>(
  (ref) => GetChecksData(fromFirestore: ref.watch(fromFirestoreAPIProvider)),
);
