import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:guia_turismo/screens/cadastro_screen.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaAtual = 0;

  final List<Widget> _paginas = [
    const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "Bem-vindo ao Guia de Turismo!\nUse o menu abaixo para navegar.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    ),
    const CadastroLugar(),
    const LugaresScreen(),
  ];

  final List<String> _cabecalho = [
    'Guia de Turismo',
    'Cadastrar Local', // Texto mais claro
    'Lugares para Visitar'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cabecalho[_paginaAtual]),
        centerTitle: true, // Centralizado como no Login
        actions: [
          Consumer<ThemeController>(
            builder: (context, controllerThema, child) => IconButton(
              onPressed: () => controllerThema.alternarTema(),
              icon: Icon(controllerThema.iconeAtual),
            ),
          ),
        ],
      ),
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        // Usando cores do tema para padronização
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor, 
        elevation: 8,
        type: BottomNavigationBarType.fixed, // Evita animações que mudam a cor de fundo
        onTap: (index) => setState(() => _paginaAtual = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Câmera'),
          BottomNavigationBarItem(icon: Icon(Icons.place_outlined), activeIcon: Icon(Icons.place), label: 'Locais')
        ],
      ),
    );
  }
}