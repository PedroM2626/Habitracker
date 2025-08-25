import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  String? get currentUserId => auth.currentUser?.uid;
  
  bool get isUserAuthenticated => auth.currentUser != null;
  
  void requireAuthentication() {
    if (!isUserAuthenticated) {
      throw Exception('User must be authenticated to perform this operation');
    }
  }
  
  /// Convert Firestore Timestamp to DateTime
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }
  
  /// Convert DateTime to Firestore Timestamp
  Timestamp dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
  
  /// Handle Firestore errors
  Exception handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('Permissão negada para acessar este recurso');
        case 'not-found':
          return Exception('Documento não encontrado');
        case 'already-exists':
          return Exception('Documento já existe');
        case 'unavailable':
          return Exception('Serviço temporariamente indisponível');
        default:
          return Exception('Erro no banco de dados: ${error.message}');
      }
    }
    return Exception('Erro desconhecido: $error');
  }
}