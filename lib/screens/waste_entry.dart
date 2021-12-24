import 'package:flutter/material.dart';
import 'package:wasteagram/models/entry_dto.dart';

class Waste_Entry extends StatelessWidget {

  final Entry_Object entry;
  const Waste_Entry({required this.entry, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wasteagram'),
        centerTitle: true,
      ),
      //TODO: Add Date, Picture, Num Items, Lat long
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            entry.date!,
            style: TextStyle(fontSize: 25),
          ),
          Image.network(
              entry.picture_url!),
          Text(
            '${entry.num_items!} Items',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Location(${entry.latitude!}, ${entry.longitude!})'),
        ],
      ),
    );
  }
}
