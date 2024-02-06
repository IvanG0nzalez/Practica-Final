import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:noticias/views/comentariosMapaView.dart';
import 'package:noticias/views/detalleNoticiaView.dart';
import 'package:intl/intl.dart';

class NoticiasView extends StatefulWidget {
  const NoticiasView({Key? key}) : super(key: key);

  @override
  _NoticiasViewState createState() => _NoticiasViewState();
}

class _NoticiasViewState extends State<NoticiasView> {
  List<dynamic> noticias = []; // Lista para almacenar las noticias
  Utiles util = Utiles();
  late Future<bool> isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = util.getValue('isAdmin').then((value) => value == 'true');
    listarNoticias();
  }

  void listarNoticias() {
    FacadeService facadeService = FacadeService();
    facadeService.listar_noticas().then((value) {
      setState(() {
        noticias = value.datos; // Almacena las noticias en la lista
        log(value.datos.toString());
      });
    });
  }

  void cerrarSesion() async {
    Utiles util = Utiles();
    util.removeAllItems();
    Navigator.pushReplacementNamed(context, '/home');
  }

  void comentario(String externalId) {
    FacadeService facadeService = FacadeService();
    facadeService.obtener_noticia(externalId).then((value) {
      if (value.code == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleNoticiaView(
              externalId: externalId,
              noticia: value.datos,
            ),
          ),
        );
      } else {
        final SnackBar msg = SnackBar(content: Text('Error ${value.code}'));
        ScaffoldMessenger.of(context).showSnackBar(msg);
      }
    });
  }

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void ver_comentarios_mapa() {
    FacadeService facadeService = FacadeService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        automaticallyImplyLeading: false,
        actions: [
          FutureBuilder<bool>(
            future: isAdmin,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // o un indicador de carga
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.data == true) {
                  return IconButton(
                    icon: const FaIcon(FontAwesomeIcons.mapMarkedAlt),
                    onPressed: ver_comentarios_mapa,
                  );
                } else {
                  return Container(); // o null si no quieres mostrar nada
                }
              }
            },
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: noticias.length,
        itemBuilder: (context, index) {
          // Construir una tarjeta para cada noticia
          return Card(
            elevation: 6.0,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.black87, width: 1.0),
            ),
            shadowColor: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      noticias[index]['titulo'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                10.0), // Bordes redondeados
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // Color de la sombra
                                spreadRadius: 2, // Extensión de la sombra
                                blurRadius: 5, // Desenfoque de la sombra
                                offset:
                                    Offset(0, 3), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10.0), // Bordes redondeados
                            child: Image.network(
                              '${Conexion().URL_MEDIA}/${noticias[index]['archivo']}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Text("Noticia " + noticias[index]['tipo'])),
                            Center(
                                child: Text("Publicado: " + _formatDate(noticias[index]['fecha']))),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<bool>(
                                  future: isAdmin,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.data == null) {
                                      return Container();
                                    } else {
                                      if (snapshot.data!) {
                                        return IconButton(
                                          icon: Icon(
                                              FontAwesomeIcons.mapMarkerAlt),
                                          onPressed: () {
                                            // Acción cuando se presiona el botón del mapa
                                          },
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(width: 20.0),
                                TextButton(
                                  onPressed: () => comentario(
                                      noticias[index]['external_id']),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<
                                            Color>(
                                        Colors.indigoAccent.withOpacity(0.5)),
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                        EdgeInsets.only(
                                            left: 30.0, right: 30.0)),
                                  ),
                                  child: const Text(
                                    'Ver',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
