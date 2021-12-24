import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wasteagram/models/entry_dto.dart';
import 'package:wasteagram/screens/input_waste.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:wasteagram/screens/waste_entry.dart';

class Launch_Screen extends StatefulWidget {
  const Launch_Screen({Key? key}) : super(key: key);

  @override
  _Launch_ScreenState createState() => _Launch_ScreenState();
}

class _Launch_ScreenState extends State<Launch_Screen> {
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  bool _isListenLocation = false, _isGetLocation = false;

  Future _getImage() async {
    //check if location service enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled!) {
        print('Service Not Enabled');
        return;
      }
    }

    //get permission for location
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('Permission not granted');
        return;
      }
    }

    _locationData = await location.getLocation();
    print('Location ${_locationData!.latitude} / ${_locationData!.longitude}');
    Entry_Object new_post = Entry_Object(
        latitude: _locationData!.latitude, longitude: _locationData!.longitude);

    ImagePicker picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Waste_Input(image: image, entry: new_post)));
    print('Snap!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wasteagram'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('waste_items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc['date']),
                trailing: Text(doc['num_items'].toString()),
                onTap: () async {
                  print("Date: ${doc['date']}");
                  print("Latitude: ${doc['latitude']}");
                  print("Longitude: ${doc['longitude']}");
                  print("Num_items: ${doc['num_items']}");
                  print("Picture_url: ${doc['picture_url']}");

                  //create new entry
                  Entry_Object my_entry = Entry_Object(
                      latitude: doc['latitude'], longitude: doc['longitude']);
                  my_entry.date = doc['date'];
                  my_entry.num_items = doc['num_items'];
                  my_entry.picture_url = await firebase_storage
                      .FirebaseStorage.instance
                      .ref(doc['picture_url'])
                      .getDownloadURL();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Waste_Entry(entry: my_entry)));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: MaterialButton(
          child: Icon(
            Icons.photo_camera,
            color: new Color(0xFF2E2E2E),
            size: 30,
          ),
          shape: CircleBorder(),
          color: Colors.green,
          onPressed: () {
            _getImage();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
