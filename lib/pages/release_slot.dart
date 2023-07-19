import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const ReleaseDartWidget());

class ReleaseDartWidget extends StatefulWidget {
  const ReleaseDartWidget({super.key});
  @override
  State<ReleaseDartWidget> createState() => _ReleaseDartWidgetState();
}

class _ReleaseDartWidgetState extends State<ReleaseDartWidget> {
  late String parkingLotId;
  late String slotId;
  String releaseRes = '';
  void releaseSlot() async {
    final response = await http.post(
        Uri.parse('http://192.168.1.2:8080/releaseSlot/$parkingLotId/$slotId'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final data = jsonDecode(response.body);
      print(data);

      print('success = ${data["success"]}');
      if (data["success"] == true) {
        setState(() {
          releaseRes = 'Slot with id $slotId has been release';
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            releaseRes = '';
          });
        });
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    final elevatedButton = ElevatedButton(
      onPressed: releaseSlot,
      child: const Text('RELEASE'),
    );
    return Center(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
              onChanged: (value) {
                parkingLotId = value;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Parking lot id',
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
              onChanged: (value) {
                slotId = value;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Parking slot id',
              )),
        ),
        elevatedButton,
        if (releaseRes.isNotEmpty) Text(releaseRes)
      ]),
    );
  }
}
