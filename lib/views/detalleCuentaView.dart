import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:noticias/views/comentariosMapaView.dart';

class DetalleCuentaView extends StatefulWidget {
  const DetalleCuentaView({Key? key}) : super(key: key);

  @override
  _DetalleCuentaViewState createState() => _DetalleCuentaViewState();
}

class _DetalleCuentaViewState extends State<DetalleCuentaView> {
  final FacadeService facadeService = FacadeService();
  final Utiles util = Utiles();

  late Future<bool> isAdmin;

  late String nombres = '';
  late String apellidos = '';
  late String correo = '';
  late String direccion = '';
  late String celular = '';

  @override
  void initState() {
    super.initState();
    isAdmin = util.getValue('isAdmin').then((value) => value == 'true');
    cargarInformacionUsuario();
  }

  Future<void> cargarInformacionUsuario() async {
    String? externalUser = await util.getValue('external_user');
    final response = await facadeService.obtener_persona(externalUser!);
    if (response.code == 200) {
      setState(() {
        nombres = response.datos['nombres'] ?? '';
        apellidos = response.datos['apellidos'] ?? '';
        correo = response.datos['cuenta']['correo'] ?? '';
        direccion = response.datos['direccion'] ?? '';
        celular = response.datos['celular'] ?? '';
      });
    } else {
      // Manejar error si la solicitud no es exitosa
    }
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
        title: Text('Detalle de Cuenta'),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirFields('Correo Electrónico', correo),
            _construirFields('Nombres', nombres),
            _construirFields('Apellidos', apellidos),
            _construirFields('Dirección', direccion),
            _construirFields('Celular', celular),
          ],
        ),
      ),
    );
  }

  Widget _construirFields(String etiqueta, String valor) {
    if (etiqueta == 'Correo Electrónico') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            valor.isNotEmpty ? valor : 'Ingresar información',
            style: TextStyle(fontSize: 16),
          ),
          Divider(),
          SizedBox(height: 12),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  valor.isNotEmpty ? valor : 'Ingresar información',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () {
                  _mostrarEditarCampo(etiqueta, valor);
                },
                icon: Icon(Icons.edit),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 12),
        ],
      );
    }
  }

  void _mostrarEditarCampo(String etiqueta, String valor) {
    TextEditingController controller = TextEditingController(text: valor);

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
                  Text(
                    'Editar $etiqueta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escriba su información aquí',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String newValue = controller.text;
                          Map<String, dynamic> newData = {
                            etiqueta.toLowerCase(): newValue,
                          };
                          String? externalUser =
                              await util.getValue('external_user');
                          final response = await facadeService.editar_persona(
                              externalUser!, newData);
                          if (response.code == 200) {
                            setState(() {
                              switch (etiqueta) {
                                case 'Correo Electrónico':
                                  correo = newValue;
                                  break;
                                case 'Nombres':
                                  nombres = newValue;
                                  break;
                                case 'Apellidos':
                                  apellidos = newValue;
                                  break;
                                case 'Dirección':
                                  direccion = newValue;
                                  break;
                                case 'Celular':
                                  celular = newValue;
                                  break;
                              }
                            });
                            Navigator.of(context).pop();
                          } else {
                            final SnackBar msg = SnackBar(
                                content: Text('Error ${response.code}'));
                            ScaffoldMessenger.of(context).showSnackBar(msg);
                          }
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

  void cerrarSesion() async {
    Utiles util = Utiles();
    util.removeAllItems();
    Navigator.pushReplacementNamed(context, '/home');
  }
}
