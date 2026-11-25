import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/controller/mapa_controller.dart';
import 'package:provider/provider.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  String? _lugarSelecionadoNome;

  Future<void> _abrirLink(BuildContext context, Uri appUri, Uri webUri, String nomeApp) async {
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o $nomeApp.')),
      );
    } catch (e) {
      debugPrint('Erro ao abrir $nomeApp: $e');
    }
  }

  Future<void> _abrirUber(BuildContext context, LatLng origem, LatLng destino, String? nomeDestino) async {
    final params = <String, String>{
      'action': 'setPickup',
      'pickup[latitude]': origem.latitude.toString(),
      'pickup[longitude]': origem.longitude.toString(),
      'dropoff[latitude]': destino.latitude.toString(),
      'dropoff[longitude]': destino.longitude.toString(),
      if (nomeDestino != null && nomeDestino.isNotEmpty) 'dropoff[nickname]': nomeDestino,
    };

    final appUri = Uri(scheme: 'uber', host: '', queryParameters: params);
    final webUri = Uri.https('m.uber.com', '/ul/', params);
    await _abrirLink(context, appUri, webUri, 'Uber');
  }

  Future<void> _abrirGoogleMaps(BuildContext context, LatLng destino) async {
    final appUri = Uri.parse(
      'google.navigation:q=${destino.latitude},${destino.longitude}&mode=d',
    );
    final webUri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '${destino.latitude},${destino.longitude}',
        'travelmode': 'driving',
      },
    );
    await _abrirLink(context, appUri, webUri, 'Google Maps');
  }

  Future<void> _abrirWaze(BuildContext context, LatLng destino) async {
    final appUri = Uri.parse(
      'waze://?ll=${destino.latitude},${destino.longitude}&navigate=yes',
    );
    final webUri = Uri.https(
      'waze.com',
      '/ul',
      {
        'll': '${destino.latitude},${destino.longitude}',
        'navigate': 'yes',
      },
    );
    await _abrirLink(context, appUri, webUri, 'Waze');
  }

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
                      child: Stack(
                        children: [
                          FlutterMap(
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
                                                mapaController.tracarRota(
                                                  destino,
                                                  nomeDestino: lugaresSalvos.nome,
                                                );
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

                          if (mapaController.rotaAtual.isNotEmpty &&
                              mapaController.atual != null &&
                              mapaController.destinoSelecionado != null)
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 84,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mapaController.nomeDestinoSelecionado ?? 'Destino',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _abrirUber(
                                                context,
                                                mapaController.atual!,
                                                mapaController.destinoSelecionado!,
                                                mapaController.nomeDestinoSelecionado,
                                              ),
                                              icon: const Icon(Icons.local_taxi, size: 18),
                                              label: const Text('Uber'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _abrirGoogleMaps(
                                                context,
                                                mapaController.destinoSelecionado!,
                                              ),
                                              icon: const Icon(Icons.map, size: 18),
                                              label: const Text('Maps'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _abrirWaze(
                                                context,
                                                mapaController.destinoSelecionado!,
                                              ),
                                              icon: const Icon(Icons.navigation, size: 18),
                                              label: const Text('Waze'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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