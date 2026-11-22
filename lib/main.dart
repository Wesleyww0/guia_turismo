import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/controller/mapa_controller.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:guia_turismo/firebase_options.dart';
//import 'package:guia_turismo/inicializar.dart';
import 'package:guia_turismo/screens/cadastro_screen.dart';
import 'package:guia_turismo/screens/home_screen.dart';
import 'package:guia_turismo/screens/login_screen.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:guia_turismo/screens/mapa_screen.dart';
import 'package:provider/provider.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 
  runApp(const inicializar());
}

class inicializar extends StatefulWidget {
  const inicializar({super.key});

  @override
  State<inicializar> createState() => _inicializarState();
}

class _inicializarState extends State<inicializar> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LugaresController()),
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(create: (_) => CameraController()),
      ChangeNotifierProvider(create: (_) => MapaController()),
    ],
    child: Consumer<ThemeController>(
      builder: (context, controllerThema, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: controllerThema.temaClaro(),
        darkTheme: controllerThema.temaEscuro(),
        themeMode: controllerThema.temaAtual,
        initialRoute: 'login',
        routes: {
          'login': (context) => TelaLogin(),
          'home': (context) => HomeScreen(),
          'lugares': (context) => LugaresScreen(),
          'cadastro': (context) => CadastroLugar(),
          'mapa': (context) => MapaScreen()
        },
      ),
    ),
    );
  }
}