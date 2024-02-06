import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/servicio_back/RespuestaGenerica.dart';
import 'package:noticias/controls/utiles/Utiles.dart';

class DetalleNoticiaView extends StatefulWidget {
  final String externalId;
  final Map<String, dynamic> noticia;

  const DetalleNoticiaView(
      {Key? key, required this.externalId, required this.noticia})
      : super(key: key);

  @override
  _DetalleNoticiaViewState createState() => _DetalleNoticiaViewState();
}

class _DetalleNoticiaViewState extends State<DetalleNoticiaView> {
  FacadeService _servicio = FacadeService();

  final TextEditingController _textoController = TextEditingController();

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

  void _guardarComentario() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    Utiles util = Utiles();
    String? externalUser = await util.getValue('external_user');

    String externalId = widget.externalId;

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
          await _servicio.guardar_comentario(comentario);

      if (respuesta.code == 200) {
        const SnackBar msg =
            SnackBar(content: Text('Mensaje guardado exitosamente'));
        ScaffoldMessenger.of(context).showSnackBar(msg);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Noticia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
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
                margin: EdgeInsets.symmetric(vertical: 8.0),
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
                constraints: const BoxConstraints(
                    maxHeight: 200), // Define la altura máxima
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
              SizedBox(height: 32.0),
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
}
