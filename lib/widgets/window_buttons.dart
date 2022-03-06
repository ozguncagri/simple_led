import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //MinimizeWindowButton(colors: buttonColors),
        //MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: WindowButtonColors(
            mouseOver: const Color(0xFFD32F2F),
            mouseDown: const Color(0xFFD32F2F),
            iconNormal: Colors.white,
            iconMouseOver: Colors.white,
          ),
        ),
      ],
    );
  }
}
