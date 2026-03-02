import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';

/// Header de página web con fondo azul, título y subtítulo en blanco.
/// En móvil, devuelve vacío (se usa el AppBar nativo de cada screen).
class WebPageHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget>? actions;

  const WebPageHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [UAGRMTheme.primaryBlue, Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Ícono con fondo blanco semitransparente
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),

          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Panel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ),
                    Text(
                      ' › $title',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Título principal en blanco
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Subtítulo en blanco semitransparente
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.80),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Acciones opcionales
          if (actions != null) ...actions!,

          // Botón volver — blanco sobre azul
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 14, color: Colors.white),
            label: const Text('Volver', style: TextStyle(fontSize: 13, color: Colors.white)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white60),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenedor de contenido web centrado con fondo gris y max-width.
class WebContentArea extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const WebContentArea({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Expanded(
      child: Container(
        color: const Color(0xFFF4F6F9),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
