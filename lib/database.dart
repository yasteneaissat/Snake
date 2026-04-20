import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────── MODÈLE SCORE ───────────────────────────
class ScoreEntry {
  final String? id;
  final String nom;
  final int score;
  final int niveau;
  final String difficulte;
  final DateTime date;

  ScoreEntry({
    this.id,
    required this.nom,
    required this.score,
    required this.niveau,
    required this.difficulte,
    required this.date,
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() => {
    'nom':        nom,
    'score':      score,
    'niveau':     niveau,
    'difficulte': difficulte,
    'date':       Timestamp.fromDate(date),
  };

  // Créer depuis un document Firestore
  factory ScoreEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ScoreEntry(
      id:         doc.id,
      nom:        d['nom']        ?? 'Anonyme',
      score:      d['score']      ?? 0,
      niveau:     d['niveau']     ?? 1,
      difficulte: d['difficulte'] ?? 'NORMAL',
      date:       (d['date'] as Timestamp).toDate(),
    );
  }

  // Date formatée lisible
  String get dateFormatee {
    final d = date;
    final jour  = d.day.toString().padLeft(2, '0');
    final mois  = d.month.toString().padLeft(2, '0');
    final annee = d.year.toString();
    final heure = d.hour.toString().padLeft(2, '0');
    final min   = d.minute.toString().padLeft(2, '0');
    return '$jour/$mois/$annee à $heure:$min';
  }
}

// ─────────────────────────── SERVICE FIRESTORE ───────────────────────────
class ScoreService {
  static final ScoreService _instance = ScoreService._();
  factory ScoreService() => _instance;
  ScoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'scores';

  // Sauvegarder un score
  Future<void> sauvegarderScore(ScoreEntry entry) async {
    try {
      await _db.collection(_collection).add(entry.toMap());
    } catch (e) {
      print('Erreur sauvegarde score: $e');
    }
  }

  // Récupérer le top 10 global
  Future<List<ScoreEntry>> getTop10() async {
    try {
      final snap = await _db
          .collection(_collection)
          .orderBy('score', descending: true)
          .limit(10)
          .get();
      return snap.docs.map((d) => ScoreEntry.fromDoc(d)).toList();
    } catch (e) {
      print('Erreur récupération scores: $e');
      return [];
    }
  }

  // Récupérer les scores d'un joueur
  Future<List<ScoreEntry>> getScoresJoueur(String nom) async {
    try {
      final snap = await _db
          .collection(_collection)
          .where('nom', isEqualTo: nom)
          .orderBy('score', descending: true)
          .limit(5)
          .get();
      return snap.docs.map((d) => ScoreEntry.fromDoc(d)).toList();
    } catch (e) {
      print('Erreur récupération scores joueur: $e');
      return [];
    }
  }

  // Stream en temps réel pour le leaderboard
  Stream<List<ScoreEntry>> streamTop10() {
    return _db
        .collection(_collection)
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ScoreEntry.fromDoc(d)).toList());
  }
}

final scoreService = ScoreService();
