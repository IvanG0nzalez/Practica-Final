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
  List<dynamic> noticias = [];
  Utiles util = Utiles();
  FacadeService facadeService = FacadeService();
  late Future<bool> isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = util.getValue('isAdmin').then((value) => value == 'true');
    listarNoticias();
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
        title: const Text('Noticias'),
        automaticallyImplyLeading: false,
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
      body: ListView.builder(
        itemCount: noticias.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 6.0,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Colors.black87, width: 1.0),
            ),
            shadowColor: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      noticias[index]['titulo'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
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
                            Center(
                                child:
                                    Text("Noticia " + noticias[index]['tipo'])),
                            Center(
                                child: Text("Publicado: " +
                                    _formatDate(noticias[index]['fecha']))),
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
                                          onPressed: () =>
                                              ver_comentarios_noticia_mapa(
                                                  noticias[index]
                                                      ['external_id']),
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
              external_noticia: externalId,
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

  void ver_comentarios_noticia_mapa(String externalId) {
    facadeService.obtener_comentarios_noticia(externalId).then((value) {
      if (value.code == 200) {
        if (value.datos.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComentariosMapaView(
                comentarios: value.datos,
              ),
            ),
          );
        } else {
          final SnackBar msg = SnackBar(
              content: Text('Aún no hay comentarios en esta noticia.'));
          ScaffoldMessenger.of(context).showSnackBar(msg);
        }
      } else {
        final SnackBar msg = SnackBar(content: Text('Error ${value.code}'));
        ScaffoldMessenger.of(context).showSnackBar(msg);
      }
    });
  }
}
