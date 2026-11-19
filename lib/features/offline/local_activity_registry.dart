import 'package:flutter/material.dart';

import 'activities/math/registry.dart';
import 'activities/class7/math/registry.dart';
import 'activities/class7/science/registry.dart';
import 'activities/class8/math/registry.dart';
import 'activities/class8/science/registry.dart';
import 'activities/class9/math/registry.dart';
import 'activities/class9/science/registry.dart';
import 'activities/science/registry.dart';

Widget? localActivity(Map<String, dynamic> activity) {
  final id = localMappingId(activity);
  return mathActivityWidgets[id] ??
      scienceActivityWidgets[id] ??
      class9MathActivityWidgets[id] ??
      class9ScienceActivityWidgets[id] ??
      class8MathActivityWidgets[id] ??
      class8ScienceActivityWidgets[id] ??
      class7MathActivityWidgets[id] ??
      class7ScienceActivityWidgets[id];
}

bool supportsLocalActivity(Map<String, dynamic> activity) =>
    localActivity(activity) != null;

int? localMappingId(Map<String, dynamic> activity) => int.tryParse(
  '${activity['mapping_id'] ?? (activity['activity_data'] is Map ? activity['activity_data']['mapping_id'] : null) ?? activity['id']}',
);

String? localActivityZone(Map<String, dynamic> activity) {
  final id = localMappingId(activity);
  if (mathActivityWidgets.containsKey(id) ||
      class9MathActivityWidgets.containsKey(id) ||
      class8MathActivityWidgets.containsKey(id) ||
      class7MathActivityWidgets.containsKey(id))
    return 'math';
  if (scienceActivityWidgets.containsKey(id) ||
      class9ScienceActivityWidgets.containsKey(id) ||
      class8ScienceActivityWidgets.containsKey(id) ||
      class7ScienceActivityWidgets.containsKey(id))
    return 'science';
  return null;
}
