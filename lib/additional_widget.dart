import 'package:flutter/material.dart';

class AdditionalWidget extends StatelessWidget {
  const AdditionalWidget({super.key, required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return 
        Column(
          children: [
            Icon(icon, size: 32, color: Colors.yellow),
            SizedBox(height: 7),
            Text(label,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.white),
            ),

            SizedBox(height: 7),
            Text(value,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.white),
            ),
          ],
        );
      
    
  }
}
