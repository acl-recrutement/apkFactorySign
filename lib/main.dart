import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/model/userModel.dart';
import 'package:myapp/view/HomePage.dart';
import 'controller/authController.dart';

void hapticFeedback() {
  HapticFeedback.lightImpact();
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AQUARELLE MADAGASCAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF42A5F5),
          surface: Colors.white,
          background: const Color(0xFFF5F7FA),
          error: const Color(0xFFE53935),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF1A1A2E),
          onBackground: const Color(0xFF1A1A2E),
          onError: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: Color(0xFF757575)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: const Color(0xFF1565C0).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: const TextStyle(fontSize: 14),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icon/logo.jpg',
                        fit: BoxFit.contain,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            size: 70,
                            color: const Color(0xFF1565C0),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'AQUARELLE',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'MADAGASCAR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String username = _usernameController.text.trim();
        String password = _passwordController.text.trim();
        final authController = Authcontroller();
        final userModel = Usermodel(identifier: username, password: password);
        final resposne = await authController.LoginUser(userModel);
        if (resposne.result == true) {
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Connexion réussie !'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  Homepage(responseModel: resposne),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Matricule ou mot de passe incorrect !'),
              backgroundColor: const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE8EAF6),
              Color(0xFFF5F7FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                'assets/icon/logo.jpg',
                                fit: BoxFit.contain,
                                width: 70,
                                height: 70,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.business,
                                    size: 44,
                                    color: const Color(0xFF1565C0),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'AQUARELLE MADAGASCAR',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1565C0),
                                  letterSpacing: 1.2,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bienvenue ! Connectez-vous à votre compte',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF757575)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Matricule',
                              hintText: 'AMAT4563',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return 'Veuillez entrer votre matricule';
                              }
                              final isMatricule =
                                  RegExp(r'^(AMAT|AMAA|LMAA)\d+$', caseSensitive: false)
                                      .hasMatch(input);
                              final isEmail =
                                  RegExp(r'^\S+@\S+\.\S+$').hasMatch(input);
                              if (!isMatricule && !isEmail) {
                                return 'Matricule invalide (ex: AMAT4563)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Fonctionnalité à venir',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: const Color(0xFFE0E0E0),
                                  thickness: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OU',
                                  style: TextStyle(color: Color(0xFF9E9E9E)),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: const Color(0xFFE0E0E0),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Connexion avec SIGN PAD HR'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.business),
                            label: const Text('SIGN PAD HR'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Contactez le support IT',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Besoin d\'aide ?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
