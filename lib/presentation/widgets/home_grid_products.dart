import 'package:flutter/material.dart';

class HomeGridProducts extends StatelessWidget {
  const HomeGridProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1000,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("The Products", style: TextStyle(fontSize: 35)),
          Row(
            children: [
              Text(
                "Timeless pieces designed for the modern wardrobe",
                style: TextStyle(fontSize: 16, color: Color(0xFFB3B8C1)),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                child: Text("View All"),
              ),
            ],
          ),
          SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 400,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                return Placeholder();
              },
            ),
          ),
        ],
      ),
    );
  }
}
