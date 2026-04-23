import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.uagrm.edu.bo/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/payments',
      title: 'Pagos',
      subtitle: 'Panel › Sistema de Pagos',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.credit_card_outlined,
                        size: 48,
                        color: UAGRMTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Sistema de Pagos',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: UAGRMTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para realizar pagos de matrícula, aranceles y otros cobros universitarios, será redirigido al sistema de pagos de la UAGRM.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _launchURL,
                      icon: const Icon(Icons.open_in_new, size: 20),
                      label: const Text('Ir al Sistema de Pagos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UAGRMTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
}
