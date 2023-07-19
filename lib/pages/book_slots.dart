import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() => runApp(const BookSlotWidget());

Future<List<ParkingName>> fetchParkingName() async {
  final response =
      await http.get(Uri.parse('http://192.168.1.2:8080/parkingLots'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final data = jsonDecode(response.body);
    List<ParkingName> listParkingName = [];
    for (Map i in data) {
      listParkingName.add(ParkingName.fromJson(i));
    }
    print(listParkingName);
    return listParkingName;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load parking lots');
  }
}

Future<Map<String, dynamic>> bookParking(String parkingId, String size) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.2:8080/getSlot/$parkingId/$size'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{}),
  );
  final data = jsonDecode(response.body);
  return data;
}

// List<ParkingName> modelUserFromJson(String str) => List<ParkingName>.from(
//     json.decode(str).map((x) => ParkingName.fromJson(x)));
// String modelUserToJson(List<ParkingName> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParkingName {
  int id;
  String parkingName;

  ParkingName({
    required this.id,
    required this.parkingName,
  });

  factory ParkingName.fromJson(Map<dynamic, dynamic> json) => ParkingName(
        id: json['id'],
        parkingName: json['parkingName'],
      );

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "parkingName": parkingName,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

class BookSlotWidget extends StatefulWidget {
  const BookSlotWidget({super.key});
  @override
  State<BookSlotWidget> createState() => _BookSlotWidgetState();
}

class _BookSlotWidgetState extends State<BookSlotWidget> {
  late Future<List<ParkingName>> futureParkingName;
  final List<String> parkingSize = ['small', 'medium', 'large', 'xLarge'];
  late String parkingDropdown;
  late String parkingSizeDropdown;
  late Map<String, dynamic> bookSlotRes = {};
  @override
  void initState() {
    super.initState();
    futureParkingName = fetchParkingName();
    parkingSizeDropdown = parkingSize.first;
    assignValue();
  }

  void assignValue() async {
    parkingDropdown = '${(await futureParkingName)[0].id}';
  }

  bookSlot() async {
    final response = await bookParking(parkingDropdown, parkingSizeDropdown);
    setState(() {
      bookSlotRes = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ParkingName>>(
      future: futureParkingName,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: Column(
              children: [
                DropdownButton<String>(
                  value: parkingDropdown,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      parkingDropdown = value!;
                    });
                  },
                  items: snapshot.data!
                      .map<DropdownMenuItem<String>>((ParkingName value) {
                    return DropdownMenuItem<String>(
                      value: '${value.id}',
                      child: Text(value.parkingName),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: parkingSizeDropdown,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      parkingSizeDropdown = value!;
                    });
                  },
                  items:
                      parkingSize.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: bookSlot,
                  child: const Text('BOOK'),
                ),
                if (bookSlotRes.isNotEmpty) getResponseText()
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const SizedBox(
            height: 10.0, width: 10.0, child: CircularProgressIndicator());
      },
    );
  }

  getResponseText() {
    return Text(bookSlotRes.toString());
  }
}
