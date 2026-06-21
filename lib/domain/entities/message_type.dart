enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  paymentLink;

  static MessageType fromString(String type) {
    final normalized = type.replaceAll('_', '').replaceAll('-', '').toLowerCase();
    if (normalized == 'document') {
      return MessageType.file;
    }
    return MessageType.values.firstWhere(
      (element) => element.name.toLowerCase() == normalized,
      orElse: () => MessageType.text,
    );
  }
}
