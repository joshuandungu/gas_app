import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/screens/category_deals_screen.dart';
import 'package:flutter/material.dart';

class TopCategories extends StatelessWidget {
  const TopCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // Increased height for better spacing
      child: ListView.builder(
        itemCount: GlobalVariables.categoryImages.length,
        scrollDirection: Axis.horizontal,
        itemExtent: 80, // Adjusted item extent
        itemBuilder: (context, index) {
          final category = GlobalVariables.categoryImages[index];
          final title = category['title'] as String;

          // This is the logic to handle both image and icon
          Widget displayWidget;
          if (category['image'] != null) {
            displayWidget = ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                category['image'] as String,
                fit: BoxFit.cover,
                height: 50, // Adjusted size
                width: 50,
              ),
            );
          } else if (category['icon'] != null) {
            displayWidget = Icon(
              category['icon'] as IconData,
              size: 40, // Adjusted size
              color: Colors.grey[800], // A neutral, dark color
            );
          } else {
            // Fallback for safety
            displayWidget = const SizedBox(height: 50, width: 50);
          }

          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              CategoryDealsScreen.routeName,
              arguments: title,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 55, // Container for the icon/image
                  width: 55,
                  child: Center(child: displayWidget),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
