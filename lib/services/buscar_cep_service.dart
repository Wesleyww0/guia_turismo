import 'dart:convert'; //Permite conversões de JSON em outras coisas
import 'package:http/http.dart' as http; //Permite requisições na net

class BuscarcepService {

  //De acordo com o proprio flutter, só static pode ter valores constantes
  //E esse headers é usado nas requisições
  static const _headers = {'User-Agent': 'GuiaTurismo/1.0 (br.com.guiaturismo.maps)'};

  //? = Pode vir um resultado nulo
  Future <Map<String, dynamic>?> buscar (String buscar) async {
    /*
      Para pegar o CEP correto, precisamos usar o viaCEP, ja que
      o Nominatim não tem todos os ceps cadastrados
    */

    //Pegar o CEP do viaCEP

    //substitui espaço e traços por vazio
    final cepLimpo = buscar.replaceAll(RegExp(r'\D'), '');


    final viaCEP = await http.get(Uri.https('viacep.com.br', '/ws/$cepLimpo/json/'));
    //Se der ruim na requisição, avisa erro
    if (viaCEP.statusCode != 200) throw Exception('Erro ao buscar CEP');
    //Obtem os dados do json
    final endereco = jsonDecode(viaCEP.body);
    if (endereco['erro'] != null) return null; //Cep não existe
    

    //Passando para o Nominatim
    final respostaNom = await http.get(Uri.https(
      //Requisição de busca
      'nominatim.openstreetmap.org', '/search', {
        'street': endereco['logradouro'],
        'city': endereco['localidade'],
        'state': endereco['uf'],
        'country': 'Brasil',
        'format': 'jsonv2',
        'limit': '1', //Busca o 1° resultado ou o mais relevante
    }),
    //Precisamos nos identificar para poder fazer a requisição
    headers: _headers,
    );
    //Se der ruim, retorna erro
    if (respostaNom.statusCode != 200) throw Exception('Erro ao buscar coordenadas');
    final List<dynamic> resultados = jsonDecode(respostaNom.body);
    
    //Se tiver vazio retorna null, mas se não trás o primeiro resultado
    return resultados.isEmpty ? null : resultados[0];

  }
}