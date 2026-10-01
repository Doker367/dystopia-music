import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/core/services/local_stream_server.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _downloadOnlyWifi;
  late bool _crossfade;
  late String _audioQuality;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    _downloadOnlyWifi = box.get('downloadOnlyWifi', defaultValue: true);
    _crossfade = box.get('crossfade', defaultValue: true);
    _audioQuality = box.get('audioQuality', defaultValue: 'Alta (320 kbps)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'AJUSTES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 140),
        children: [
          // App Branding Card with Distopia Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1F1A), Color(0xFF131418)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFFA8B545).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA8B545).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA8B545).withValues(alpha: 0.25),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/distopia_logo_transparent.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DYSTOPIA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cyberpunk Audio Player v1.0.0',
                        style: TextStyle(
                          color: const Color(0xFFA8B545).withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Motor de Audio Nativo Offline-First',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seccion Reproduccion
          _buildSectionHeader('REPRODUCCIÓN & AUDIO'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.high_quality_rounded, color: Color(0xFFA8B545)),
              title: const Text('Calidad de Audio', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(_audioQuality, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              trailing: DropdownButton<String>(
                dropdownColor: const Color(0xFF1E1E24),
                underline: const SizedBox.shrink(),
                value: _audioQuality,
                items: ['Estándar (128 kbps)', 'Alta (320 kbps)', 'Lossless FLAC']
                    .map((q) => DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(color: Colors.white, fontSize: 12))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _audioQuality = val);
                    Hive.box('settings').put('audioQuality', val);
                    LocalStreamServer.clearMetaCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calidad de audio actualizada: $val'),
                        backgroundColor: const Color(0xFF1E1E24),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            SwitchListTile(
              activeTrackColor: const Color(0xFFA8B545),
              secondary: const Icon(Icons.graphic_eq_rounded, color: Color(0xFFA8B545)),
              title: const Text('Crossfade Automático', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Transiciones suaves entre canciones', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              value: _crossfade,
              onChanged: (val) {
                setState(() => _crossfade = val);
                Hive.box('settings').put('crossfade', val);
              },
            ),
          ]),

          const SizedBox(height: 20),

          // Seccion Descargas
          _buildSectionHeader('DESCARGAS & ALMACENAMIENTO'),
          _buildCard([
            SwitchListTile(
              activeTrackColor: const Color(0xFFA8B545),
              secondary: const Icon(Icons.wifi_rounded, color: Color(0xFFA8B545)),
              title: const Text('Descargar solo con Wi-Fi', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Evitar consumo de datos móviles', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              value: _downloadOnlyWifi,
              onChanged: (val) {
                setState(() => _downloadOnlyWifi = val);
                Hive.box('settings').put('downloadOnlyWifi', val);
              },
            ),
            const Divider(color: Colors.white10, height: 1),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded, color: Color(0xFFA8B545)),
              title: const Text('Ubicación de Descargas', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('/Dystopia/Music', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ),
          ]),

          const SizedBox(height: 20),

          // Seccion Informacion
          _buildSectionHeader('SISTEMA & LICENCIA'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Color(0xFFA8B545)),
              title: const Text('Versión del Núcleo', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Dystopia v1.0.0+1 (Impeller Vulkan)', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ),
            const Divider(color: Colors.white10, height: 1),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: Color(0xFFA8B545)),
              title: const Text('Licencia y Privacidad', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Reproducción legal 100% Offline-First', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }
}
