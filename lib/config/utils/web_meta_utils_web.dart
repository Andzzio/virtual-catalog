import 'package:web/web.dart' as web;

void updatePageTitle(String title) {
  web.document.title = title;
}

void updateFavicon(String iconUrl) {
  if (iconUrl.isEmpty) return;

  final link = web.document.getElementById('favicon');
  if (link != null) {
    link.setAttribute('href', iconUrl);
  }
}
