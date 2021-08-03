import 'package:flutter/material.dart';

class GradientElevatedButton extends StatelessWidget {
  const GradientElevatedButton({
    Key? key,
    required this.width,
    required this.colors,
    required this.title,
    required this.titleSize,
    required this.onClick,
  }) : super(key: key);

  final double width;
  final List<Color> colors;
  final String title;
  final double titleSize;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0,
          )
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 1.0],
          colors: colors,
        ),
        color: Colors.deepPurple.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: onClick,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
