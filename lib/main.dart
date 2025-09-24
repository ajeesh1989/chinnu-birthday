// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const GreetingCardApp());
}

class GreetingCardApp extends StatelessWidget {
  const GreetingCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Happy Birthday Chinnu 🎉",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      home: const CardPage(),
    );
  }
}

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> with TickerProviderStateMixin {
  final confettiController = ConfettiController(
    duration: const Duration(seconds: 6),
  );

  int _stage = 0; // 0 = egg, 1 = gallery, 2 = final greeting
  int _photoIndex = 0;
  int _messageIndex = 0;

  final List<String> gallery = [
    "assets/chinnu0.jpg",
    "assets/chinnu1.jpg",
    "assets/chinnu2.jpg",
    "assets/chinnu3.jpg",
    "assets/chinnu4.jpg",
  ];

  final List<String> _funMessages = [
    "🎂 Eat more cake today!",
    "🎈 You’re the star of the day!",
    "✨ Sparkle like never before!",
    "💖 Lots of hugs & love!",
    "🎉 Dance, laugh & shine!",
    "🍫 Don’t share the chocolates 😉",
  ];

  String? _surpriseMessage;
  Timer? _messageTimer;
  Timer? _galleryTimer;

  late AnimationController _eggController;
  late AnimationController _wobbleController;
  late Animation<double> _wobbleAnimation;

  // Egg breaking animation
  late AnimationController _eggCrackController;

  @override
  void initState() {
    super.initState();

    _eggController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _wobbleAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );

    // Egg cracking animation
    _eggCrackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _eggCrackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stage = 1;
        _startGalleryTimer();
        confettiController.play();
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      confettiController.play();
    });
  }

  @override
  void dispose() {
    confettiController.dispose();
    _eggController.dispose();
    _wobbleController.dispose();
    _eggCrackController.dispose();
    _messageTimer?.cancel();
    _galleryTimer?.cancel();
    super.dispose();
  }

  Path drawStar(Size size) {
    final path = Path();
    const pointCount = 5;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2;
    final angle = pi / pointCount;
    for (int i = 0; i < pointCount; i++) {
      final outerX = outerRadius * cos(2 * i * angle);
      final outerY = outerRadius * sin(2 * i * angle);
      path.lineTo(outerX, outerY);
      final innerX = innerRadius * cos(2 * i * angle + angle);
      final innerY = innerRadius * sin(2 * i * angle + angle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    return path;
  }

  void _handleTap() {
    setState(() {
      if (_stage == 0) {
        _eggCrackController.forward(from: 0.0); // play crack effect
      } else if (_stage == 1) {
        _galleryTimer?.cancel();
        _galleryTimer = null;
        _showFinalStage();
      } else if (_stage == 2) {
        _nextMessage();
      }
    });
  }

  void _nextMessage() {
    setState(() {
      _messageIndex = (_messageIndex + 1) % _funMessages.length;
      _surpriseMessage = _funMessages[_messageIndex];
      confettiController.play();
    });
  }

  void _startMessageTimer() {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _nextMessage(),
    );
  }

  void _startGalleryTimer() {
    _galleryTimer?.cancel();
    _galleryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_photoIndex < gallery.length - 1) {
        setState(() {
          _photoIndex++;
        });
      } else {
        _galleryTimer?.cancel();
        _showFinalStage();
      }
    });
  }

  void _showFinalStage() {
    _stage = 2;
    confettiController.stop(); // stop confetti in final stage
    _messageIndex = 0;
    _surpriseMessage = _funMessages[_messageIndex];
    _startMessageTimer();
    setState(() {});
  }

  Widget _buildStage() {
    if (_stage == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _wobbleAnimation,
            child: GestureDetector(
              onTap: _handleTap,
              child: ClipPath(
                clipper: EggClipper(),
                child: Image.asset(
                  "assets/chinnuu.jpg",
                  width: 300, // smaller size like before
                  height: 350, // smaller size like before
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "👆 Tap on the egg! and wait!!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black38, blurRadius: 5)],
            ),
          ),
        ],
      );
    } else if (_stage == 1) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey("gallery$_photoIndex"),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            gallery[_photoIndex],
            width: 450,
            height: 550,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // rounded corners
              child: Image.asset(
                "assets/chinnu.jpg",
                width: 460,
                height: 690,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "🎂 Happy Birthday, Chinnu 🎉",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 14,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_surpriseMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.shade300.withOpacity(0.7),
                      Colors.purple.shade300.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _surpriseMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 15),
            const Text(
              "With Love ❤️",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            // Soft background color gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB3E5FC),
                    Color(0xFFCE93D8),
                    Color(0xFFFFCCBC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Confetti only in stage 0 & 1
            if (_stage != 2)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.1,
                  numberOfParticles: 50,
                  gravity: 0.05,
                  colors: const [
                    Colors.yellow,
                    Colors.pink,
                    Colors.cyan,
                    Colors.orange,
                    Colors.greenAccent,
                    Colors.purpleAccent,
                  ],
                  createParticlePath: drawStar,
                ),
              ),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: _buildStage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EggClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.25,
      size.width,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(0, size.height, 0, size.height * 0.7);
    path.quadraticBezierTo(0, size.height * 0.25, size.width / 2, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
