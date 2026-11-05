
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapaService {
  Future<LatLng?> obterLocal() async {
    //Verifica se o serviço de localização está ativo
    bool ativo = await Geolocator.isLocationServiceEnabled();

    if (!ativo) return null;
    //Vendo se temos permissão para acessar a localização
    LocationPermission permissao = await Geolocator.checkPermission();

    //Se não tiver, peça
    if (permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
    }
    
    //Se o usuário bloqueou total a permissão, então deixa quieto
    if (permissao == LocationPermission.deniedForever) return null;

    Position posicao;

    try {
      //Tenta pegar a posição do usuário, se der bom, pega a latitude e longitude, se não, retorna erro no console
      posicao = await Geolocator.getCurrentPosition();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      debugPrint("Erro ao obter posição: $erro");
      return null;
    } 

  }
}