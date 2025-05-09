import 'package:flutter/material.dart';

class CounterBuildStatsRow extends StatelessWidget{
const CounterBuildStatsRow({super.key,required this.label,required this.count});

final String label;
final int count;
@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18)),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
  
  
