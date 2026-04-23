import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/graphql_service.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/theme_provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/login_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/career_selection_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/main_panel_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/enabled_subjects_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/enrollment_slip_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/blocked_status_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/enrollment_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/enrollment_dates_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/academic_calendar_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/transactions_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/offers_screen.dart';
import 'package:inscripcion_frontend/modules/inscripcion/pages/payments_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  
  // Configurar barra de estado para que sea legible
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Barra transparente
      statusBarIconBrightness: Brightness.dark, // Iconos oscuros (para fondo claro)
      statusBarBrightness: Brightness.light, // Para iOS
    ),
  );
  
  runApp(const UAGRMApp());
}

class UAGRMApp extends StatelessWidget {
  const UAGRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = GraphQLService.initClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: GraphQLProvider(
        client: client,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => MaterialApp(
            title: 'UAGRM Inscripción',
            debugShowCheckedModeBanner: false,
            theme: UAGRMTheme.themeData,
            darkTheme: UAGRMTheme.darkThemeData,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/': page = const LoginScreen(); break;
                case '/career': page = const CareerSelectionScreen(); break;
                case '/panel': page = const MainPanelScreen(); break;
                case '/enabled-subjects': page = const EnabledSubjectsScreen(); break;
                case '/enrollment-slip': page = const EnrollmentSlipScreen(); break;
                case '/blocked-status': page = const BlockedStatusScreen(); break;
                case '/enrollment': page = const EnrollmentScreen(); break;
                case '/enrollment-dates': page = const EnrollmentDatesScreen(); break;
                case '/calendar': page = const AcademicCalendarScreen(); break;
                case '/transactions': page = const TransactionsScreen(); break;
                case '/offers': page = const OffersScreen(); break;
                case '/payments': page = const PaymentsScreen(); break;
                default: page = const LoginScreen();
              }

              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 150),
              );
            },
          ),
        ),
      ),
    );
  }
}
