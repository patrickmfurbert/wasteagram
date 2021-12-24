import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '/models/entry_dto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Waste_Input extends StatefulWidget {
  final image;
  final entry;
  const Waste_Input({this.image, this.entry, Key? key}) : super(key: key);

  @override
  _Waste_InputState createState() => _Waste_InputState();
}

class _Waste_InputState extends State<Waste_Input> {
  final GlobalKey<FormState>? _key = GlobalKey<FormState>();
  int number_of_waste_items = 0;

  @override
  Widget build(BuildContext context) {
    if (number_of_waste_items != 0) {
      print(number_of_waste_items);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15),

            //widget image
            widget.image != null
                ? Image.file(File(widget.image!.path))
                : Text("No Image Selected"),

            SizedBox(height: 25),
            Form(
              key: _key,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Wasted Items',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter number';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (isNumber(value)) {
                    print(value);
                    setState(() => number_of_waste_items = int.parse(value));
                  }
                },
              ),
            ),
            SizedBox(height: 70),
            Text(
                'Location ${widget.entry.latitude.toString()} / ${widget.entry.longitude.toString()}'),
            SizedBox(height: 80),
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(
                  width: MediaQuery.of(context).size.width * .6, height: 80),
              child: ElevatedButton(
                onPressed: () async {
                  //validate
                  _key!.currentState!.validate();

                  //get reference to stuff?
                  firebase_storage.FirebaseStorage storage =
                      firebase_storage.FirebaseStorage.instance;

                  String? storage_url =
                      'uploads/${widget.image!.path.split('/').last}';

                  //upload picture
                  await storage
                      .ref(storage_url)
                      .putFile(File(widget.image!.path));

                  //get picture URL

                  //get date
                  DateTime now = new DateTime.now();
                  final DateFormat formatter = DateFormat('EEEE, MM dd, yyyy');
                  final String formatted = formatter.format(now);
                  print(formatted); // something like 2013-04-20

                  //add data to object
                  widget.entry.date = formatted;
                  widget.entry.picture_url = storage_url;
                  widget.entry.num_items = number_of_waste_items;

                  CollectionReference<Map<String, dynamic>> waste =
                      FirebaseFirestore.instance.collection('waste_items');

                  await waste.add({
                    'date': widget.entry.date,
                    'latitude': widget.entry.latitude,
                    'longitude': widget.entry.longitude,
                    'num_items': widget.entry.num_items,
                    'picture_url': widget.entry.picture_url
                  });

                  Navigator.pop(context);
                },
                child: Icon(Icons.upload),
              ),
            )
          ],
        ),
      ),
    );
  }
}

bool isNumber(var value) {
  if (value != null && int.parse(value) != 0) {
    return true;
  }
  return false;
}
