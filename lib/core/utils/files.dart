import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../network/upload_file.dart';
import 'toast.dart';

/// Replaces `<input type="file">`. Returns `null` when the user cancels.
///
/// Uses the file path when the platform gives one (desktop, iOS) and the
/// bytes otherwise (Android `content://` URIs), so the result always uploads.
Future<UploadFile?> pickUploadFile({
  FileType type = FileType.any,
  List<String>? allowedExtensions,
}) async {
  try {
    final file = await FilePicker.pickFile(
      type: allowedExtensions != null ? FileType.custom : type,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    final path = file.path;
    if (path != null) return UploadFile(name: file.name, path: path);
    return UploadFile(name: file.name, bytes: await file.readAsBytes());
  } catch (e) {
    AppToast.error('Could not open the file: $e');
    return null;
  }
}

/// `<input type="file" accept="image/*">`.
Future<UploadFile?> pickImageFile() => pickUploadFile(type: FileType.image);

/// Reads an [UploadFile] fully (for previews / data URLs).
Future<Uint8List> readUploadBytes(UploadFile file) async {
  if (file.bytes != null) return file.bytes!;
  return File(file.path!).readAsBytes();
}

/// `FileReader.readAsDataURL` equivalent.
Future<String> toDataUrl(UploadFile file) async {
  final bytes = await readUploadBytes(file);
  return 'data:${mimeTypeFor(file.name)};base64,${base64Encode(bytes)}';
}

/// Replaces the web's blob download (`URL.createObjectURL` + `<a download>`):
/// asks where to save and writes [bytes]. Returns `true` when saved.
Future<bool> saveBytesAs(Uint8List bytes, String fileName, {String? mimeType}) async {
  try {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType ?? mimeTypeFor(fileName),
    );
    if (uri == null) return false;
    AppToast.success('Saved $fileName');
    return true;
  } catch (e) {
    AppToast.error('Could not save the file: $e');
    return false;
  }
}

String mimeTypeFor(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  return switch (ext) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'svg' => 'image/svg+xml',
    'pdf' => 'application/pdf',
    'csv' => 'text/csv',
    'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'xls' => 'application/vnd.ms-excel',
    _ => 'application/octet-stream',
  };
}
