import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WhatsappFloatingButton extends StatelessWidget {
  const WhatsappFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      shape: CircleBorder(),
      backgroundColor: Colors.greenAccent,
      child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
    );
  }
}
