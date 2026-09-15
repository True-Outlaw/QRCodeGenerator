// Platform-adaptive I/O helpers.
//
// On web (dart:js_interop / package:web available) this re-exports
// [platform_io_web.dart], which uses the browser Clipboard API and relies on
// file_picker's built-in download trigger.
// On all native targets this re-exports [platform_io_native.dart], which uses
// dart:io and the pasteboard package.
export 'platform_io_native.dart' if (dart.library.html) 'platform_io_web.dart';
