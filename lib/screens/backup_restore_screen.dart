import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _statusMessage;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

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
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptions = prefs.getStringList('v2ray_subscriptions') ?? [];
      final configs = prefs.getStringList('v2ray_configs') ?? [];
      final blockedApps = prefs.getStringList('blocked_apps') ?? [];
      final data = {
        'subscriptions': subscriptions,
        'configs': configs,
        'blocked_apps': blockedApps,
      };
      final jsonString = jsonEncode(data);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'settings-pc-$timestamp.json';
      // Get the Downloads directory
      Directory? downloadsDir;
      try {
        downloadsDir = Directory('/storage/emulated/0/Download');
        // Check if the directory exists, create it if it doesn't
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      } catch (e) {
        // Fallback to temporary directory if Downloads is inaccessible
        downloadsDir = await getTemporaryDirectory();
      }
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(jsonString);
      setState(() {
        _statusMessage = 'Backup saved to Downloads/$fileName';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) {
        setState(() {
          _statusMessage = 'No file selected';
        });
        return;
      }
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'v2ray_subscriptions',
        List<String>.from(data['subscriptions'] ?? []),
      );
      await prefs.setStringList(
        'v2ray_configs',
        List<String>.from(data['configs'] ?? []),
      );
      await prefs.setStringList(
        'blocked_apps',
        List<String>.from(data['blocked_apps'] ?? []),
      );
      setState(() {
        _statusMessage =
            'Data imported successfully. Please restart the app to show data.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error importing data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _glowController,
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
                'BACKUP & RESTORE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A2A), Color(0xFF0F0F1E), Color(0xFF0A0A2A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Backup Card
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: _buildGamingCard(
                      title: 'BACKUP DATA',
                      description:
                          'Export your subscriptions, local servers, and blocked apps to a JSON file.',
                      buttonText: 'EXPORT NOW',
                      onPressed: _isLoading ? null : _exportData,
                      icon: Icons.cloud_upload,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Restore Card
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: _buildGamingCard(
                      title: 'RESTORE DATA',
                      description:
                          'Import subscriptions, local servers, and blocked apps from a JSON file.',
                      buttonText: 'IMPORT NOW',
                      onPressed: _isLoading ? null : _importData,
                      icon: Icons.cloud_download,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Status Message
              if (_statusMessage != null)
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _statusMessage!.contains('Error')
                              ? Colors.red.withOpacity(_glowAnimation.value)
                              : Colors.cyan.withOpacity(_glowAnimation.value),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _statusMessage!.contains('Error')
                                ? Colors.red.withOpacity(
                                    _glowAnimation.value * 0.3,
                                  )
                                : Colors.cyan.withOpacity(
                                    _glowAnimation.value * 0.3,
                                  ),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusMessage!.contains('Error')
                              ? Colors.red
                              : Colors.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamingCard({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.purple.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.cyan,
                      size: 28,
                      shadows: [
                        const Shadow(color: Colors.cyan, blurRadius: 10),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [Shadow(color: Colors.cyan, blurRadius: 10)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildGamingButton(
                  text: buttonText,
                  onPressed: onPressed,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGamingButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(_glowAnimation.value * 0.5),
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
              splashColor: Colors.cyan.withOpacity(0.3),
              highlightColor: Colors.purple.withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          text,
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
    );
  }
}
