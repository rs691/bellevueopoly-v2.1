import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/glassmorphic_card.dart';
import '../providers/firestore_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/responsive_form_container.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Initialize particles
    _initializeParticles();
  }

  void _initializeParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(
        _Particle(
          color: _getRandomColor(),
          size: math.Random().nextDouble() * 20 + 10,
          offsetX: math.Random().nextDouble(),
          offsetY: math.Random().nextDouble(),
          speed: math.Random().nextDouble() * 0.5 + 0.3,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.pinkAccent.withValues(alpha: 0.4),
      Colors.purpleAccent.withValues(alpha: 0.4),
      Colors.orangeAccent.withValues(alpha: 0.4),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      if (userCredential.user != null) {
        // Add user to Firestore
        await ref
            .read(firestoreServiceProvider)
            .addUser(user: userCredential.user!, username: _username);

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        if (mounted) {
          // Navigate to email verification screen
          context.go('/email-verification', extra: _email);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final authService = ref.read(authServiceProvider);
        IconData icon = Icons.error_outline;
        String message;
        bool showRetry = false;

        if (e.code == 'network-request-failed') {
          icon = Icons.wifi_off;
          message = 'Network error. Please check your internet connection.';
          showRetry = true;
        } else {
          message = authService.getErrorMessage(e);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: showRetry ? 4 : 3),
            action: showRetry
                ? SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: _trySubmit,
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'An unexpected error occurred. Please try again.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _trySubmit,
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Animated background particles
            ..._buildParticles(),

            // Main content
            SafeArea(
              child: ResponsiveFormContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Join the adventure!',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 40),

                      // Registration Form
                      GlassmorphicCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _username = value ?? '';
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || !value.contains('@')) {
                                      return 'Please enter a valid email.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _email = value ?? '';
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters long.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _password = value ?? '';
                                  },
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _trySubmit,
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : const Text('Create Account'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Link to login
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          "Already have an account? Log in",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(15, (index) {
      final particle = _particles[index];
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final animValue =
              (_particleController.value + particle.offsetY) % 1.0;

          return Positioned(
            left: MediaQuery.of(context).size.width * particle.offsetX,
            top: screenHeight * animValue - particle.size,
            child: Opacity(
              opacity: (math.sin(animValue * math.pi) * 0.6).clamp(0.0, 0.6),
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _Particle {
  final Color color;
  final double size;
  final double offsetX;
  final double offsetY;
  final double speed;

  _Particle({
    required this.color,
    required this.size,
    required this.offsetX,
    required this.offsetY,
    required this.speed,
  });
}
