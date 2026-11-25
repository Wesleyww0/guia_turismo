import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:guia_turismo/screens/cadastro_screen.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:guia_turismo/screens/mapa_screen.dart';
import 'package:guia_turismo/services/session_services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaAtual = 0;

  final List<String> _cabecalho = [
    'Guia de Turismo',
    'Cadastrar Local',
    'Lugares para Visitar',
    'Mapa GPS',
  ];

  Future _carregarDadosSessao() async {
    final session = SessionService();
    final nomeSalvo = await session.pegarNome();
    final emailSalvo = await session.pegarEmail();
    return {
      'nome': nomeSalvo,
      'email': emailSalvo,
    };
  }

  Widget _buildInicio(BuildContext context) {
    final User? usuarioFirebase = FirebaseAuth.instance.currentUser;
    final String? fotoUrl = usuarioFirebase?.photoURL;

    return FutureBuilder(
      future: _carregarDadosSessao(),
      builder: (context, snapshot) {
        final dadosSessao = snapshot.data ?? const {'nome': '', 'email': ''};

        final String nome = (usuarioFirebase?.displayName?.trim().isNotEmpty == true)
            ? usuarioFirebase!.displayName!.trim()
            : (dadosSessao['nome']!.trim().isNotEmpty
                ? dadosSessao['nome']!.trim()
                : 'Viajante');

        final String email = (usuarioFirebase?.email?.trim().isNotEmpty == true)
            ? usuarioFirebase!.email!.trim()
            : dadosSessao['email']!.trim();

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.blueGrey.shade100,
                      backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                          ? NetworkImage(fotoUrl)
                          : null,
                      child: (fotoUrl == null || fotoUrl.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 38,
                              color: Colors.blueGrey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bem-vindo ao Guia de Turismo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Logado como: $nome',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Text(
                      'Use o menu abaixo para navegar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fazerLogout() async {
    try {
      await context.read<AuthController>().deslogarUsuario();

      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      _buildInicio(context),
      const CadastroLugar(),
      const LugaresScreen(),
      const MapaScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_cabecalho[_paginaAtual]),
        centerTitle: true,
        actions: [
          Consumer<ThemeController>(
            builder: (context, controllerThema, child) => IconButton(
              onPressed: () => controllerThema.alternarTema(),
              icon: Icon(controllerThema.iconeAtual),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _fazerLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: paginas[_paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _paginaAtual = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Câmera'),
          BottomNavigationBarItem(icon: Icon(Icons.place_outlined), activeIcon: Icon(Icons.place), label: 'Locais'),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed_outlined), activeIcon: Icon(Icons.gps_fixed), label: 'Mapa'),
        ],
      ),
    );
  }
}