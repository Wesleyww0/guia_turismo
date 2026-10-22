import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  @override
  Widget build(BuildContext context) {
    // Usando o esquema de cores do tema para consistência
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<CameraController>(
        builder: (context, controleCamera, _) => Center(
          // Centraliza o conteúdo como no Login
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Padding padrão do Login
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Estica como no Login
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo_outlined,
                  size: 80,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 32),
                
                // Container da Imagem padronizado
                Material(
                  elevation: 4, // Sombra consistente com os Cards
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias, // Garante que a imagem siga a borda
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          image: exibirImagem(controleCamera),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          // Botão menor e flutuante sobre a imagem
                          backgroundColor: Colors.white,
                          elevation: 2,
                          onPressed: () => abrirModal(controleCamera, context),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Tire uma foto do local para cadastrá-lo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DecorationImage exibirImagem(CameraController controleCamera) {
  if (controleCamera.imagemSelecionada == null) {
    return const DecorationImage(
      image: NetworkImage('https://placehold.co/300x300.png?text=Sem+Imagem'),
      fit: BoxFit.cover,
    );
  } else {
    return DecorationImage(
      image: FileImage(controleCamera.imagemSelecionada!),
      fit: BoxFit.cover,
    );
  }
}

void abrirModal(CameraController controleCamera, context) {
  // Padronizando o Modal com bordas arredondadas no topo
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueGrey),
              title: const Text("Usar Câmera"),
              onTap: () {
                controleCamera.abrirCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blueGrey),
              title: const Text("Escolher da Galeria"),
              onTap: () {
                controleCamera.abrirGaleria();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}