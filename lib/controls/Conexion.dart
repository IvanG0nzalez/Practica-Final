import 'package:noticias/controls/servicio_back/RespuestaGenerica.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:noticias/controls/utiles/Utiles.dart';

class Conexion {
  final String URL = "http://192.168.1.109:3000/api/"; //de la casa
  final String URL_MEDIA = "http://192.168.1.109:3000/multimedia";
  //final String URL = "http://10.20.139.90:3000/api/"; //de la uni
  //final String URL_MEDIA = "http://10.20.139.90:3000/multimedia";
  static bool NO_TOKEN = false;
  Future<RespuestaGenerica> solicitudGet(String recurso, bool token) async{
    Map<String, String> _header = {'Content-Type':'application/json'};
    if(token){
        Utiles util = Utiles();
        String? token = await util.getValue('token');
      _header = {'Content-Type':'application/json','token':token.toString()};
    }
    final String _url = URL+recurso;
    final uri = Uri.parse(_url);
    try{
      final response = await http.get(uri, headers: _header);
      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          return _response(404, "Recurso no encontrado", []);
        } else {
          Map<dynamic, dynamic> mapa = jsonDecode(response.body);
          return _response(mapa['code'], mapa['msg'], mapa['datos']);
        }
      } else {
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        return _response(mapa['code'], mapa['msg'], mapa['datos']);
      }
    } catch(e){
      return _response(500, "Error inesperado", []);
    }
  }

  Future<RespuestaGenerica> solicitudPost(String recurso, bool token, Map<dynamic, dynamic> mapa) async{
    Map<String, String> _header = {'Content-Type':'application/json'};
    if(token){
      Utiles util = Utiles();
      String? token = await util.getValue('token');
      _header = {'Content-Type':'application/json','token':token.toString()};
    }
    final String _url = URL+recurso;
    final uri = Uri.parse(_url);
    try{
      final response = await http.post(uri, headers: _header, body: jsonEncode(mapa));
      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          return _response(404, "Recurso no encontrado", []);
        } else {
          Map<dynamic, dynamic> mapa = jsonDecode(response.body);
          return _response(mapa['code'], mapa['msg'], mapa['datos']);
        }
      } else {
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        return _response(mapa['code'], mapa['msg'], mapa['datos']);
      }
    } catch(e){
      return _response(500, "Error inesperado", []);
    }
  }

  Future<RespuestaGenerica> solicitudPatch(String recurso, bool token, Map<dynamic, dynamic> mapa) async {
  Map<String, String> _header = {'Content-Type':'application/json'};
  if(token){
    Utiles util = Utiles();
    String? token = await util.getValue('token');
    _header = {'Content-Type':'application/json','token':token.toString()};
  }
  final String _url = URL+recurso;
  final uri = Uri.parse(_url);
  try{
    final response = await http.patch(uri, headers: _header, body: jsonEncode(mapa));
    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        return _response(404, "Recurso no encontrado", []);
      } else {
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        return _response(mapa['code'], mapa['msg'], mapa['datos']);
      }
    } else {
      Map<dynamic, dynamic> mapa = jsonDecode(response.body);
      return _response(mapa['code'], mapa['msg'], mapa['datos']);
    }
  } catch(e){
    return _response(500, "Error inesperado", []);
  }
}

  RespuestaGenerica _response(int code, String msg, dynamic data) {
    var respuesta = RespuestaGenerica();
    respuesta.code = code;
    respuesta.datos = data;
    respuesta.msg = msg;
    return respuesta;
  }
}