import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<String> nombres = [];

  var loading = false;
  String dropDownValue = "";
  void fetchDataFromJson() async {
    setState(() {
      nombres.clear();
    });
    final response = await http
        .get(Uri.parse('https://app.iedeoccidente.com/getPeriodos.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Limpiamos la lista actual antes de agregar nuevos nombres
      print(jsonData);
      nombres.clear();
      //nombres.addAll(jsonData['periodo']);

      // Iteramos sobre los datos JSON y obtenemos los nombres
      for (var item in jsonData) {
        String nombre = item['periodo'];
        nombres.add(nombre);
      }

      // Actualizamos el widget con los nuevos datos
      // Esto es necesario para que los cambios se reflejen en la interfaz gráfica
      setState(() {
        dropDownValue = nombres.first;
        loading = false;
      });
    } else {
      print('Error al obtener los datos JSON: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obtener Datos JSON'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                      print(loading);
                    });
                    fetchDataFromJson();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 150, vertical: 10)),
                  ),
                  child: Text('Obtener Datos JSON'),
                )),
            SizedBox(height: 20),
            Loading(
              isLoading: loading,
              child: Text(""),
            ),
            DropdownButton(
              value: dropDownValue,
              items: nombres.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? value) {
                // Do something with the selected value.
                setState(() {
                  dropDownValue = value!;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: nombres.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(nombres[index]),
                    onTap: () {
                      print(nombres[index]);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Dialog title'),
                            content: Text('This is a dialog.'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text('Close'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Agregamos una acción adicional al botón flotante para limpiar la lista
          nombres.clear();
          setState(() {});
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}

class Loading extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  Loading({this.isLoading = false, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return widget.isLoading ? CircularProgressIndicator() : widget.child;
  }
}
