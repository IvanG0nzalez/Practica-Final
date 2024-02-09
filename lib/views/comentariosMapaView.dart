import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class ComentariosMapaView extends StatefulWidget {
  final List<dynamic> comentarios;

  const ComentariosMapaView({Key? key, required this.comentarios})
      : super(key: key);

  @override
  _ComentariosMapaViewState createState() => _ComentariosMapaViewState();
}

class _ComentariosMapaViewState extends State<ComentariosMapaView>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late final AnimatedMapController _animatedMapController;
  Utiles util = Utiles();
  FacadeService facadeService = FacadeService();
  late Future<bool> isAdmin;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);
    isAdmin = util.getValue('isAdmin').then((value) => value == 'true');
  }

  @override
  Widget build(BuildContext context) {
    print(widget.comentarios);
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
        title: const Text('Mapa de Comentarios'),
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
            const ListTile(
              title: Text(
                "COMENTARIOS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text(
                "(Presione sobre un comentario para visualizarlo en el mapa)",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
            for (var comentario in widget.comentarios)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                        "Noticia: " + comentario['titulo_noticia'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Comentario de: " + comentario['usuario'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                        ),
                      ),
                      Text(
                        '${comentario['texto']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '(Latitud: ${comentario['latitud']}, Longitud: ${comentario['longitud']})',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(
                        context); //cierra el menú y mueve el centro del mapa al punto seleccionado
                    _centrarMapa(
                      double.parse(comentario['latitud'].toString()),
                      double.parse(comentario['longitud'].toString()),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      body: FutureBuilder<MapOptions>(
        future: _crearMapOptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              return FlutterMap(
                mapController: _animatedMapController.mapController,
                options: snapshot.data!,
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: _crearMarcadores(),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: Text('No se encontraron datos.'));
            }
          }
        },
      ),
    );
  }

  Future<LatLng> posicion_actual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    double latitud = position.latitude;
    double longitud = position.longitude;

    return LatLng(latitud, longitud);
  }

  void cerrarSesion() async {
    Utiles util = Utiles();
    util.removeAllItems();
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<MapOptions> _crearMapOptions() async {
    LatLng centro = await posicion_actual();
    return MapOptions(
      initialCenter: centro, //centro del mapa inicial
      initialZoom: 17.0, //zoom inicial
    );
  }
void _mostrarInfoComentario(Map<String, dynamic> comentario) {
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
              crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles del Comentario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Comentario de ${comentario['usuario']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "En la noticia '${comentario['titulo_noticia']}'",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "Texto: ${comentario['texto']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "Latitud: ${comentario['latitud']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Longitud: ${comentario['longitud']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cerrar',
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
        ),
      );
    },
  );
}


  List<Marker> _crearMarcadores() {
    return widget.comentarios.map((comentario) {
      double latitud = double.parse(comentario['latitud'].toString());
      double longitud = double.parse(comentario['longitud'].toString());

      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(latitud, longitud),
        child: IconButton(
          icon: Icon(Icons.location_on),
          onPressed: () {
            _mostrarInfoComentario(comentario);
          },
        ),
      );
    }).toList();
  }

  void _centrarMapa(double latitud, double longitud) {
    //mapController.move(LatLng(latitud, longitud), 21.0);
    _animatedMapController.animateTo(
      dest: LatLng(latitud, longitud),
      zoom: 21.0,
      curve: Curves.fastLinearToSlowEaseIn,
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
