import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaService {
  Future<LatLng?> obterLocal() async {
    bool ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) return null;

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.deniedForever) return null;

    try {
      Position posicao = await Geolocator.getCurrentPosition();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      debugPrint("Erro ao obter posição: $erro");
      return null;
    }
  }

  Future<List<LatLng>> buscarRota(LatLng origem, LatLng destino) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origem.longitude},${origem.latitude};'
        '${destino.longitude},${destino.latitude}'
        '?overview=full&geometries=geojson',
      );

      final resposta = await http.get(url);
      if (resposta.statusCode != 200) return [];

      final dados = jsonDecode(resposta.body);
      final List routes = dados['routes'] ?? [];
      if (routes.isEmpty) return [];

      final List coordenadas = routes[0]['geometry']['coordinates'];
      return coordenadas
          .map((coord) => LatLng(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              ))
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar rota: $e");
      return [];
    }
  }
}