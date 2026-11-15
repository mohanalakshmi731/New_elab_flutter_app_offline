import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transient activity identity. The authenticated session is never replaced.
class LabPractice {
  const LabPractice({
    required this.token,
    this.practice = false,
    this.classId,
    this.batchId,
    this.student,
  });
  final String token;
  final bool practice;
  final int? classId;
  final int? batchId;
  final Map<String, dynamic>? student;

  bool get ready => !practice || student != null;

  Map<String, dynamic> apply(Map<String, dynamic> payload) {
    if (!practice) return payload;
    if (!ready) throw StateError('Select a student before starting practice.');
    return {
      ...payload,
      'lab_mode': 'practice',
      'lab_class_id': classId,
      'lab_batch_id': batchId,
      'student_id': student!['id'],
      'instructor_id': null,
      'sub_user_id': student!['zsl_id'],
      'classes_id': student!['zsl_class_id'],
    };
  }
}

class LabPracticeController extends Notifier<LabPractice?> {
  @override
  LabPractice? build() => null;
  void set(LabPractice? value) => state = value;
}

final labPracticeProvider =
    NotifierProvider<LabPracticeController, LabPractice?>(
      LabPracticeController.new,
    );

const labIdentityPaths = {
  '/zsl/signed/link',
  '/tracking/activity',
  '/usage-tracking/record',
  '/zsl/attempt-quiz',
  '/zsl/record-activity-performance',
};
