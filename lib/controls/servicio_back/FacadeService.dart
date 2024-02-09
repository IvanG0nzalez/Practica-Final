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
      log(e.toString());
      return isws;
    }
    return isws;
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

  Future<RespuestaGenerica> listar_noticas() async {
    return await c.solicitudGet("noticias", false);
  }

  Future<RespuestaGenerica> obtener_noticia(String externalId) async {
    return await c.solicitudGet('noticias/get/${externalId}', false);
  }

  Future<RespuestaGenerica> guardar_comentario(Map<String, dynamic> comentario) async {
    return await c.solicitudPost("comentarios/save", false, comentario);
  }

  Future<RespuestaGenerica> obtener_comentarios() async {
    return await c.solicitudGet("comentarios", false);
  }

  Future<RespuestaGenerica> obtener_comentarios_noticia(String externalId) async {
    return await c.solicitudGet('noticias/comentarios/get/${externalId}', false);
  }

  Future<RespuestaGenerica> obtener_10_comentarios_noticia(String externalId) async {
    return await c.solicitudGet('noticias/comentarios/get10/${externalId}', false);
  }

  Future<RespuestaGenerica> obtener_comentarios_noticia_usuario(String externalNoticia, String? externalPersona) async {
    return await c.solicitudGet('noticias/comentarios/usuarios/get/${externalNoticia}/${externalPersona}', false);
  }

  Future<RespuestaGenerica> editar_comentario(String externalComentario, Map<String, dynamic> comentario) async {
    return await c.solicitudPatch('comentarios/edit/${externalComentario}/', false, comentario);
  }

  Future<RespuestaGenerica> obtener_persona(String externalId) async {
    return await c.solicitudGet('admin/personas/get/${externalId}', false);
  }

  Future<RespuestaGenerica> editar_persona(String externalPersona, Map<String, dynamic> mapa) async {
    return await c.solicitudPatch('admin/personas/edit/${externalPersona}/', false, mapa);
  }
}
