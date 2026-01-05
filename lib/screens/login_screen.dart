import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/glassmorphic_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/responsive_form_container.dart';
import '../services/firestore_service.dart'; // Import your service

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Re-usable FirestoreService instance
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower, more ambient animation
    )..repeat();
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
          speed: math.Random().nextDouble() * 0.1 + 0.05, // Slower speed
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
    if (isValid != true) return;
    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user != null) {
        // Check if email is verified
        if (!userCredential.user!.emailVerified) {
          if (mounted) {
            _showError('Please verify your email before logging in.');
            // Optionally redirect to verification screen
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              context.go('/email-verification', extra: _email);
            }
          }
        } else {
          if (mounted) context.go('/');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed.');
    } catch (e) {
      _showError('An unexpected error occurred.');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
        final user = userCredential.user;

        if (user != null &&
            userCredential.additionalUserInfo?.isNewUser == true) {
          await _firestoreService.addUser(
            user: user,
            username:
                user.displayName ?? user.email?.split('@')[0] ?? 'New Player',
          );
        }

        if (mounted) context.go('/');
      } else {
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        final user = userCredential.user;

        if (user != null &&
            userCredential.additionalUserInfo?.isNewUser == true) {
          await _firestoreService.addUser(
            user: user,
            username:
                user.displayName ?? user.email?.split('@')[0] ?? 'New Player',
          );
        }

        if (mounted) context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google Sign-In failed.');
    } catch (e) {
      _showError('An unexpected error occurred during Google Sign-In.');
    }

    if (mounted) setState(() => _isGoogleLoading = false);
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);

    try {
      // Use the newly added method in AuthService (or direct auth for now if not available via provider here)
      // Since we are inside a widget, we can use FirebaseAuth directly or Ref if we convert to ConsumerWidget fully
      // But let's stick to the pattern used in _signInWithGoogle which uses FirebaseAuth.instance directly
      // EXCEPT I just added it to AuthService, so let's try to use that if possible, OR just duplicate the logic
      // to match the existing style of this file which overrides the service pattern a bit.
      // To be safe and consistent with _signInWithGoogle in this file:
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestoreService.addUser(
          user: user,
          username: 'Guest Player', // Default name for anonymous
        );
      }

      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Bypass failed.');
    } catch (e) {
      _showError('An unexpected error occurred during bypass.');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Helper to reduce code duplication for showing errors
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ..._buildParticles(),
            SafeArea(
              child: ResponsiveFormContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Log in to continue your adventure',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 40),
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
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      (value == null || !value.contains('@'))
                                      ? 'Please enter a valid email.'
                                      : null,
                                  onSaved: (value) => _email = value ?? '',
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (value) =>
                                      (value == null || value.length < 6)
                                      ? 'Password must be at least 6 characters long.'
                                      : null,
                                  onSaved: (value) => _password = value ?? '',
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => context.go('/password-reset'),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading || _isGoogleLoading
                                        ? null
                                        : _trySubmit,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text('Login'),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const _OrDivider(),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: _isGoogleLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : OutlinedButton.icon(
                                          icon: Image.asset(
                                            'assets/images/google_logo.png', // Make sure you have this asset
                                            height: 24.0,
                                          ),
                                          label: const Text(
                                            'Sign in with Google',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.white.withValues(alpha: 
                                                0.5,
                                              ),
                                            ),
                                          ),
                                          onPressed:
                                              _isLoading || _isGoogleLoading
                                              ? null
                                              : _signInWithGoogle,

                                        ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: TextButton(
                                    onPressed:
                                        _isLoading || _isGoogleLoading
                                            ? null
                                            : _signInAnonymously,
                                    child: const Text(
                                      'Developer Bypass (Guest)',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(
                          "Don't have an account? Sign up",
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
    // Extracted for cleanliness
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final animValue =
              (_particleController.value * particle.speed + particle.offsetY) %
              1.0;
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
    }).toList();
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

// Extracted the 'OR' divider into its own stateless widget for performance and readability
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

