import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/services/mapa_service.dart';
import 'package:latlong2/latlong.dart';

class MapaController extends ChangeNotifier {
  final MapaService _servico = MapaService();

  LatLng? atual;
  List<LatLng> pontosNoMapa = [];
  bool carregando = false;
  String erro = "";

  final MapController mapControllerNativo = MapController();

  MapaController() {
    buscarLocal();
  }

  Future<void> buscarLocal() async {
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      atual = await _servico.obterLocal();
      if (atual == null) {
        erro = "Erro ao buscar local";
      } else {
        if (!pontosNoMapa.contains(atual!)) {
          pontosNoMapa.add(atual!);
        }
      }
    } catch (e) {
      erro = e.toString();
      debugPrint("Erro: $erro");
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void moverParaDestino(LatLng novaCoordenada) {
    atual = novaCoordenada;

    if (!pontosNoMapa.contains(novaCoordenada)) {
      pontosNoMapa.add(novaCoordenada);
    }

    mapControllerNativo.move(novaCoordenada, 15.0);
    notifyListeners();
  }
}