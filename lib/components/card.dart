import 'package:flutter/material.dart';

import '../helper/fonts.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;

  const CustomCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FontsHelper.boldTextStyle(
                fontSize: FontsHelper.largeFontSize,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: FontsHelper.mediumTextStyle(
                fontSize: FontsHelper.mediumFontSize,
                color: Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              content,
              style: FontsHelper.smallTextStyle(
                fontSize: FontsHelper.smallFontSize,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
