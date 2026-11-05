import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:guia_turismo/services/buscar_cep_service.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  @override

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  
  bool _buscandoCep = false;
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
                 SizedBox(height: 24),
                 Text(
                  "Tire uma foto do local para cadastrá-lo.",
                  
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                 SizedBox(height: 24),

                // Campo de Busca por CEP
                TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Digite o CEP do local',
                    prefixIcon: const Icon(Icons.map_outlined),
                    suffixIcon: _buscandoCep
                        ?  Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              if (_cepController.text.isNotEmpty) {
                                setState(() => _buscandoCep = true);
                                try {
                                  // Chama o seu serviço de CEP
                                  final resultado = await BuscarcepService().buscar(_cepController.text);
                                  
                                  if (resultado != null) {
                                    setState(() {
                                      _latController.text = resultado['lat'].toString();
                                      _lonController.text = resultado['lon'].toString();
                                    });
                                  }
                                } catch (e) {
                                  debugPrint("Erro: $e");
                                } finally {
                                  setState(() => _buscandoCep = false);
                                }
                              }
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campos de Latitude e Longitude (Preenchidos automaticamente)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lonController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
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