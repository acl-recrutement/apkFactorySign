import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/view/contractPage.dart';
import 'package:myapp/view/employeePage.dart';
import 'package:myapp/view/signaturePage.dart';
import 'dart:math' as math; // 🔑 indispensable pour sin/cos/pi
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:myapp/config/config.dart';
import '../model/responseModel.dart';

// Helper optionnel (mais propre) pour lisibilité
double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;

class Homepage extends StatefulWidget {
  final ResponseModel responseModel;
  const Homepage({Key? key, required this.responseModel}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Homepage> with TickerProviderStateMixin {
  late ResponseModel currentUser;
  late AnimationController _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.responseModel;
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  final socket = IO
      .io(
        apiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      )
      .connect();

  void _viewEmployees() => {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeePage(responseModel: currentUser),
      ),
    ),
  };
  void _signDocument() => {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignaturePage(responseModel: currentUser),
      ),
    ),
  };
  void _signContract() => {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(responseModel: currentUser),
      ),
    ),
  };
  void _logout() => {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      result: (Route<dynamic> route) => false,
    ),
  };

  Widget _radialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double angle, // en degrés (ex: 30, 150, 270)
    required double radius,
  }) {
    final animation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOut,
    );
    final scale = _isMenuOpen ? 1.0 : 0.0;
    final opacity = _isMenuOpen ? 1.0 : 0.0;

    // 🔁 Conversion degrés → radians — ✅ Dart compatible
    final angleRad = _degreesToRadians(angle);

    return Positioned.fill(
      child: FractionalTranslation(
        translation: Offset(
          radius * scale * math.cos(angleRad),
          -radius * scale * math.sin(angleRad), // négatif = vers le haut
        ),
        child: Opacity(
          opacity: opacity,
          child: ScaleTransition(
            scale: animation,
            child: GestureDetector(
              onTap: () {
                _toggleMenu();
                onPressed();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 28, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            '${currentUser.nom} ${currentUser.prenom}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Stack(
        children: [
          // Fond dégradé subtil
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  Theme.of(context).colorScheme.background,
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bonjour, ${currentUser.prenom} !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Boutons classiques (fallback UX)
                  _buildActionCard(
                    icon: Icons.group_outlined,
                    title: 'Voir la liste des employés',
                    onTap: _viewEmployees,
                  ),
                  const SizedBox(height: 16),
                  // ignore: unrelated_type_equality_checks
                  if ({'RH', 'IE', 'FM', 'HOD'}.contains(currentUser.role)) ...[
                    _buildActionCard(
                      icon: Icons.edit,
                      title: 'Sign requisition',
                      onTap: _signDocument,
                      color: Colors.blue,
                    ),
                  ],
                  if (currentUser.role == 'RHO') ...[
                    _buildActionCard(
                      icon: Icons.edit_document,
                      title: 'Sign contract',
                      onTap: _signContract,
                      color: Colors.blue,
                    ),
                  ],
                  if (currentUser.role == 'RH') ...[
                    _buildActionCard(
                      icon: Icons.edit_document,
                      title: 'Sign contract',
                      onTap: _signContract,
                      color: Colors.blue,
                    ),
                  ],
                  _buildActionCard(
                    icon: Icons.logout,
                    title: 'Déconnexion',
                    onTap: _logout,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // ✨ Floating Radial Menu (le "wow")
          Positioned(
            bottom: 32,
            right: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Disque de fond du menu ouvert
                AnimatedBuilder(
                  animation: _menuController,
                  builder: (context, child) {
                    return Container(
                      width: 200 * _menuController.value,
                      height: 200 * _menuController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100.withOpacity(0.6),
                      ),
                    );
                  },
                ),

                // Boutons radiaux (seulement si ouvert)
                if (_isMenuOpen) ...[
                  _radialButton(
                    icon: Icons.group,
                    label: 'Employés',
                    onPressed: _viewEmployees,
                    angle: 30,
                    radius: 100,
                  ),

                  _radialButton(
                    icon: Icons.edit,
                    label: 'Signer',
                    onPressed: _signDocument,
                    angle: 150,
                    radius: 100,
                  ),

                  _radialButton(
                    icon: Icons.logout,
                    label: 'Quitter',
                    onPressed: _logout,
                    angle: 270,
                    radius: 100,
                  ),
                ],

                // FAB central
                FloatingActionButton(
                  onPressed: _toggleMenu,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 8,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        RotationTransition(turns: animation, child: child),
                    child: Icon(
                      _isMenuOpen ? Icons.close : Icons.menu,
                      key: ValueKey<bool>(_isMenuOpen),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: effectiveColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
