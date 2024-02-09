import 'package:flutter/material.dart';
import 'package:noticias/views/administrarUsuariosView.dart';
import 'package:noticias/views/comentariosUsuarioView.dart';
import 'package:noticias/views/detalleCuentaView.dart';
import 'package:noticias/views/detalleNoticiaView.dart';
import 'package:noticias/views/exception/Page404.dart';
import 'package:noticias/views/noticiasView.dart';
import 'package:noticias/views/registerView.dart';
import 'package:noticias/views/sessionView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SessionView(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const SessionView(),
        '/register': (context) => const RegisterView(),
        '/noticias': (context) => const NoticiasView(),
        '/noticias/detalle': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DetalleNoticiaView(
            externalNoticia: args['externalId'],
            noticia: args['noticia'],
          );
        },
        '/cuenta': (context) => const DetalleCuentaView(),
        '/administrar_usuarios': (context) => const AdministrarUsuariosView(),
        '/comentarios_usuario': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ComentariosUsuarioView(
            externalUsuario: args['externalUsuario'],
            nombreUsuario: args['nombreUsuario'],
          );
        },
      },
      onGenerateRoute: (setting) {
        if (setting.name == '/noticias/detalle') {
          final args = setting.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DetalleNoticiaView(
              externalNoticia: args['externalId'],
              noticia: args['noticia'],
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => const Page404());
      },
    );
  }
}
