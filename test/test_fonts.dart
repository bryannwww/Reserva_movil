import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las tipografías reales del proyecto en las pruebas de maquetación.
/// Sin esto Flutter usa la fuente Ahem, cuyos glifos son cuadrados y provocan
/// desbordamientos que no ocurren en el navegador.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final body = FontLoader('Manrope')
    ..addFont(rootBundle.load('assets/fonts/Manrope-Light.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Manrope-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Manrope-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Manrope-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Manrope-Bold.ttf'));
  await body.load();

  final display = FontLoader('CormorantGaramond')
    ..addFont(rootBundle.load('assets/fonts/CormorantGaramond-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/CormorantGaramond-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/CormorantGaramond-Bold.ttf'));
  await display.load();
}
