import 'dart:html' as html;

void setWebCookie(String name, String value, {int maxAgeDays = 365}) {
  final maxAgeSeconds = maxAgeDays * 86400;
  html.document.cookie =
      '$name=${Uri.encodeComponent(value)}; max-age=$maxAgeSeconds; path=/; SameSite=Lax';
}

String? getWebCookie(String name) {
  final cookies = html.document.cookie?.split(';') ?? [];
  for (var cookie in cookies) {
    final parts = cookie.trim().split('=');
    if (parts.length == 2 && parts[0] == name) {
      return Uri.decodeComponent(parts[1]);
    }
  }
  return null;
}

void deleteWebCookie(String name) {
  html.document.cookie =
      '$name=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
}
