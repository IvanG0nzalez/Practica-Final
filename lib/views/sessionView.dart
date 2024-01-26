import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:validators/validators.dart';

class SessionView extends StatefulWidget {
  const SessionView({Key? key}) : super(key: key);

  @override
  _SessionViewState createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  final _formKey =
      GlobalKey<FormState>(); //El guión bajo indica que la variable es privada

  final TextEditingController correoControl = TextEditingController();
  final TextEditingController claveControl = TextEditingController();

  void _iniciar() {
    setState(() {
      //Conexion c = Conexion();
      //c.solicitudGet("autos", false);
      FacadeService servicio = FacadeService();
      if (_formKey.currentState!.validate()) {
        Map<String, String> mapa = {
          "correo": correoControl.text,
          "clave": claveControl.text
        };
        servicio.inicioSesion(mapa).then((value) async {
          if (value.code == 200) {
            Utiles util = Utiles();
            util.saveValue('token', value.datos['token']);
            final SnackBar msg =
                SnackBar(content: Text('Bienvenido ${value.datos['user']}'));
            ScaffoldMessenger.of(context).showSnackBar(msg);
          } else {
            final SnackBar msg = SnackBar(content: Text('Error ${value.code}'));
            ScaffoldMessenger.of(context).showSnackBar(msg);
          }
          log(value.datos.toString());
        });
      } else {
        log('ta mal');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(32),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text("Noticias",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text("Le mejor aplicación del mundo xd",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: correoControl,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Debe ingresar su correo";
                  }
                  //if(!isEmail(value)) {
                  //  return "Debe ingresar un correo válido";
                  //}
                },
                decoration: const InputDecoration(
                    labelText: 'Correo',
                    suffixIcon: Icon(Icons.alternate_email)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                obscureText: true,
                controller: claveControl,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Debe ingresar su clave";
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Clave', suffixIcon: Icon(Icons.key)),
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10,
                  0), //Función para padding de todos lados Left, Top, Right, Bottom
              child: ElevatedButton(
                  child: const Text("Inicio"), onPressed: _iniciar),
            ),
            Row(
              children: <Widget> [
                const Text('No tienes una cuenta'),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/register');
                  }, 
                  child: const Text(
                    'Registrate',
                    style: TextStyle(fontSize: 20),
                  )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
