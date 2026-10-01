import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

          // Seccion Creditos & Atribucion
          _buildSectionHeader('CRÉDITOS & ATRIBUCIÓN'),
          _buildCard([
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA8B545).withValues(alpha: 0.16),
                ),
                child: const Icon(Icons.code_rounded, color: Color(0xFFA8B545), size: 20),
              ),
              title: const Text('Creado por Doker', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Código abierto y uso libre con atribución. Toca para ver detalles.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
              onTap: () => _showCreditsModal(context),
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
              subtitle: Text('Código libre • Atribución a Doker • MIT License', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              onTap: () => _showCreditsModal(context),
            ),
          ]),
        ],
      ),
    );
  }

  void _showCreditsModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131418),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA8B545).withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/distopia_logo_transparent.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'DYSTOPIA MUSIC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFA8B545).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA8B545).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Creado por Doker (@Doker367)',
                  style: TextStyle(
                    color: Color(0xFFA8B545),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1C22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.favorite_rounded, color: Color(0xFFA8B545), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Uso Libre para Todos:\nPuedes utilizar este reproductor y su código fuente libremente para proyectos personales, educativos o de aprendizaje.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bookmark_added_rounded, color: Color(0xFFA8B545), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Atribución y Referencia:\nSi tomas código, arquitectura, widgets o diseño como base o referencia, te pedimos dar la mención correspondiente a Doker y enlazar al repositorio oficial.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'https://github.com/Doker367/dystopia-music',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8B545),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
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
