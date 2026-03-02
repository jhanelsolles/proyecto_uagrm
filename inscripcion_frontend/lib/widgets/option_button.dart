import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isAvailable;
  final bool hasBadge;
  final String? badgeText;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.icon,
    required this.title,
    this.isAvailable = true,
    this.hasBadge = false,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = kIsWeb ? 28.0 : 28.0;
    final containerSize = kIsWeb ? 44.0 : 56.0;
    final fontSize = kIsWeb ? 12.0 : 13.0;

    return Material(
      color: Colors.white,
      elevation: isAvailable ? (kIsWeb ? 1 : 2) : 0,
      borderRadius: BorderRadius.circular(kIsWeb ? 8 : 12),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(kIsWeb ? 8 : 12),
        hoverColor: kIsWeb ? UAGRMTheme.primaryBlue.withOpacity(0.04) : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kIsWeb ? 8 : 12),
            border: Border.all(
              color: isAvailable
                  ? (kIsWeb ? Colors.grey.shade200 : Colors.transparent)
                  : Colors.grey.shade300,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: containerSize,
                      height: containerSize,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? UAGRMTheme.primaryBlue.withOpacity(kIsWeb ? 0.08 : 0.1)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isAvailable ? UAGRMTheme.primaryBlue : Colors.grey,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(height: kIsWeb ? 8 : 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 6 : 8),
                      child: Text(
                        isAvailable ? title : 'No disponible',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? UAGRMTheme.textDark : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBadge && isAvailable)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: UAGRMTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeText ?? '!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
