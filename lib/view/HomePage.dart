import 'package:flutter/material.dart';
import 'package:e_sign/main.dart';
import 'package:e_sign/view/contractPage.dart';
import 'package:e_sign/view/employeePage.dart';
import 'package:e_sign/view/signaturePage.dart';
import 'dart:math' as math;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:e_sign/config/config.dart';
import '../model/responseModel.dart';

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

  void _signDocument() => {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignaturePage(responseModel: currentUser),
      ),
    ),
  };
  void _signContract() => {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(responseModel: currentUser),
      ),
    ),
  };
  void _logout() async {
    hapticFeedback();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFE53935),
          size: 32,
        ),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        result: (Route<dynamic> route) => false,
      );
    }
  }

  Widget _radialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double angle,
    required double radius,
  }) {
    final animation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOut,
    );
    final scale = _isMenuOpen ? 1.0 : 0.0;
    final opacity = _isMenuOpen ? 1.0 : 0.0;

    final angleRad = _degreesToRadians(angle);

    return Positioned.fill(
      child: FractionalTranslation(
        translation: Offset(
          radius * scale * math.cos(angleRad),
          -radius * scale * math.sin(angleRad),
        ),
        child: Opacity(
          opacity: opacity,
          child: ScaleTransition(
            scale: animation,
            child: GestureDetector(
              onTap: () {
                hapticFeedback();
                _toggleMenu();
                onPressed();
              },
              child: Tooltip(
                message: label,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 28, color: const Color(0xFF1565C0)),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: const Color(0xFF424242),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icon/logo.jpg',
                  fit: BoxFit.contain,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.business,
                      size: 20,
                      color: const Color(0xFF1565C0),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${currentUser.nom} ${currentUser.prenom}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFF5F7FA), Colors.white],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE3F2FD),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Text(
                        '${currentUser.prenom[0]}${currentUser.nom[0]}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bonjour, ${currentUser.prenom} !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currentUser.role} • ${currentUser.site}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF757575),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if ({'RH', 'IE', 'FM', 'HOD'}.contains(currentUser.role)) ...[
                    _buildActionCard(
                      icon: Icons.edit_document,
                      title: 'Sign requisition',
                      onTap: _signDocument,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (currentUser.role == 'RHO') ...[
                    _buildActionCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Sign contract',
                      onTap: _signContract,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (currentUser.role == 'RH') ...[
                    _buildActionCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Sign contract',
                      onTap: _signContract,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  _buildActionCard(
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    onTap: _logout,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF5350), Color(0xFFC62828)],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            right: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _menuController,
                  builder: (context, child) {
                    return Container(
                      width: 200 * _menuController.value,
                      height: 200 * _menuController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE3F2FD).withOpacity(0.4),
                      ),
                    );
                  },
                ),
                if (_isMenuOpen) ...[
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
                FloatingActionButton(
                  onPressed: () {
                    hapticFeedback();
                    _toggleMenu();
                  },
                  backgroundColor: const Color(0xFF1565C0),
                  elevation: 8,
                  tooltip: _isMenuOpen ? 'Fermer le menu' : 'Ouvrir le menu',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        RotationTransition(turns: animation, child: child),
                    child: Icon(
                      _isMenuOpen ? Icons.close : Icons.menu,
                      key: ValueKey<bool>(_isMenuOpen),
                      color: Colors.white,
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
    required Gradient gradient,
  }) {
    return Tooltip(
      message: title,
      child: Card(
        elevation: 2,
        shadowColor: const Color(0xFF1565C0).withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            hapticFeedback();
            onTap();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [Colors.white, gradient.colors.last.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF9E9E9E),
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
