import 'dart:convert';
import 'package:flutter/material.dart';

/// The same thumbnail widget handles online URLs and encrypted snapshot data.
Image contentImage(
  String source, {
  Key? key,
  BoxFit? fit,
  double? width,
  double? height,
  AlignmentGeometry alignment = Alignment.center,
  ImageErrorWidgetBuilder? errorBuilder,
  ImageLoadingBuilder? loadingBuilder,
}) {
  if (source.trim().isEmpty) {
    return Image.memory(
      base64Decode(''),
      key: key,
      width: width,
      height: height,
      fit: fit,
      errorBuilder:
          errorBuilder ??
          (_, _, _) => const Icon(Icons.image_not_supported_outlined),
    );
  }
  if (source.startsWith('data:image/')) {
    try {
      return Image.memory(
        base64Decode(source.substring(source.indexOf(',') + 1)),
        key: key,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: errorBuilder,
      );
    } on FormatException {
      return Image.memory(
        base64Decode(''),
        key: key,
        errorBuilder: errorBuilder,
      );
    }
  }
  return Image.network(
    source,
    key: key,
    fit: fit,
    width: width,
    height: height,
    alignment: alignment,
    errorBuilder: errorBuilder,
    loadingBuilder: loadingBuilder,
  );
}
