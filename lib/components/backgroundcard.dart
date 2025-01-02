import 'package:flutter/material.dart';
import 'package:wallet_budget_tracker/helper/colors.dart';

class BackgroundCard extends StatelessWidget {
  Widget body;
  BackgroundCard({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width, // 1/4 of the full width
      height: screenSize.height / 2.7, // 1/4 of the full height
      decoration: const BoxDecoration(
        color: ColorsHelper.green,
        /* image: const DecorationImage(
          image: AssetImage('assets/img/bgcard.png'), // Specify your image path
          fit: BoxFit.cover, // Optional: Adjust how the image is fitted
        ),*/ // Set the background color to green
        // Optional: Add rounded corners
      ),
      child: body,
    );
  }
}
