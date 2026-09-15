import 'dart:io';
import 'dart:typed_data';

import 'package:pasteboard/pasteboard.dart';

/// Writes [bytes] to [path] on the native filesystem.
///
/// Used after [FilePicker.saveFile] returns a path on Windows/Linux/macOS,
/// because the desktop file_picker implementation only shows the dialog and
/// returns the chosen path — it does not write the file itself.
Future<void> writeFileBytes(String path, Uint8List bytes) =>
    File(path).writeAsBytes(bytes);

/// Copies a PNG [bytes] image to the system clipboard using the
/// [pasteboard](https://pub.dev/packages/pasteboard) package.
Future<void> copyImageToClipboard(Uint8List bytes) =>
    Pasteboard.writeImage(bytes);
