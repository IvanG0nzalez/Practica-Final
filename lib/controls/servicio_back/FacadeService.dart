import 'dart:convert';
import 'dart:developer';
import 'package:noticias/controls/Conexion.dart';
import 'package:noticias/controls/servicio_back/RespuestaGenerica.dart';
import 'package:noticias/controls/servicio_back/modelo/InicioSesionSW.dart';
import 'package:http/http.dart' as http;
import 'package:noticias/controls/servicio_back/modelo/RegistroSW.dart';


class FacadeService {
  Conexion c = Conexion();
  Future<InicioSesionSW> inicioSesion(Map<String, String> mapa) async {
    Map<String, String> header = {'Content-Type': 'application/json'};

    final String url = '${c.URL}login';
    final uri = Uri.parse(url);
    InicioSesionSW isws = InicioSesionSW();
    try {
      final response =
          await http.post(uri, headers: header, body: jsonEncode(mapa));
      log(response.toString());
      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          isws.code = 404;
          isws.tag = 'Error';
          isws.msg = 'Recurso No Encontrado';
          isws.datos = {};
          return isws;
        }
      } else {
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        isws.code = mapa['code'];
        isws.tag = mapa['tag'];
        isws.msg = mapa['msg'];
        isws.datos = mapa['datos'];
        return isws;
      }
    } catch (e) {
      isws.code = 500;
      isws.tag = 'Error Interno';
      isws.msg = 'Error Inesperado';
      isws.datos = {};
      return isws;
    }
    return isws;
  }
  Future<RespuestaGenerica> listar_compradores() async {
    return await c.solicitudGet("admin/compradores", false);
  }

  Future<RegistroSW> registro(Map<String, String> mapa) async {
    Map<String, String> header = {'Content-Type': 'application/json'};

    final String url = '${c.URL}personas/usuarios/save';
    final uri = Uri.parse(url);
    RegistroSW rws = RegistroSW();
    try {
      final response =
          await http.post(uri, headers: header, body: jsonEncode(mapa));
      log(response.toString());
      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          rws.code = 404;
          rws.msg = 'Error en el registro';
          return rws;
        }
      } else {
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        rws.code = mapa['code'];
        rws.msg = mapa['msg'];
        return rws;
      }
    } catch (e) {
      rws.code = 500;
      rws.msg = 'Error Inesperado';
      return rws;
    }
    return rws;
  }
}
