import 'package:flutter/material.dart';

class HourlyForcastWidget extends StatelessWidget {
  const HourlyForcastWidget({
    super.key,
    required this.tempreture,
    required this.time,
    required this.icon,
  });
  final String tempreture;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        color: const Color.fromARGB(255, 65, 155, 228), // Sets the background color to blue
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                 const Color.fromARGB(255, 34, 150, 244),
                const Color.fromARGB(255, 22, 82, 234),
              ], // Define your gradient colors
              begin: Alignment.topLeft, // Start point of the gradient
              end: Alignment.bottomRight, // End point of the gradient
            ),
          ),

          width: 110,
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 7),
              Icon(icon, size: 32, color: Colors.yellow),
              SizedBox(height: 7),
              Text(
                tempreture,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
