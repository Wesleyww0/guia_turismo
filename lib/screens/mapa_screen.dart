import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/controller/mapa_controller.dart';
import 'package:provider/provider.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:latlong2/latlong.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}
class _MapaScreenState extends State<MapaScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MapaController, LugaresController>(
      builder: (context, mapaController, lugaresController,child) => Scaffold(
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            //Centralização
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Se está carregando, mostra o circulo de loading
              mapaController.carregando ? Center(child: CircularProgressIndicator())
              //Se não achar/carregar, fala que n foi encontrado 
              : mapaController.atual == null ? Center(child: Text("Não encontrado")) 
              //Se achar/carregar o mapa
              : Expanded( 
              child: FlutterMap(
                options: MapOptions(
                  initialZoom: 15,
                  //! significa que não vai estar nulo
                  initialCenter: mapaController.atual!
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    //Informa quem está pedindo para usar o mapa
                    userAgentPackageName: "br.com.guiaturismo.maps",
                  ),
                  
                      /*
                        Se o lugar não tiver categoria ou tiver coordenadas inválidas
                        ele não aparece no mapa.
                      */

                      //Marcador para os lugares salvos
                      MarkerLayer(
                        markers: 
                        lugaresController.lugares.map(
                          (lugaresSalvos) => Marker(
                            alignment: Alignment.center,
                            width: 40,
                            height: 40,
                            rotate: true,
                            //lugaresSalvos foi criado nesse Map, e pega os valores de lugares dentro de lugaresController
                            point: LatLng(lugaresSalvos.latitude.toDouble(), lugaresSalvos.longitude.toDouble()),
                            child: Tooltip(
                            message: lugaresSalvos.nome, //Se pressionar o lugar mostra o nome
                            child: Icon(Icons.place, color: Colors.blueAccent)
                            )
                          ),
                        ).toList() 
                        ),

                        //Criado durante a aula 
                        MarkerLayer(
                    markers: 
                    mapaController.pontosNoMapa.map(
                      (pontoReferencia) => Marker(
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                        rotate: true,
                        point: pontoReferencia,
                        child: Icon(Icons.location_on)
                      )
                      ).toList()),
                ]
                ) 
              ),
            ],
          )
          ),
        floatingActionButton: FloatingActionButton(
          //Centraliza a posição do usuário no mapa
          onPressed: () => mapaController.buscarLocal(),
          child: Icon(Icons.person_pin_circle_rounded),
          ),
      )
    );
  }
}