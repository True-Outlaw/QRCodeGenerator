import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// No-op on web.
///
/// [FilePicker.saveFile] with a [bytes] argument automatically triggers a
/// browser download — no additional file write is required.
Future<void> writeFileBytes(String path, Uint8List bytes) async {}

/// Copies a PNG image to the clipboard using the modern Web Clipboard API
/// (`navigator.clipboard.write`).
///
/// Requires the page to be served over HTTPS (GitHub Pages qualifies) and
/// the user to have granted clipboard-write permission.
/// Throws on unsupported browsers or denied permissions; the caller shows an
/// error snackbar in that case.
Future<void> copyImageToClipboard(Uint8List bytes) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );

  // package:web types are already JSAny — no .toJS needed on blob.
  final clipboardItem = web.ClipboardItem(
    <String, JSAny?>{'image/png': blob}.jsify()! as JSObject,
  );

  await web.window.navigator.clipboard.write([clipboardItem].toJS).toDart;
}
