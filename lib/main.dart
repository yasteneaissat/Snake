import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database.dart';
import 'leaderboard.dart';

// ─────────────────────────── AUDIO MANAGER ───────────────────────────
class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final AudioPlayer _player = AudioPlayer();
  String? _current;

  Future<void> play(String track) async {
    if (_current == track) return; // déjà en cours
    _current = track;
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/$track.mp3'));
  }

  Future<void> pause()  async => await _player.pause();
  Future<void> resume() async => await _player.resume();
  Future<void> stop()   async { _current = null; await _player.stop(); }

  void dispose() => _player.dispose();
}

final audio = AudioManager();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyALy0Zol7hcal7mRUAWR7seZLCjgWMDV28",
      authDomain: "serpent-exe.firebaseapp.com",
      projectId: "serpent-exe",
      storageBucket: "serpent-exe.firebasestorage.app",
      messagingSenderId: "186400368437",
      appId: "1:186400368437:web:58a7bb627f1c41325c4e7c",
    ),
  );
  runApp(const SnakeApp());
}

// ─────────────────────────── THEME ───────────────────────────
enum AppTheme { dark, light }

class ThemeNotifier extends ValueNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.dark);
  void toggle() => value = value == AppTheme.dark ? AppTheme.light : AppTheme.dark;
}

final themeNotifier = ThemeNotifier();

// Dark theme colors
const Color kDarkBg        = Color(0xFF050510);
const Color kDarkGrid      = Color(0xFF0D0D2B);
const Color kDarkSnakeHead = Color(0xFF00FF9F);
const Color kDarkSnakeTail = Color(0xFF00D4FF);
const Color kDarkAccent    = Color(0xFF00D4FF);
const Color kDarkPink      = Color(0xFFFF2D78);
const Color kDarkYellow    = Color(0xFFFFE600);
const Color kDarkPurple    = Color(0xFFBF00FF);

// Light theme colors
const Color kLightBg        = Color(0xFFF5F0FF);
const Color kLightGrid      = Color(0xFFE8DEFF);
const Color kLightSnakeHead = Color(0xFFFF3B8E);
const Color kLightSnakeTail = Color(0xFFFF85B8);
const Color kLightAccent    = Color(0xFF7C3AED);
const Color kLightPink      = Color(0xFFDB2777);
const Color kLightYellow    = Color(0xFFF59E0B);
const Color kLightPurple    = Color(0xFF8B5CF6);

class GameColors {
  final Color bg, grid, snakeHead, snakeTail, accent, danger, bonus, text, textSub;
  final bool isDark;
  const GameColors({
    required this.bg, required this.grid, required this.snakeHead,
    required this.snakeTail, required this.accent, required this.danger,
    required this.bonus, required this.text, required this.textSub,
    required this.isDark,
  });

  static GameColors of(AppTheme t) => t == AppTheme.dark
      ? const GameColors(
          bg: kDarkBg, grid: kDarkGrid, snakeHead: kDarkSnakeHead,
          snakeTail: kDarkSnakeTail, accent: kDarkAccent, danger: kDarkPink,
          bonus: kDarkPurple, text: Colors.white, textSub: Color(0xFF6B7280),
          isDark: true,
        )
      : const GameColors(
          bg: kLightBg, grid: kLightGrid, snakeHead: kLightSnakeHead,
          snakeTail: kLightSnakeTail, accent: kLightAccent, danger: kLightPink,
          bonus: kLightPurple, text: Color(0xFF1E1B4B), textSub: Color(0xFF9CA3AF),
          isDark: false,
        );
}

// ─────────────────────────── APP ───────────────────────────
class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: themeNotifier,
      builder: (_, theme, __) {
        final c = GameColors.of(theme);
        return MaterialApp(
          title: 'SERPENT.EXE',
          debugShowCheckedModeBanner: false,
          theme: theme == AppTheme.dark
              ? ThemeData.dark().copyWith(scaffoldBackgroundColor: c.bg)
              : ThemeData.light().copyWith(scaffoldBackgroundColor: c.bg),
          home: MenuScreen(colors: c),
        );
      },
    );
  }
}

// ─────────────────────────── CONSTANTS ───────────────────────────
const int kCols = 20;
const int kRows = 28;

enum Direction { up, down, left, right }
enum GameState { playing, paused, gameOver }
enum Difficulty { easy, normal, hard, insane }

extension DifficultyExt on Difficulty {
  String get label => ['EASY', 'NORMAL', 'HARD', 'INSANE'][index];
  int get speed    => [250, 150, 90, 50][index];
  int get multi    => [1, 2, 3, 5][index];
}

// ─────────────────────────── MODELS ───────────────────────────
class Point {
  final int x, y;
  const Point(this.x, this.y);
  @override bool operator ==(Object o) => o is Point && o.x == x && o.y == y;
  @override int get hashCode => Object.hash(x, y);
}

class FoodItem {
  final Point pos;
  final Color color;
  final int value;
  final bool isBonus;
  final DateTime spawnTime;
  FoodItem({required this.pos, required this.color, required this.value, this.isBonus = false})
      : spawnTime = DateTime.now();
  double get age => DateTime.now().difference(spawnTime).inMilliseconds / 1000.0;
}

class Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;
  Particle({required this.x, required this.y, required this.vx, required this.vy,
            required this.life, required this.color, required this.size}) : maxLife = life;
}

// ─────────────────────────── MENU ───────────────────────────
class MenuScreen extends StatefulWidget {
  final GameColors colors;
  const MenuScreen({super.key, required this.colors});
  @override State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _glowCtrl, _floatCtrl, _scanCtrl;
  Difficulty _diff = Difficulty.normal;

  @override
  void initState() {
    super.initState();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _scanCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    audio.play('menu');
  }

  @override
  void dispose() {
    _glowCtrl.dispose(); _floatCtrl.dispose(); _scanCtrl.dispose();
    super.dispose();
  }

  void _startGame() async {
    // Demander le nom du joueur
    final nom = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NomJoueurDialog(),
    );
    if (nom == null || !mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => GameScreen(difficulty: _diff, nomJoueur: nom),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  void _ouvrirLeaderboard() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const LeaderboardScreen(),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  Color _diffColor(Difficulty d, GameColors c) {
    switch (d) {
      case Difficulty.easy:   return c.snakeHead;
      case Difficulty.normal: return c.accent;
      case Difficulty.hard:   return c.isDark ? kDarkYellow : kLightYellow;
      case Difficulty.insane: return c.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: themeNotifier,
      builder: (_, theme, __) {
        final c = GameColors.of(theme);
        return Scaffold(
          backgroundColor: c.bg,
          body: Stack(children: [
            CustomPaint(painter: BgPainter(scan: _scanCtrl, colors: c), size: Size.infinite),
            if (c.isDark) ...[
              _GlowOrb(ctrl: _glowCtrl, color: c.accent,  top: -100, left: -50,  size: 300, opacity: 0.15),
              _GlowOrb(ctrl: _glowCtrl, color: c.danger,  bottom: -80, right: -60, size: 250, opacity: 0.12, invert: true),
            ],
            SafeArea(child: Column(children: [
              // Theme toggle
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(
                    onTap: () => setState(() => themeNotifier.toggle()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.accent.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(20),
                        color: c.accent.withOpacity(0.1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(theme == AppTheme.dark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                            color: c.accent, size: 14),
                        const SizedBox(width: 6),
                        Text(theme == AppTheme.dark ? 'CLAIR' : 'SOMBRE',
                          style: TextStyle(color: c.accent, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ]),
              ),
              const Spacer(flex: 2),
              // Logo
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -8 * _floatCtrl.value),
                  child: Column(children: [
                    SizedBox(width: 80, height: 80,
                      child: CustomPaint(painter: SnakeLogoPainter(anim: _glowCtrl, color: c.snakeHead))),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(colors: [c.snakeHead, c.accent]).createShader(b),
                      child: const Text('SERPENT', style: TextStyle(
                          fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 10, color: Colors.white)),
                    ),
                    Text('.EXE', style: TextStyle(
                        fontSize: 16, color: c.danger, letterSpacing: 8, fontWeight: FontWeight.w300)),
                  ]),
                ),
              ),
              const Spacer(),
              // Difficulty
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  Text('DIFFICULTÉ', style: TextStyle(
                      color: c.accent.withOpacity(0.7), fontSize: 11, letterSpacing: 3)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: Difficulty.values.map((d) {
                      final sel = d == _diff;
                      final dColor = _diffColor(d, c);
                      return GestureDetector(
                        onTap: () => setState(() => _diff = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            border: Border.all(color: sel ? dColor : dColor.withOpacity(0.3), width: sel ? 2 : 1),
                            color: sel ? dColor.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: sel ? [BoxShadow(color: dColor.withOpacity(0.35), blurRadius: 12)] : [],
                          ),
                          child: Text(d.label, style: TextStyle(
                              color: sel ? dColor : dColor.withOpacity(0.5),
                              fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        ),
                      );
                    }).toList(),
                  ),
                ]),
              ),
              const SizedBox(height: 36),
              // Start button
              AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) => GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    width: 200, height: 54,
                    decoration: BoxDecoration(
                      border: Border.all(color: c.snakeHead, width: 2),
                      color: c.snakeHead.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(
                        color: c.snakeHead.withOpacity(0.25 + 0.2 * _glowCtrl.value),
                        blurRadius: 18 + 8 * _glowCtrl.value,
                      )],
                    ),
                    child: Center(child: Text('▶  JOUER', style: TextStyle(
                        color: c.snakeHead, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 4))),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Leaderboard button
              GestureDetector(
                onTap: _ouvrirLeaderboard,
                child: Container(
                  width: 200, height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: c.isDark ? kDarkYellow : kLightYellow, width: 1.5),
                    color: (c.isDark ? kDarkYellow : kLightYellow).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text('🏆  SCORES', style: TextStyle(
                      color: c.isDark ? kDarkYellow : kLightYellow,
                      fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 3))),
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text('SWIPE ou TOUCHES FLÉCHÉES pour diriger',
                    style: TextStyle(color: c.textSub, fontSize: 10, letterSpacing: 2)),
              ),
            ])),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────── GAME SCREEN ───────────────────────────
class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final String nomJoueur;
  const GameScreen({super.key, required this.difficulty, required this.nomJoueur});
  @override State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<Point> _snake = [];
  Direction _dir = Direction.right;
  Direction _nextDir = Direction.right;
  FoodItem? _food;
  FoodItem? _bonusFood;
  int _score = 0, _highScore = 0, _level = 1, _eaten = 0;
  GameState _state = GameState.playing;
  Timer? _gameTimer, _bonusTimer;
  final List<Particle> _particles = [];
  final Random _rng = Random();

  late AnimationController _glowCtrl, _shakeCtrl, _particleCtrl, _scorePopCtrl;
  late Animation<double> _shakeAnim;

  GameColors get c => GameColors.of(themeNotifier.value);

  @override
  void initState() {
    super.initState();
    _glowCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _shakeCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim    = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 50))
      ..addListener(_updateParticles)..repeat();
    _scorePopCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _initGame();
    audio.play('game');
  }

  void _initGame() {
    _snake   = [const Point(8, 14), const Point(7, 14), const Point(6, 14)];
    _dir     = Direction.right;
    _nextDir = Direction.right;
    _score = 0; _level = 1; _eaten = 0;
    _particles.clear();
    _spawnFood();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    final speed = max(40, widget.difficulty.speed - (_level - 1) * 10);
    _gameTimer = Timer.periodic(Duration(milliseconds: speed), (_) => _tick());
  }

  void _tick() {
    if (_state != GameState.playing) return;
    setState(() => _move());
  }

  void _move() {
    _dir = _nextDir;
    final head = _snake.first;
    final newHead = switch (_dir) {
      Direction.up    => Point(head.x, (head.y - 1 + kRows) % kRows),
      Direction.down  => Point(head.x, (head.y + 1) % kRows),
      Direction.left  => Point((head.x - 1 + kCols) % kCols, head.y),
      Direction.right => Point((head.x + 1) % kCols, head.y),
    };

    if (_snake.contains(newHead)) { _die(); return; }
    _snake.insert(0, newHead);

    bool ate = false;
    if (_food != null && newHead == _food!.pos) {
      _eatFood(_food!); ate = true; _spawnFood();
    } else if (_bonusFood != null && newHead == _bonusFood!.pos) {
      _eatFood(_bonusFood!); ate = true;
      _bonusFood = null; _bonusTimer?.cancel();
    }
    if (!ate) _snake.removeLast();
  }

  void _eatFood(FoodItem food) {
    final pts = food.value * widget.difficulty.multi;
    _score += pts; _eaten++;
    _scorePopCtrl.forward(from: 0);
    if (_eaten % 5 == 0) { _level++; _startTimer(); }
    if (_score > _highScore) _highScore = _score;
    if (_eaten % 3 == 0 && _bonusFood == null) _spawnBonus();
    _spawnParticles(food.pos, food.color);
  }

  void _spawnParticles(Point pos, Color color) {
    for (int i = 0; i < 14; i++) {
      _particles.add(Particle(
        x: pos.x.toDouble(), y: pos.y.toDouble(),
        vx: (_rng.nextDouble() - 0.5) * 0.35,
        vy: (_rng.nextDouble() - 0.5) * 0.35,
        life: 0.8 + _rng.nextDouble() * 0.4,
        color: color, size: 0.2 + _rng.nextDouble() * 0.3,
      ));
    }
  }

  void _updateParticles() {
    setState(() {
      for (final p in _particles) { p.x += p.vx; p.y += p.vy; p.life -= 0.05; }
      _particles.removeWhere((p) => p.life <= 0);
    });
  }

  void _spawnFood() {
    Point pos;
    do { pos = Point(_rng.nextInt(kCols), _rng.nextInt(kRows)); } while (_snake.contains(pos));
    final colors = [c.snakeHead, c.accent, c.danger, c.isDark ? kDarkYellow : kLightYellow];
    _food = FoodItem(pos: pos, color: colors[_rng.nextInt(colors.length)], value: 10);
  }

  void _spawnBonus() {
    Point pos;
    do { pos = Point(_rng.nextInt(kCols), _rng.nextInt(kRows)); }
    while (_snake.contains(pos) || pos == _food?.pos);
    _bonusFood = FoodItem(pos: pos, color: c.bonus, value: 50, isBonus: true);
    _bonusTimer?.cancel();
    _bonusTimer = Timer(const Duration(seconds: 6), () => setState(() => _bonusFood = null));
  }

  void _die() {
    _gameTimer?.cancel(); _bonusTimer?.cancel();
    _shakeCtrl.forward(from: 0);
    _spawnParticles(_snake.first, c.danger);
    audio.play('gameover');
    // Sauvegarde dans Firestore
    scoreService.sauvegarderScore(ScoreEntry(
      nom:        widget.nomJoueur,
      score:      _score,
      niveau:     _level,
      difficulte: widget.difficulty.label,
      date:       DateTime.now(),
    ));
    setState(() => _state = GameState.gameOver);
  }

  void _setDir(Direction d) {
    if ((_dir == Direction.up    && d == Direction.down)  ||
        (_dir == Direction.down  && d == Direction.up)    ||
        (_dir == Direction.left  && d == Direction.right) ||
        (_dir == Direction.right && d == Direction.left)) return;
    _nextDir = d;
  }

  void _togglePause() {
    setState(() {
      if (_state == GameState.playing) {
        _state = GameState.paused;
        _gameTimer?.cancel();
        audio.pause();
      } else if (_state == GameState.paused) {
        _state = GameState.playing;
        _startTimer();
        audio.resume();
      }
    });
  }

  void _restart() {
    _gameTimer?.cancel(); _bonusTimer?.cancel();
    setState(() { _state = GameState.playing; _initGame(); });
    audio.play('game');
  }

  void _handleSwipe(Velocity v) {
    final dx = v.pixelsPerSecond.dx;
    final dy = v.pixelsPerSecond.dy;
    if (dx.abs() > dy.abs()) {
      _setDir(dx > 0 ? Direction.right : Direction.left);
    } else {
      _setDir(dy > 0 ? Direction.down : Direction.up);
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel(); _bonusTimer?.cancel();
    _glowCtrl.dispose(); _shakeCtrl.dispose();
    _particleCtrl.dispose(); _scorePopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: themeNotifier,
      builder: (_, theme, __) {
        final colors = GameColors.of(theme);
        return Scaffold(
          backgroundColor: colors.bg,
          body: KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            onKeyEvent: (e) {
              if (e is! KeyDownEvent) return;
              if (e.logicalKey == LogicalKeyboardKey.arrowUp)    _setDir(Direction.up);
              if (e.logicalKey == LogicalKeyboardKey.arrowDown)  _setDir(Direction.down);
              if (e.logicalKey == LogicalKeyboardKey.arrowLeft)  _setDir(Direction.left);
              if (e.logicalKey == LogicalKeyboardKey.arrowRight) _setDir(Direction.right);
              if (e.logicalKey == LogicalKeyboardKey.space)      _togglePause();
            },
            child: GestureDetector(
              onPanEnd: (d) => _handleSwipe(d.velocity),
              child: SafeArea(
                child: Column(children: [
                  _buildHUD(colors),
                  Expanded(child: _buildBoard(colors)),
                  if (_state == GameState.playing) _buildDPad(colors),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHUD(GameColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MenuScreen(colors: c))),
          child: Icon(Icons.arrow_back_ios, color: c.accent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SCORE', style: TextStyle(color: c.accent.withOpacity(0.6), fontSize: 9, letterSpacing: 2)),
          AnimatedBuilder(
            animation: _scorePopCtrl,
            builder: (_, __) => Transform.scale(
              scale: 1.0 + 0.3 * sin(_scorePopCtrl.value * pi),
              alignment: Alignment.centerLeft,
              child: Text('$_score', style: TextStyle(
                color: c.snakeHead, fontSize: 22, fontWeight: FontWeight.w800,
                shadows: [Shadow(color: c.snakeHead.withOpacity(0.5), blurRadius: 8)])),
            ),
          ),
        ])),
        _HudStat('NVL',    '$_level',    c.isDark ? kDarkYellow : kLightYellow),
        const SizedBox(width: 14),
        _HudStat('RECORD', '$_highScore', c.danger),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _togglePause,
          child: Icon(_state == GameState.paused ? Icons.play_arrow : Icons.pause,
              color: c.accent, size: 24),
        ),
      ]),
    );
  }

  Widget _buildBoard(GameColors c) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = _shakeCtrl.isAnimating
            ? sin(_shakeAnim.value * pi * 8) * 6 * (1 - _shakeAnim.value)
            : 0.0;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: LayoutBuilder(builder: (_, box) {
        final cell = min(box.maxWidth / kCols, box.maxHeight / kRows);
        return Stack(children: [
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => CustomPaint(
              painter: GamePainter(
                snake: _snake, food: _food, bonus: _bonusFood,
                particles: _particles, cell: cell, glow: _glowCtrl.value, colors: c,
              ),
              size: Size(kCols * cell, kRows * cell),
            ),
          ),
          if (_state == GameState.paused)
            _PauseOverlay(colors: c, onResume: _togglePause, onRestart: _restart),
          if (_state == GameState.gameOver)
            _GameOverOverlay(
              score: _score, high: _highScore, level: _level,
              diff: widget.difficulty, colors: c,
              onRestart: _restart,
              onMenu: () => Navigator.of(context).pushReplacement(PageRouteBuilder(
                pageBuilder: (_, __, ___) => MenuScreen(colors: c),
                transitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (_, a, __, ch) => FadeTransition(opacity: a, child: ch),
              )),
            ),
        ]);
      }),
    );
  }

  // ── D-PAD: visible uniquement pendant le jeu ──
  Widget _buildDPad(GameColors c) {
    const double s = 50.0;
    const double g = 5.0;

    Widget btn(IconData icon, Direction dir) =>
        _DPadBtn(icon: icon, onTap: () => _setDir(dir), colors: c, size: s);

    Widget empty() => SizedBox(width: s, height: s);

    Widget center() => Container(
      width: s, height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.snakeHead.withOpacity(0.08),
        border: Border.all(color: c.snakeHead.withOpacity(0.25), width: 1.5),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          empty(), const SizedBox(width: g),
          btn(Icons.keyboard_arrow_up_rounded, Direction.up),
          const SizedBox(width: g), empty(),
        ]),
        const SizedBox(height: g),
        Row(mainAxisSize: MainAxisSize.min, children: [
          btn(Icons.keyboard_arrow_left_rounded,  Direction.left),
          const SizedBox(width: g), center(), const SizedBox(width: g),
          btn(Icons.keyboard_arrow_right_rounded, Direction.right),
        ]),
        const SizedBox(height: g),
        Row(mainAxisSize: MainAxisSize.min, children: [
          empty(), const SizedBox(width: g),
          btn(Icons.keyboard_arrow_down_rounded, Direction.down),
          const SizedBox(width: g), empty(),
        ]),
      ]),
    );
  }
}

// ─────────────────────────── PAINTERS ───────────────────────────
class GamePainter extends CustomPainter {
  final List<Point> snake;
  final FoodItem? food, bonus;
  final List<Particle> particles;
  final double cell, glow;
  final GameColors colors;

  GamePainter({required this.snake, required this.food, required this.bonus,
               required this.particles, required this.cell, required this.glow,
               required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawParticles(canvas);
    if (food  != null) _drawFood(canvas, food!);
    if (bonus != null) _drawBonus(canvas, bonus!);
    _drawSnake(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final p = Paint()..color = colors.grid.withOpacity(0.8)..strokeWidth = 0.5;
    for (int x = 0; x <= kCols; x++)
      canvas.drawLine(Offset(x * cell, 0), Offset(x * cell, size.height), p);
    for (int y = 0; y <= kRows; y++)
      canvas.drawLine(Offset(0, y * cell), Offset(size.width, y * cell), p);
  }

  void _drawSnake(Canvas canvas) {
    for (int i = 0; i < snake.length; i++) {
      final pt     = snake[i];
      final t      = i / snake.length;
      final isHead = i == 0;
      final color  = isHead
          ? colors.snakeHead
          : Color.lerp(colors.snakeHead, colors.snakeTail.withOpacity(0.4), t)!;

      final rect  = Rect.fromLTWH(pt.x * cell + 1, pt.y * cell + 1, cell - 2, cell - 2);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

      if (isHead) {
        canvas.drawRRect(rRect, Paint()
          ..color = colors.snakeHead.withOpacity(0.35 + 0.2 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, colors.isDark ? 8 : 5));
      }
      canvas.drawRRect(rRect, Paint()..color = color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(rect.width * 0.28), const Radius.circular(2)),
        Paint()..color = Colors.white.withOpacity((0.2 * (1 - t)) * (colors.isDark ? 1 : 0.6)),
      );
      if (isHead) _drawEyes(canvas, pt, snake.length > 1 ? snake[1] : null);
    }
  }

  void _drawEyes(Canvas canvas, Point head, Point? neck) {
    double ex1 = 0.25, ey1 = 0.25, ex2 = 0.75, ey2 = 0.25;
    if (neck != null) {
      if (neck.x < head.x)      { ex1 = 0.75; ey1 = 0.25; ex2 = 0.75; ey2 = 0.75; }
      else if (neck.x > head.x) { ex1 = 0.25; ey1 = 0.25; ex2 = 0.25; ey2 = 0.75; }
      else if (neck.y > head.y) { ex1 = 0.25; ey1 = 0.25; ex2 = 0.75; ey2 = 0.25; }
      else                      { ex1 = 0.25; ey1 = 0.75; ex2 = 0.75; ey2 = 0.75; }
    }
    for (final (ex, ey) in [(ex1, ey1), (ex2, ey2)]) {
      final cx = head.x * cell + ex * cell;
      final cy = head.y * cell + ey * cell;
      canvas.drawCircle(Offset(cx, cy), cell * 0.12,
          Paint()..color = colors.isDark ? Colors.black : Colors.white);
      canvas.drawCircle(Offset(cx, cy), cell * 0.06, Paint()..color = colors.snakeHead);
    }
  }

  void _drawFood(Canvas canvas, FoodItem food) {
    final cx = food.pos.x * cell + cell / 2;
    final cy = food.pos.y * cell + cell / 2;
    final r  = cell * 0.35 + 0.05 * cell * glow;
    canvas.drawCircle(Offset(cx, cy), r * 1.5,
        Paint()..color = food.color.withOpacity(0.3 + 0.15 * glow)
               ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = food.color);
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.3), r * 0.25,
        Paint()..color = Colors.white.withOpacity(0.5));
  }

  void _drawBonus(Canvas canvas, FoodItem bonus) {
    final cx    = bonus.pos.x * cell + cell / 2;
    final cy    = bonus.pos.y * cell + cell / 2;
    final pulse = sin(bonus.age * pi * 4) * 0.08;
    final path  = Path();
    final outer = cell * (0.4 + pulse);
    final inner = outer * 0.4;
    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + cos(angle) * r;
      final y = cy + sin(angle) * r;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()
      ..color = bonus.color.withOpacity(0.45 + 0.3 * glow)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14));
    canvas.drawPath(path, Paint()..color = bonus.color);
    final tp = TextPainter(
      text: TextSpan(text: '+50', style: TextStyle(
          color: Colors.white, fontSize: cell * 0.38, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x * cell + cell / 2, p.y * cell + cell / 2), p.size * cell,
        Paint()..color = p.color.withOpacity((p.life / p.maxLife).clamp(0, 1))
               ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}

class BgPainter extends CustomPainter {
  final Animation<double> scan;
  final GameColors colors;
  BgPainter({required this.scan, required this.colors}) : super(repaint: scan);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = colors.bg);
    final gp = Paint()..color = colors.grid.withOpacity(0.5)..strokeWidth = 0.5;
    const sp = 28.0;
    for (double x = 0; x < size.width;  x += sp)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
    for (double y = 0; y < size.height; y += sp)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);

    final scanY = scan.value * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 40, size.width, 80),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent,
          colors.accent.withOpacity(0.04),
          colors.accent.withOpacity(colors.isDark ? 0.07 : 0.03),
          colors.accent.withOpacity(0.04),
          Colors.transparent],
      ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 80)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}

class SnakeLogoPainter extends CustomPainter {
  final Animation<double> anim;
  final Color color;
  SnakeLogoPainter({required this.anim, required this.color}) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..cubicTo(size.width * 0.2, size.height * 0.15,
                size.width * 0.8, size.height * 0.15,
                size.width * 0.8, size.height * 0.5)
      ..cubicTo(size.width * 0.8, size.height * 0.85,
                size.width * 0.2, size.height * 0.85,
                size.width * 0.35, size.height * 0.65);
    canvas.drawPath(path, Paint()
      ..color = color.withOpacity(0.3)..strokeWidth = 8..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(path, Paint()
      ..color = color.withOpacity(0.85 + 0.15 * anim.value)..strokeWidth = 4
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.65), 6,
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}

// ─────────────────────────── OVERLAYS ───────────────────────────
class _PauseOverlay extends StatelessWidget {
  final GameColors colors;
  final VoidCallback onResume, onRestart;
  const _PauseOverlay({required this.colors, required this.onResume, required this.onRestart});

  @override
  Widget build(BuildContext context) => Container(
    color: colors.bg.withOpacity(0.88),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      _GlowText('PAUSE', color: colors.accent, size: 40),
      const SizedBox(height: 32),
      _Btn(label: 'REPRENDRE',    color: colors.snakeHead, onTap: onResume),
      const SizedBox(height: 12),
      _Btn(label: 'RECOMMENCER', color: colors.isDark ? kDarkYellow : kLightYellow, onTap: onRestart),
    ])),
  );
}

class _GameOverOverlay extends StatefulWidget {
  final int score, high, level;
  final Difficulty diff;
  final GameColors colors;
  final VoidCallback onRestart, onMenu;
  const _GameOverOverlay({required this.score, required this.high, required this.level,
    required this.diff, required this.colors, required this.onRestart, required this.onMenu});
  @override State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final newRecord = widget.score > 0 && widget.score >= widget.high;
    return Container(
      color: c.bg.withOpacity(0.92),
      child: FadeTransition(
        opacity: _ctrl,
        child: ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0)
              .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('GAME OVER', style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 6, color: c.danger,
              shadows: [Shadow(color: c.danger.withOpacity(0.5), blurRadius: 20)],
            )),
            const SizedBox(height: 20),
            if (newRecord)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: c.isDark ? kDarkYellow : kLightYellow),
                  borderRadius: BorderRadius.circular(6),
                  color: (c.isDark ? kDarkYellow : kLightYellow).withOpacity(0.12),
                ),
                child: _GlowText('★  NOUVEAU RECORD  ★',
                    color: c.isDark ? kDarkYellow : kLightYellow, size: 13),
              ),
            _StatRow('SCORE',      '${widget.score}', c.snakeHead, c),
            _StatRow('MEILLEUR',   '${widget.high}',  c.danger,    c),
            _StatRow('NIVEAU',     '${widget.level}', c.accent,    c),
            _StatRow('DIFFICULTÉ', widget.diff.label, c.isDark ? kDarkYellow : kLightYellow, c),
            const SizedBox(height: 28),
            _Btn(label: 'REJOUER',    color: c.snakeHead, onTap: widget.onRestart),
            const SizedBox(height: 10),
            _Btn(label: '🏆  SCORES', color: c.isDark ? kDarkYellow : kLightYellow,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LeaderboardScreen()))),
            const SizedBox(height: 10),
            _Btn(label: 'MENU',       color: c.accent,    onTap: widget.onMenu),
          ])),
        ),
      ),
    );
  }
}

// ─────────────────────────── SMALL WIDGETS ───────────────────────────
class _GlowOrb extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  final double? top, bottom, left, right, size, opacity;
  final bool invert;
  const _GlowOrb({required this.ctrl, required this.color, this.top, this.bottom,
    this.left, this.right, required this.size, required this.opacity, this.invert = false});

  @override
  Widget build(BuildContext context) => Positioned(
    top: top, bottom: bottom, left: left, right: right,
    child: AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withOpacity((opacity ?? 0.1) * (invert ? 1 - ctrl.value : ctrl.value)),
            Colors.transparent,
          ]),
        ),
      ),
    ),
  );
}

class _HudStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _HudStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(label, style: TextStyle(color: color.withOpacity(0.6), fontSize: 9, letterSpacing: 2)),
    Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800,
        shadows: [Shadow(color: color.withOpacity(0.4), blurRadius: 8)])),
  ]);
}

class _GlowText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  const _GlowText(this.text, {required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    color: color, fontSize: size, fontWeight: FontWeight.w800, letterSpacing: 2,
    shadows: [Shadow(color: color, blurRadius: 12), Shadow(color: color, blurRadius: 24)],
  ));
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final GameColors c;
  const _StatRow(this.label, this.value, this.color, this.c);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: c.textSub, fontSize: 11, letterSpacing: 2)),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700,
          shadows: [Shadow(color: color, blurRadius: 8)])),
    ]),
  );
}

class _Btn extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.color, required this.onTap});
  @override State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => setState(() => _pressed = true),
    onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 200, height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: widget.color, width: 2),
        color: widget.color.withOpacity(_pressed ? 0.28 : 0.1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: _pressed ? 6 : 16)],
      ),
      child: Center(child: Text(widget.label, style: TextStyle(
          color: widget.color, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 3))),
    ),
  );
}

class _DPadBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final GameColors colors;
  final double size;
  const _DPadBtn({required this.icon, required this.onTap, required this.colors, this.size = 50});
  @override State<_DPadBtn> createState() => _DPadBtnState();
}

class _DPadBtnState extends State<_DPadBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final s = widget.size;
    return GestureDetector(
      onTapDown:   (_) { setState(() => _pressed = true); widget.onTap(); },
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: s, height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? c.snakeHead.withOpacity(0.25)
              : (c.isDark ? const Color(0xFF0D1530) : Colors.white),
          border: Border.all(
            color: _pressed ? c.snakeHead : c.accent.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (_pressed)
              BoxShadow(color: c.snakeHead.withOpacity(0.45), blurRadius: 14)
            else
              BoxShadow(color: Colors.black.withOpacity(c.isDark ? 0.3 : 0.1),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(widget.icon,
            color: _pressed ? c.snakeHead : c.accent.withOpacity(0.85), size: s * 0.55),
      ),
    );
  }
}
