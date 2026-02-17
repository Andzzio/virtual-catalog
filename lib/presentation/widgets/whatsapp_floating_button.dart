import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';

class WhatsappFloatingButton extends StatelessWidget {
  const WhatsappFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.read<BusinessProvider>();
    final phone = businessProvider.business?.whatsappNumber ?? "";
    return FloatingActionButton(
      onPressed: () async {
        if (phone.isEmpty) return;
        final String message = "Hola, me gustaría ver su catálogo";
        final url = Uri.parse(
          "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("No se puedo enviar el mensaje a whatsapp");
        }
      },
      shape: CircleBorder(),
      backgroundColor: Colors.greenAccent,
      child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
    );
  }
}
