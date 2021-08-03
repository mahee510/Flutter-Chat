import 'package:flutter/material.dart';

class SplashScreeen extends StatelessWidget {
  const SplashScreeen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Flutter Chat",
              style: Theme.of(context).textTheme.headline3,
            )
          ],
        ),
      ),
    );
  }
}
