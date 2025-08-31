import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _glowController;
  late Animation<double> _logoAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<Color?> _titleColorAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _titleScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _titleColorAnimation = ColorTween(
      begin: const Color(0xFF6C63FF),
      end: const Color(0xFF00C9A7),
    ).animate(_titleController);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _titleController,
          builder: (context, child) {
            return Transform.scale(
              scale: _titleScaleAnimation.value,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    _titleColorAnimation.value ?? const Color(0xFF6C63FF),
                    const Color(0xFF00C9A7),
                    const Color(0xFFFF4D6D),
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds),
                child: const Text(
                  'ABOUT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF6C63FF)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FF), Color(0xFFEAEAFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _logoAnimation.value),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C63FF,
                            ).withOpacity(_glowAnimation.value * 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: const Color(
                              0xFF00C9A7,
                            ).withOpacity(_glowAnimation.value * 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.7),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _titleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _titleScaleAnimation.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          _titleColorAnimation.value ?? const Color(0xFF6C63FF),
                          const Color(0xFF00C9A7),
                          const Color(0xFFFF4D6D),
                        ],
                        tileMode: TileMode.mirror,
                      ).createShader(bounds),
                      child: const Text(
                        'NEXZO VPN',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(
                              color: Color(0xFF6C63FF),
                              blurRadius: 15,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              color: Color(0xFF00C9A7),
                              blurRadius: 15,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Version 2.7.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Fast, Unlimited, Safe and Free',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Text(
                'Developed by',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.15),
                      const Color(0xFF00C9A7).withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Ehsan Fazli for NEXZO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF6C63FF,
                          ).withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color(
                            0xFF00C9A7,
                          ).withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'NEXZO VPN is a powerful Flutter application designed to provide secure, private internet access through V2Ray VPN technology and Telegram MTProto proxies. With a clean light-themed interface and comprehensive features, NEXZO VPN puts you in control of your online privacy without any subscription fees or hidden costs.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildGamingButton(
                    icon: Icons.telegram,
                    label: 'Telegram Channel',
                    color: const Color(0xFF0088cc),
                    onPressed: () {
                      _launchUrl('https://t.me/irdevs_dns');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGamingButton(
                    icon: Icons.code,
                    label: 'GitHub Source',
                    color: Colors.deepPurple,
                    onPressed: () {
                      _launchUrl('https://github.com/tsshack/NEXZO-VPN');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGamingButton(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    color: Colors.teal,
                    onPressed: () {
                      _launchUrl(
                        'https://github.com/tsshack/NEXZO-VPN/blob/master/PRIVACY.md',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGamingButton(
                    icon: Icons.gavel_outlined,
                    label: 'Terms of Service',
                    color: Colors.pinkAccent,
                    onPressed: () {
                      _launchUrl(
                        'https://github.com/tsshack/NEXZO-VPN/blob/master/TERMS.md',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '© 2025 NEXZO VPN',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6C63FF).withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              splashColor: color.withOpacity(0.2),
              highlightColor: color.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
