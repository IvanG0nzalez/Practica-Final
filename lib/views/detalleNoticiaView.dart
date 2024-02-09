import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/servicio_back/RespuestaGenerica.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:noticias/views/comentariosMapaView.dart';

class DetalleNoticiaView extends StatefulWidget {
  final String external_noticia;
  final Map<String, dynamic> noticia;

  const DetalleNoticiaView(
      {Key? key, required this.external_noticia, required this.noticia})
      : super(key: key);

  @override
  _DetalleNoticiaViewState createState() => _DetalleNoticiaViewState();
}

class _DetalleNoticiaViewState extends State<DetalleNoticiaView> {
  Utiles util = Utiles();
  FacadeService facadeService = FacadeService();
  late Future<String> external_user;

  final TextEditingController _textoController = TextEditingController();

  List<dynamic> _comentarios = [];
  late Future<List<dynamic>> _comentariosPropios;

  late Future<bool> isAdmin;

  @override
  void initState() {
    super.initState();
    _comentariosPropios = _cargarComentariosPropiosIniciales();
    _cargarComentarios();
    isAdmin = util.getValue('isAdmin').then((value) => value == 'true');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Detalle Noticia'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 227, 206, 251),
              ),
              child: Text(
                'Aplicación de Noticias',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text('Listado de Noticias'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/noticias');
              },
            ),
            FutureBuilder<bool>(
              future: isAdmin,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data == true) {
                    return ListTile(
                      leading: FaIcon(FontAwesomeIcons.mapMarkedAlt),
                      title: Text(
                        'Mapa general',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        ver_comentarios_mapa();
                      },
                    );
                  } else {
                    return Container();
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: Text('Cuenta'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/cuenta');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar Sesión'),
              onTap: () {
                cerrarSesion();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.noticia['titulo'],
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    '(Noticia ${widget.noticia['tipo']})',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Editor: ${widget.noticia['persona']['nombres']} ${widget.noticia['persona']['apellidos']}',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatDate(widget.noticia['fecha']),
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1.0),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    '${Conexion().URL_MEDIA}/${widget.noticia['archivo']}',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.noticia['cuerpo'],
                      style: const TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Mis Comentarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 227, 206, 251).withOpacity(0.5),
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SingleChildScrollView(
                  child: FutureBuilder<List<dynamic>>(
                    future: _comentariosPropios,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error al cargar comentarios'),
                          );
                        } else {
                          List<dynamic> comentarios = snapshot.data ?? [];
                          return comentarios.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Aún no ha hecho un comentario'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: comentarios.length,
                                  itemBuilder: (context, index) {
                                    var comentario = comentarios[index];
                                    return Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom:
                                              BorderSide(color: Colors.black54),
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Text(comentario['usuario']),
                                        subtitle: Text(comentario['texto']),
                                        trailing: ElevatedButton(
                                          onPressed: () {
                                            _editarComentario(comentario);
                                          },
                                          child: Text('Editar'),
                                        ),
                                      ),
                                    );
                                  },
                                );
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Otros Comentarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 227, 206, 251).withOpacity(0.5),
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: _comentarios.isEmpty ? 55.0 : 300.0,
                child: SizedBox(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _comentarios.isNotEmpty
                          ? _comentarios.map((comentario) {
                              return Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black54),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(comentario['usuario']),
                                  subtitle: Text(comentario['texto']),
                                  // Otros campos del comentario, si los hay
                                ),
                              );
                            }).toList()
                          : [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('¡Sé el primero en comentar!'),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 20, right: 5),
          child: FloatingActionButton(
            onPressed: _mostrarPopUp,
            child: const Icon(Icons.comment),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future<List<dynamic>> _cargarComentariosPropiosIniciales() async {
    final respuesta = await facadeService.obtener_comentarios_noticia_usuario(
        widget.external_noticia, await util.getValue('external_user'));
    if (respuesta.code == 200) {
      log(respuesta.datos.toString());
      return respuesta.datos;
    } else {
      return [];
    }
  }

  void _cargarComentariosPropios() async {
    final respuesta = await facadeService.obtener_comentarios_noticia_usuario(
        widget.external_noticia, await util.getValue('external_user'));
    if (respuesta.code == 200) {
      log(respuesta.datos.toString());
      setState(() {
        _comentariosPropios = Future.value(respuesta.datos);
      });
    } else {}
  }

  void _cargarComentarios() async {
    RespuestaGenerica respuesta = await facadeService
        .obtener_10_comentarios_noticia(widget.external_noticia);
    if (respuesta.code == 200) {
      setState(() {
        _comentarios = respuesta.datos;
      });
    } else {}
  }

  void cerrarSesion() async {
    Utiles util = Utiles();
    util.removeAllItems();
    Navigator.pushReplacementNamed(context, '/home');
  }

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _mostrarPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.black54,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresar Comentario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textoController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Escriba su comentario aquí',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _limpiarTexto();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                              color: Colors.white), //color del texto del boton
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _guardarComentario();
                          Navigator.of(context).pop(); //cierra el popup
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, //color del botón
                          foregroundColor:
                              Colors.black, //color del texto del botón
                        ),
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _limpiarTexto() {
    _textoController.clear();
  }

  void _guardarComentario() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    Utiles util = Utiles();
    String? externalUser = await util.getValue('external_user');

    String externalId = widget.external_noticia;

    String texto = _textoController.text;

    if (texto.isNotEmpty) {
      Map<String, dynamic> comentario = {
        "texto": texto,
        "usuario": externalUser,
        "longitud": position.longitude.toString(),
        "latitud": position.latitude.toString(),
        "noticia": externalId,
      };

      RespuestaGenerica respuesta =
          await facadeService.guardar_comentario(comentario);

      if (respuesta.code == 200) {
        const SnackBar msg =
            SnackBar(content: Text('Mensaje guardado exitosamente'));
        ScaffoldMessenger.of(context).showSnackBar(msg);
        _limpiarTexto();
        _cargarComentarios();
        _cargarComentariosPropios();
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('El texto del comentario no puede estar vacío.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _editarComentario(dynamic comentario) {
    String textoExistente = comentario['texto'];
    _textoController.text = textoExistente;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.black54,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar Comentario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textoController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Editar su comentario aquí',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _limpiarTexto();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String textoEditado = _textoController.text;
                          Map<String, dynamic> comentarioEditado = {
                            "texto": textoEditado,
                          };

                          RespuestaGenerica respuesta =
                              await facadeService.editar_comentario(
                            comentario['external_id'],
                            comentarioEditado,
                          );

                          if (respuesta.code == 200) {
                            const SnackBar msg = SnackBar(
                                content:
                                    Text('Comentario editado exitosamente'));
                            ScaffoldMessenger.of(context).showSnackBar(msg);
                            _cargarComentarios();
                            _cargarComentariosPropios();
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text(respuesta.msg),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Aceptar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void ver_comentarios_mapa() {
    facadeService.obtener_comentarios().then((value) {
      if (value.code == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComentariosMapaView(
              comentarios: value.datos,
            ),
          ),
        );
      } else {
        final SnackBar msg = SnackBar(content: Text('Error ${value.code}'));
        ScaffoldMessenger.of(context).showSnackBar(msg);
      }
    });
  }
}
