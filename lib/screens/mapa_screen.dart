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
  String? _lugarSelecionadoNome;

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapaController, LugaresController>(
      builder: (context, mapaController, lugaresController, child) => Scaffold(
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              mapaController.carregando
                  ? Center(child: CircularProgressIndicator())
                  : mapaController.atual == null
                  ? Center(child: Text("Não encontrado"))
                  : Expanded(
                      child: FlutterMap(
                        mapController: mapaController.mapControllerNativo,
                        options: MapOptions(
                          initialZoom: 15,
                          initialCenter: mapaController.atual ?? LatLng(0, 0),
                          onTap: (_, __) {
                            if (_lugarSelecionadoNome != null) {
                              setState(() => _lugarSelecionadoNome = null);
                            }
                            mapaController.limparRota();
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: "br.com.guiaturismo.maps",
                            maxNativeZoom: 19,
                          ),

                          // Linha da rota até o lugar selecionado
                          if (mapaController.rotaAtual.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: mapaController.rotaAtual,
                                  strokeWidth: 4.5,
                                  color: Colors.blueAccent,
                                ),
                              ],
                            ),

                          // Marcador para os lugares salvos
                          MarkerLayer(
                            markers: lugaresController.lugares
                                .map(
                                  (lugaresSalvos) {
                                    final destino = LatLng(
                                      lugaresSalvos.latitude.toDouble(),
                                      lugaresSalvos.longitude.toDouble(),
                                    );
                                    return Marker(
                                      alignment: Alignment.center,
                                      width: 130,
                                      height: 64,
                                      rotate: true,
                                      point: destino,
                                      child: GestureDetector(
                                        onTap: () {
                                          final selecionando =
                                              _lugarSelecionadoNome != lugaresSalvos.nome;
                                          setState(() {
                                            _lugarSelecionadoNome =
                                                selecionando ? lugaresSalvos.nome : null;
                                          });
                                          if (selecionando) {
                                            mapaController.tracarRota(destino);
                                          } else {
                                            mapaController.limparRota();
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if (_lugarSelecionadoNome == lugaresSalvos.nome)
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 4),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  lugaresSalvos.nome,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            Tooltip(
                                              message: lugaresSalvos.nome,
                                              child: Icon(
                                                Icons.place,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                                .toList(),
                          ),

                          // Criado durante a aula
                          MarkerLayer(
                            markers: mapaController.pontosNoMapa
                                .map(
                                  (pontoReferencia) => Marker(
                                    alignment: Alignment.center,
                                    width: 40,
                                    height: 40,
                                    rotate: true,
                                    point: pontoReferencia,
                                    child: Icon(Icons.location_on),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => mapaController.buscarLocal(),
          child: Icon(Icons.person_pin_circle_rounded),
        ),
      ),
    );
  }
}