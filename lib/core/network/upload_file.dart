import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A file chosen by the user that must be sent as multipart/form-data.
///
/// Replaces the browser `File` objects the web app appended to `FormData`.
/// Desktop/mobile pickers give a [path]; some platforms only give [bytes].
class UploadFile {
  const UploadFile({required this.name, this.path, this.bytes})
      : assert(path != null || bytes != null,
            'UploadFile needs either a path or bytes');

  final String name;
  final String? path;
  final Uint8List? bytes;

  Future<MultipartFile> toMultipartFile() async {
    if (path != null) {
      return MultipartFile.fromFile(path!, filename: name);
    }
    return MultipartFile.fromBytes(bytes!, filename: name);
  }
}

/// Builds a [FormData] from a map, the way the web services did with
/// `formData.append(key, value)`:
///  * `null` values are skipped,
///  * [UploadFile] values become multipart files,
///  * `bool` values become `'1'` / `'0'` (Laravel friendly),
///  * lists are sent as `key[]` entries,
///  * everything else is sent with `toString()`.
Future<FormData> buildFormData(Map<String, dynamic> fields) async {
  final form = FormData();
  for (final entry in fields.entries) {
    await _append(form, entry.key, entry.value);
  }
  return form;
}

Future<void> _append(FormData form, String key, dynamic value) async {
  if (value == null) return;
  if (value is UploadFile) {
    form.files.add(MapEntry(key, await value.toMultipartFile()));
  } else if (value is List) {
    for (final item in value) {
      await _append(form, key.endsWith('[]') ? key : '$key[]', item);
    }
  } else if (value is bool) {
    form.fields.add(MapEntry(key, value ? '1' : '0'));
  } else {
    form.fields.add(MapEntry(key, value.toString()));
  }
}
