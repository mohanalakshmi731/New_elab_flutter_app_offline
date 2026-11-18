import 'package:flutter/material.dart';

import 'activities/math/registry.dart';
import 'activities/science/registry.dart';

Widget? localActivity(Map<String, dynamic> activity) {
  final id = localMappingId(activity);
  return mathActivityWidgets[id] ?? scienceActivityWidgets[id];
}

bool supportsLocalActivity(Map<String, dynamic> activity) =>
    localActivity(activity) != null;

int? localMappingId(Map<String, dynamic> activity) => int.tryParse(
  '${activity['mapping_id'] ?? (activity['activity_data'] is Map ? activity['activity_data']['mapping_id'] : null) ?? activity['id']}',
);

String? localActivityZone(Map<String, dynamic> activity) {
  final id = localMappingId(activity);
  if (mathActivityWidgets.containsKey(id)) return 'math';
  if (scienceActivityWidgets.containsKey(id)) return 'science';
  return null;
}
