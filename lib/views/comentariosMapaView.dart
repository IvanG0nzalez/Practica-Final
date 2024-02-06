import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);
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

  @override
  Widget build(BuildContext context) {
    print(widget.comentarios);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Comentarios'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.popUntil(
                              context, ModalRoute.withName('/noticias'));
                        },
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Noticias',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: cerrarSesion,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                  title: Text(
                    "Publicado por: " + comentario['usuario'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${comentario['texto']} \n(Lat: ${comentario['latitud']}, Lng: ${comentario['longitud']})',
                    style: const TextStyle(
                      fontSize: 14.5,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); //cierra el menú y mueve el centro del mapa al punto seleccionado
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

  Future<MapOptions> _crearMapOptions() async {
    LatLng centro = await posicion_actual();
    return MapOptions(
      initialCenter: centro, //centro del mapa inicial
      initialZoom: 17.0, //zoom inicial
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
          onPressed: () => {},
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
}
