import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

final request =
    Uri.parse("https://api.hgbrasil.com/finance?format=json&key=498a965e");
void main() {
  runApp(MaterialApp(
    home: const HomeScreen(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amberAccent)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber))),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String? text) {
    if (text.toString().isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text!);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String? text) {
    if (text.toString().isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text!);
    dolarController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String? text) {
    if (text.toString().isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text!);
    dolarController.text = (euro * this.euro).toStringAsFixed(2);
    euroController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CONVERSOR DE MOEDAS'),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'CARREGANDO DADOS...',
                  style: TextStyle(color: Colors.amberAccent, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'ERRO AO CARREGAR DADOS...',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 140,
                        color: Colors.amberAccent,
                      ),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      const Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, _dolarChanged),
                      const Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController noteController, Function(String?) func) {
  return TextField(
    controller: noteController,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: const OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.amberAccent),
        hintText: "55.00",
        hintStyle: const TextStyle(color: Colors.grey)),
    style: const TextStyle(
      color: Colors.amber,
    ),
    onChanged: func,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  Response response = await get(request);
  return json.decode(response.body);
}
