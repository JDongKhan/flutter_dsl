import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dsl/flutter_dsl.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) async {
    print(details);
  };

  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stack) {
      print('$error \n $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        child: FlutterDSLWidget(
          path: 'assets/view.xml',
          linkAction: (dynamic link) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NextPage()));
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterDSLWidget(
        path: 'assets/view_2.xml',
        linkAction: (dynamic link) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NextPage()));
        },
      ),
    );
  }
}
