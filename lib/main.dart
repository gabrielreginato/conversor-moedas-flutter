import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const url = 'https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL,BTC-BRL';
Uri request = Uri.parse(url);

void main() async {
  runApp(MyApp());
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController realController = TextEditingController();
  final TextEditingController euroController = TextEditingController();
  final TextEditingController bitController = TextEditingController();

  double dolarCot = 0.0;
  double euroCot = 0.0;
  double bitCot = 0.0;

  void _realChanged(String text) {
    double real = 0.0;
    if (text.isNotEmpty) {
      real = double.parse(text);
    }

    dolarController.text = (real / dolarCot).toStringAsFixed(2);
    euroController.text = (real / euroCot).toStringAsFixed(2);
    bitController.text = (real / bitCot).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = 0.0;
    if (text.isNotEmpty) {
      dolar = double.parse(text);
    }

    realController.text = (dolarCot * dolar).toStringAsFixed(2);
    euroController.text = (double.parse(realController.text) / euroCot).toStringAsFixed(2);
    bitController.text = (double.parse(realController.text) / bitCot).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = 0.0;
    if(text.isNotEmpty) {
      euro = double.parse(text);
    }

    realController.text = (euroCot * euro).toStringAsFixed(2);
    dolarController.text = (double.parse(realController.text) / dolarCot).toStringAsFixed(2);
    bitController.text = (double.parse(realController.text) / bitCot).toStringAsFixed(2);
  }

  void _bitChanged(String text) {
    double bitcoin = 0.0;
    if(text.isNotEmpty) {
      bitcoin = double.parse(text);
    }

    realController.text = (bitCot * bitcoin).toStringAsFixed(2);
    dolarController.text = (double.parse(realController.text) / dolarCot).toStringAsFixed(2);
    euroController.text = (double.parse(realController.text) / euroCot).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff101010),
      appBar: AppBar(
        title: Text(
          'Coinverter',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando Dados...',
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao Carregar Dados :(\n${snapshot.error}',
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolarCot = double.parse(snapshot.data!['USDBRL']['high']);
                euroCot = double.parse(snapshot.data!['EURBRL']['high']);
                bitCot = double.parse(snapshot.data!['BTCBRL']['high']);
                realController.text = '1.00';
                dolarController.text = (1 / dolarCot).toStringAsFixed(2);
                euroController.text = (1 / euroCot).toStringAsFixed(2);
                bitController.text = (1 / bitCot).toStringAsFixed(2);
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                          'Reais', 'R\$ ', realController, _realChanged),
                      SizedBox(height: 30),
                      buildTextField(
                          'Dólares', 'U\$ ', dolarController, _dolarChanged),
                      SizedBox(height: 30),
                      buildTextField(
                          'Euros', '€  ', euroController, _euroChanged),
                      SizedBox(height: 30),
                      buildTextField(
                          'Bitcoin', '₿  ', bitController, _bitChanged),
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

TextField buildTextField(
  String label,
  String prefix,
  TextEditingController controller,
  Function f,
) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 24,
    ),
    onChanged: (value) => f(value),
  );
}
