import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';

class WhatsappFloatingButton extends StatelessWidget {
  const WhatsappFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final phone =
            context.read<BusinessProvider>().business?.whatsappNumber ?? "";
        debugPrint(phone);
      },
      shape: CircleBorder(),
      backgroundColor: Colors.greenAccent,
      child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
    );
  }
}
