import 'package:flutter/material.dart';
import 'database.dart';

// ─────────────────────────── COULEURS (copie légère) ───────────────────────────
const Color _bg     = Color(0xFF050510);
const Color _grid   = Color(0xFF0D0D2B);
const Color _green  = Color(0xFF00FF9F);
const Color _blue   = Color(0xFF00D4FF);
const Color _pink   = Color(0xFFFF2D78);
const Color _yellow = Color(0xFFFFE600);
const Color _purple = Color(0xFFBF00FF);

// ─────────────────────────── ÉCRAN LEADERBOARD ───────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _glowCtrl.dispose(); super.dispose(); }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1: return _yellow;
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return _blue.withOpacity(0.7);
    }
  }

  String _rankIcon(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '#$rank';
    }
  }

  Color _diffColor(String diff) {
    switch (diff.toUpperCase()) {
      case 'EASY':   return _green;
      case 'NORMAL': return _blue;
      case 'HARD':   return _yellow;
      case 'INSANE': return _pink;
      default:       return _blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_ios, color: _blue, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text('LEADERBOARD', style: TextStyle(
                color: _yellow, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4,
                shadows: [Shadow(color: _yellow, blurRadius: 12)],
              )),
            ]),
          ),
          // Liste en temps réel
          Expanded(
            child: StreamBuilder<List<ScoreEntry>>(
              stream: scoreService.streamTop10(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _green));
                }
                if (snapshot.hasError) {
                  return Center(child: Text(
                    'Erreur de connexion\n${snapshot.error}',
                    style: const TextStyle(color: _pink),
                    textAlign: TextAlign.center,
                  ));
                }
                final scores = snapshot.data ?? [];
                if (scores.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🐍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text('Aucun score encore !',
                      style: TextStyle(color: _blue.withOpacity(0.7), fontSize: 16, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('Sois le premier à jouer',
                      style: TextStyle(color: _blue.withOpacity(0.4), fontSize: 12)),
                  ]));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: scores.length,
                  itemBuilder: (_, i) {
                    final s = scores[i];
                    final rank = i + 1;
                    final rColor = _rankColor(rank);
                    return AnimatedBuilder(
                      animation: _glowCtrl,
                      builder: (_, __) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: rank <= 3
                                ? rColor.withOpacity(0.6 + 0.2 * _glowCtrl.value)
                                : _grid,
                            width: rank == 1 ? 2 : 1,
                          ),
                          color: rank <= 3
                              ? rColor.withOpacity(0.05)
                              : _grid.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: rank <= 3 ? [
                            BoxShadow(
                              color: rColor.withOpacity(0.15 + 0.1 * _glowCtrl.value),
                              blurRadius: 12,
                            )
                          ] : [],
                        ),
                        child: Row(children: [
                          // Rang
                          SizedBox(
                            width: 40,
                            child: Text(_rankIcon(rank),
                              style: TextStyle(
                                fontSize: rank <= 3 ? 22 : 14,
                                color: rColor,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Infos joueur
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.nom, style: TextStyle(
                                color: rank == 1 ? _yellow : Colors.white,
                                fontSize: 15, fontWeight: FontWeight.w700,
                                shadows: rank == 1
                                    ? [const Shadow(color: _yellow, blurRadius: 8)]
                                    : [],
                              )),
                              const SizedBox(height: 3),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _diffColor(s.difficulte).withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(s.difficulte, style: TextStyle(
                                    color: _diffColor(s.difficulte),
                                    fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
                                  )),
                                ),
                                const SizedBox(width: 8),
                                Text('Niv. ${s.niveau}',
                                  style: TextStyle(color: _blue.withOpacity(0.6), fontSize: 11)),
                                const SizedBox(width: 8),
                                Text(s.dateFormatee,
                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                              ]),
                            ],
                          )),
                          // Score
                          Text('${s.score}', style: TextStyle(
                            color: rColor,
                            fontSize: 22, fontWeight: FontWeight.w900,
                            shadows: [Shadow(color: rColor, blurRadius: 8)],
                          )),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Info temps réel
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _green,
                  boxShadow: [BoxShadow(color: _green, blurRadius: 4)])),
              const SizedBox(width: 6),
              Text('Mise à jour en temps réel',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 1)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────── POPUP NOM JOUEUR ───────────────────────────
class NomJoueurDialog extends StatefulWidget {
  const NomJoueurDialog({super.key});
  @override State<NomJoueurDialog> createState() => _NomJoueurDialogState();
}

class _NomJoueurDialogState extends State<NomJoueurDialog> {
  final _ctrl = TextEditingController();
  bool _error = false;

  void _valider() {
    final nom = _ctrl.text.trim();
    if (nom.isEmpty || nom.length < 2) {
      setState(() => _error = true);
      return;
    }
    Navigator.of(context).pop(nom);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A0A1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _green.withOpacity(0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🐍', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          const Text('TON NOM', style: TextStyle(
            color: _green, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4,
            shadows: [Shadow(color: _green, blurRadius: 10)],
          )),
          const SizedBox(height: 6),
          Text('Il apparaîtra dans le leaderboard',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLength: 12,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'EX: PLAYER1',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 2),
              counterStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              errorText: _error ? 'Minimum 2 caractères' : null,
              errorStyle: const TextStyle(color: _pink),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _blue.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _pink),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _pink, width: 2),
              ),
            ),
            onSubmitted: (_) => _valider(),
            onChanged: (_) { if (_error) setState(() => _error = false); },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _valider,
            child: Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: _green, width: 2),
                color: _green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: _green.withOpacity(0.3), blurRadius: 12)],
              ),
              child: const Center(child: Text('JOUER  ▶', style: TextStyle(
                color: _green, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 4))),
            ),
          ),
        ]),
      ),
    );
  }
}
