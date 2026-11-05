import 'package:flutter/material.dart';
import 'package:guia_turismo/services/mapa_service.dart';
import 'package:latlong2/latlong.dart';



class MapaController extends ChangeNotifier{
  //Atribui os resultados de mapaService a variavel _servico
  final MapaService _servico = MapaService();

  LatLng? atual;

  List<LatLng> pontosNoMapa = [];
  bool carregando = false;
  String erro = "";

  //Busca o lugar assim que a página é chamada
  MapaController(){
    buscarLocal();
  }



  Future<void> buscarLocal() async {
    carregando = true;
    notifyListeners();

    try {
      atual = await _servico.obterLocal(); //retorna latitude e longitude

      if (atual == null){
        erro = "Erro ao buscar local";
      } else {
        pontosNoMapa.add(atual!);
      }
    } catch (e) {
      erro = e.toString(); //Só colocar isso em desenvolvimento, jamais em produção (erro com códigos e coisas chatas)
      debugPrint("Erro: $erro");
    } finally {
      carregando = false;
      notifyListeners();
    }
    
  }

}