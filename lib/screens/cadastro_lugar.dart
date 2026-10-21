import 'package:flutter/material.dart';
import 'package:guiaapp/controller/camera_controller.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CameraController>(
        builder: (context, controle, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  // primeiro widget é o fundo
                  height: 300,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(16),
                    image: exibirImagem(controle),                   
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => controle.abrirCamera(),
                    icon: Icon(Icons.camera_alt_rounded),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

DecorationImage exibirImagem (CameraController controle) {
  if(controle.imagemSelecionada == null) {
    return DecorationImage(image: NetworkImage('https://placehold.jp/150x150.png'));
  } else {
    return DecorationImage(
      image: FileImage(controle.imagemSelecionada!),
      fit: BoxFit.cover
      );
  }
}

void abrirModal (CameraController controle, context) {
  showModalBottomSheet(
    context: context,
     builder: (context) => 
     SafeArea(
      bottom: true,
      child:  Wrap(
        alignment: WrapAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            onTap: () {
              controle.abrirCamera();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            onTap: () {
              controle.abrirGaleria();
              Navigator.pop(context);
            }
          )
        ],
      )
    )
  );
}