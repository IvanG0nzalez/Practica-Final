import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:noticias/views/comentariosMapaView.dart';

class AdministrarUsuariosView extends StatefulWidget {
  const AdministrarUsuariosView({Key? key}) : super(key: key);

  @override
  _AdministrarUsuariosViewState createState() =>
      _AdministrarUsuariosViewState();
}

class _AdministrarUsuariosViewState extends State<AdministrarUsuariosView> {
  List<dynamic> usuarios = [];

  Utiles util = Utiles();
  FacadeService facadeService = FacadeService();
  late Future<bool> isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = util.getValue('isAdmin').then((value) => value == 'true');
    listarUsuarios();
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
        title: const Text('Administrar Usuarios'),
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
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Cuenta'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/cuenta');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Listado de Noticias'),
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
                      leading: const FaIcon(FontAwesomeIcons.mapMarkedAlt),
                      title: const Text(
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
                      leading: const FaIcon(FontAwesomeIcons.users),
                      title: const Text(
                        'Administrar Usuarios',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, '/administrar_usuarios');
                      },
                    );
                  } else {
                    return Container();
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                cerrarSesion();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          dynamic usuario = usuarios[index];

          if (usuario['rol']['nombre'] == 'administrador') {
            return Container();
          }

          String direccion = usuario['direccion'] != 'NONE'
              ? 'Dirección: ${usuario['direccion']}'
              : 'Dirección: Sin registrar';
          String celular = usuario['celular'] != 'NONE'
              ? 'Celular: ${usuario['celular']}'
              : 'Celular: Sin registrar';
          String correo = usuario['cuenta']['correo'] != 'NONE'
              ? 'Correo: ${usuario['cuenta']['correo']}'
              : 'Correo: Sin registrar';

          return Card(
            elevation: 6.0,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '${usuario['nombres']} ${usuario['apellidos']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (correo.isNotEmpty)
                    Text(
                      correo,
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  if (direccion.isNotEmpty)
                    Text(
                      direccion,
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  if (celular.isNotEmpty)
                    Text(
                      celular,
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/comentarios_usuario',
                              arguments: {
                                'externalUsuario': usuario['external_id'],
                                'nombreUsuario':
                                    '${usuario['nombres']} ${usuario['apellidos']}',
                              });
                        },
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                          ),
                        ),
                        child: const Text('Ver comentarios'),
                      ),
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          _banearUsuario(usuario['external_id']);
                        },
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.shade400),
                          side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(color: Colors.black54),
                          ),
                        ),
                        child: const Text(
                          'Banear',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void listarUsuarios() {
    facadeService.listar_personas().then((value) {
      setState(() {
        usuarios = value.datos;
        log(value.datos.toString());
      });
    });
  }

  void _banearUsuario(String externalUsuario) {
    facadeService.dar_de_baja(externalUsuario).then((value) {
      if (value.code == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario baneado exitosamente')),
        );
        listarUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al banear al usuario')),
        );
      }
    });
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

  void cerrarSesion() async {
    Utiles util = Utiles();
    util.removeAllItems();
    Navigator.pushReplacementNamed(context, '/home');
  }
}
