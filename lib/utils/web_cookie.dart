import 'web_cookie_stub.dart'
    if (dart.library.js_interop) 'web_cookie_html.dart' as web_impl;

class WebCookie {
  static void set(String name, String value, {int maxAgeDays = 365}) {
    web_impl.setWebCookie(name, value, maxAgeDays: maxAgeDays);
  }

  static String? get(String name) {
    return web_impl.getWebCookie(name);
  }

  static void delete(String name) {
    web_impl.deleteWebCookie(name);
  }
}
