import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:validators/validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nombresC = TextEditingController();
    final TextEditingController apellidosC = TextEditingController();
    final TextEditingController correoC = TextEditingController();
    final TextEditingController claveC = TextEditingController();

    void _iniciar() {
      setState(() {
        //Conexion c = Conexion();
        //c.solicitudGet("autos", false);
        FacadeService servicio = FacadeService();
        if (_formKey.currentState!.validate()) {
          Map<String, String> mapa = {
            "nombres": nombresC.text,
            "apellidos": apellidosC.text,
            "correo": correoC.text,
            "clave": claveC.text
          };
          servicio.registro(mapa).then((value) async {
            if (value.code == 200) {
              final SnackBar msg =
                  SnackBar(content: Text('Registrado correctamente'));
              ScaffoldMessenger.of(context).showSnackBar(msg);
            } else {
              final SnackBar msg =
                  SnackBar(content: Text('Error ${value.code}'));
              ScaffoldMessenger.of(context).showSnackBar(msg);
            }
            log(value.datos.toString());
          });
        } else {
          log('ta mal');
        }
      });
    }

    return Form(
      key: _formKey,
      child: Scaffold(
        body: ListView(
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
              child: const Text("Registro de usuarios",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: nombresC,
                decoration: const InputDecoration(
                    labelText: 'Nombres', suffixIcon: Icon(Icons.account_tree)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Debe ingresar sus nombres";
                  }
                  //if(!isEmail(value)) {
                  //  return "Debe ingresar un correo válido";
                  //}
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: apellidosC,
                decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    suffixIcon: Icon(Icons.account_tree)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Debe ingresar sus apellidos";
                  }
                  //if(!isEmail(value)) {
                  //  return "Debe ingresar un correo válido";
                  //}
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: correoC,
                decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    suffixIcon: Icon(Icons.account_tree)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Debe ingresar su correo";
                  }
                  if (!isEmail(value)) {
                    return "Debe ingresar un correo válido";
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                obscureText: true,
                controller: claveC,
                decoration: const InputDecoration(
                    labelText: 'Clave', suffixIcon: Icon(Icons.account_tree)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Debe ingresar su clave";
                  }
                  //if(!isEmail(value)) {
                  //  return "Debe ingresar un correo válido";
                  //}
                },
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10,
                  0), //Función para padding de todos lados Left, Top, Right, Bottom
              child: ElevatedButton(
                  child: const Text("Registrar"), onPressed: _iniciar),
            ),
            Row(
              children: <Widget>[
                const Text('Ya tienes una cuenta'),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    child: const Text(
                      'Inicio de sesión',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
