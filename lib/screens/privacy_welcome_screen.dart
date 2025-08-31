import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class PrivacyWelcomeScreen extends StatefulWidget {
  const PrivacyWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyWelcomeScreen> createState() => _PrivacyWelcomeScreenState();
}

class _PrivacyWelcomeScreenState extends State<PrivacyWelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;
  bool _acceptedPrivacy = false;

  // Animation controllers
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // If on privacy page and checkbox not checked, don't proceed
    if (_currentPage == 1 && !_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the privacy policy to continue'),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _savePreferenceAndNavigate();
    }
  }

  void _savePreferenceAndNavigate() async {
    if (_acceptedPrivacy) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('privacy_accepted', true);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } else {
      // Show warning dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Dialog(
                backgroundColor: Colors.black.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.cyan.withOpacity(_glowAnimation.value),
                    width: 1.5,
                  ),
                ),
                insetPadding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(
                          _glowAnimation.value * 0.3,
                        ),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.purple.withOpacity(
                          _glowAnimation.value * 0.3,
                        ),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.cyan.withOpacity(_glowAnimation.value),
                                  Colors.purple.withOpacity(
                                    _glowAnimation.value,
                                  ),
                                ],
                                tileMode: TileMode.mirror,
                              ).createShader(bounds),
                              child: const Text(
                                'Privacy Policy Not Accepted',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'You have not accepted the privacy policy. You can continue to use the app, but you will not receive support or help. Do you want to proceed?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGamingButton(
                              text: 'Cancel',
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              color: Colors.grey,
                            ),
                            _buildGamingButton(
                              text: 'Proceed Anyway',
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('privacy_accepted', true);
                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MainNavigationScreen(),
                                    ),
                                  );
                                }
                              },
                              color: Colors.cyan,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildGamingButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onPressed,
              splashColor: color.withOpacity(0.3),
              highlightColor: color.withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A2A), Color(0xFF0F0F1E), Color(0xFF0A0A2A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return TextButton(
                              onPressed: _savePreferenceAndNavigate,
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.cyan.withOpacity(
                                    _glowAnimation.value,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        _buildWelcomePage(),
                        _buildPrivacyPage(),
                        _buildNoLimitsPage(),
                        _buildFreeToUsePage(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page indicators
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _totalPages,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: _currentPage == index ? 24 : 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: _currentPage == index
                                        ? Colors.cyan.withOpacity(
                                            _glowAnimation.value,
                                          )
                                        : Colors.grey.withOpacity(0.5),
                                    boxShadow: _currentPage == index
                                        ? [
                                            BoxShadow(
                                              color: Colors.cyan.withOpacity(
                                                _glowAnimation.value * 0.5,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Next button
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(
                                      _glowAnimation.value * 0.5,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _currentPage == 1 && !_acceptedPrivacy
                                      ? null
                                      : _nextPage,
                                  splashColor: Colors.cyan.withOpacity(0.3),
                                  highlightColor: Colors.purple.withOpacity(
                                    0.2,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.cyan.withOpacity(0.8),
                                          Colors.purple.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _currentPage == _totalPages - 1
                                            ? 'Get Started'
                                            : 'Next',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(_glowAnimation.value),
                              Colors.purple.withOpacity(_glowAnimation.value),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.security,
                          size: 70,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.cyan.withOpacity(_glowAnimation.value),
                      Colors.purple.withOpacity(_glowAnimation.value),
                    ],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
                  child: const Text(
                    'Welcome to NEXZO VPN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'NEXZO VPN',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(_glowAnimation.value),
                              Colors.purple.withOpacity(_glowAnimation.value),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.privacy_tip,
                          size: 70,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.cyan.withOpacity(_glowAnimation.value),
                      Colors.purple.withOpacity(_glowAnimation.value),
                    ],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
                  child: const Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'We don\'t track, store, or share your data. Your online activity remains private and secure.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGamingCheckbox(
                  value: _acceptedPrivacy,
                  onChanged: (value) {
                    setState(() {
                      _acceptedPrivacy = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'I accept the ',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      InkWell(
                        onTap: () async {
                          // Open privacy policy link
                          final Uri url = Uri.parse(
                            'https://github.com/tsshack/NEXZO-VPN/blob/master/PRIVACY.md',
                          );
                          try {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Could not open Privacy Policy',
                                  ),
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Text(
                              'privacy policy',
                              style: TextStyle(
                                color: Colors.cyan.withOpacity(
                                  _glowAnimation.value,
                                ),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ),
                      const Text(
                        ' and ',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      InkWell(
                        onTap: () async {
                          // Open terms of service link
                          final Uri url = Uri.parse(
                            'https://github.com/tsshack/NEXZO-VPN/blob/master/TERMS.md',
                          );
                          try {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Could not open Terms of Service',
                                  ),
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Text(
                              'terms of service',
                              style: TextStyle(
                                color: Colors.cyan.withOpacity(
                                  _glowAnimation.value,
                                ),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamingCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: value
                  ? LinearGradient(
                      colors: [
                        Colors.cyan.withOpacity(_glowAnimation.value),
                        Colors.purple.withOpacity(_glowAnimation.value),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: value
                    ? Colors.cyan.withOpacity(_glowAnimation.value)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(
                          _glowAnimation.value * 0.5,
                        ),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: value
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildNoLimitsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(_glowAnimation.value),
                              Colors.purple.withOpacity(_glowAnimation.value),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(Icons.speed, size: 70, color: Colors.white),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.cyan.withOpacity(_glowAnimation.value),
                      Colors.purple.withOpacity(_glowAnimation.value),
                    ],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
                  child: const Text(
                    'PowerFull VPN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'NEXZO VPN is PowerFull',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeToUsePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(_glowAnimation.value),
                              Colors.purple.withOpacity(_glowAnimation.value),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(
                                _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          size: 70,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.cyan.withOpacity(_glowAnimation.value),
                      Colors.purple.withOpacity(_glowAnimation.value),
                    ],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
                  child: const Text(
                    'VIP VPN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'IS VIP NEXZO VPN',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
