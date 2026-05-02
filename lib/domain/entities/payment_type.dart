import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum PaymentType {
  whatsapp(label: "WhatsApp", faIcon: FaIcon(FontAwesomeIcons.whatsapp)),
  bankTransfer(
    label: "Transferencia Bancaria",
    faIcon: FaIcon(FontAwesomeIcons.buildingColumns),
  ),
  culqi(label: "Culqi", faIcon: FaIcon(FontAwesomeIcons.creditCard), logos: []),
  yape(label: "Yape", faIcon: FaIcon(FontAwesomeIcons.moneyBill1Wave)),
  izipay(
    label: "Izipay",
    faIcon: FaIcon(FontAwesomeIcons.creditCard),
    logos: [],
  );

  final String label;
  final FaIcon faIcon;
  final List<String>? logos;
  const PaymentType({required this.label, required this.faIcon, this.logos});
}
