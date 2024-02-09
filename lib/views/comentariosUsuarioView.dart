import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';

class ComentariosUsuarioView extends StatefulWidget {
  final String externalUsuario;
  final String nombreUsuario;

  const ComentariosUsuarioView({Key? key, required this.externalUsuario, required this.nombreUsuario})
      : super(key: key);

  @override
  _ComentariosUsuarioViewState createState() =>
      _ComentariosUsuarioViewState();
}

class _ComentariosUsuarioViewState extends State<ComentariosUsuarioView> {
  Utiles util = Utiles();
  FacadeService facadeService = FacadeService();

  late Future<List<dynamic>> _comentariosUsuario;

  @override
  void initState() {
    super.initState();
    _comentariosUsuario = _cargarComentariosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreUsuario),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _comentariosUsuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> comentarios = snapshot.data!;
            if (comentarios.isEmpty) {
              return const Center(
                child: Card(
                  margin: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'El usuario aún no ha publicado ningún comentario',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: comentarios.length,
                itemBuilder: (context, index) {
                  dynamic comentario = comentarios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    color: Colors.grey[200],
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black26),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "En la noticia " +
                                '"${comentario['titulo_noticia']}"',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${comentario['texto']}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '(Latitud: ${comentario['latitud']}, Longitud: ${comentario['longitud']})',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<List<dynamic>> _cargarComentariosUsuario() async {
    final respuesta = await facadeService.obtener_comentarios_persona(
        widget.externalUsuario);
    if (respuesta.code == 200) {
      log(respuesta.datos.toString());
      return respuesta.datos;
    } else {
      return [];
    }
  }
}