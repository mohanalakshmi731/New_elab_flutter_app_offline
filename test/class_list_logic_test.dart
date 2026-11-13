import 'dart:convert';
import 'dart:typed_data';

import 'package:elab_app/features/classes/class_list_logic.dart';
import 'package:elab_app/features/classes/quizsys_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JS helpers', () {
    test('jsString / vueText / jsMember', () {
      expect(jsString(5.0), '5');
      expect(jsString(null), 'null');
      expect(vueText(null), '');
      expect(jsMember({'a': null}, 'a'), 'null');
      expect(jsMember({'a': '+91'}, 'b'), 'undefined');
      expect('${jsMember({'country_code': '+91'}, 'country_code')}${jsMember({'phone': '123'}, 'phone')}', '+91123');
    });

    test('jsLocaleDateString', () {
      expect(jsLocaleDateString('2024-03-05T10:00:00'), '3/5/2024');
      expect(jsLocaleDateString('not a date'), 'Invalid Date');
    });

    test('safeFileName / pdfFileName', () {
      expect(safeFileName('  Batch A / 2024: x  '), 'Batch-A-2024-x');
      expect(safeFileName('', 'fallback.pdf'), 'fallback.pdf');
      expect(safeFileName('--a--'), 'a');
      expect(pdfFileName('x'), 'x.pdf');
      expect(pdfFileName('x.PDF'), 'x.PDF');
    });

    test('digitsMax10', () {
      expect(digitsMax10('+91 98765-43210 11'), '9198765432');
    });
  });

  group('store mappings', () {
    test('mapClassItem uses counts', () {
      final m = mapClassItem({'id': 1, 'name': 'Grade 5', 'curricula_id': 7, 'status': 'published'},
          {'students_count': 3, 'admin_instructors_count': 2});
      expect(m['year'], 'Grade 5');
      expect(m['c_id'], 7);
      expect(m['students'], 3);
      expect(m['admins'], 2);
      expect(m['courses'], 0);
      expect(m['is_admin'], false);
    });

    test('searchClassRows unwraps data', () {
      expect(searchClassRows({'data': {'data': [{'id': 1}, null]}}).length, 1);
      expect(searchClassRows([{'id': 2}]).single['id'], 2);
    });

    test('mapBatch picks the active pivot and lowercases status', () {
      final b = mapBatch({
        'id': 1,
        'name': 'A',
        'status': 'Published',
        'students': [
          {'pivot': {'status': false}},
          {'pivot': {'status': true, 'x': 1}},
        ],
      });
      expect(b['status'], 'published');
      expect((b['pivot'] as Map)['x'], 1);
      expect(batchStatus(null), 'unknown');
    });

    test('mapStudent / pivotStudentList', () {
      final s = mapStudent({
        'id': 4,
        'status': 1,
        'user': {'first_name': 'Ann', 'last_name': '', 'email': 'a@x.io'},
        'batches': [
          {'name': 'B1', 'pivot': {'status': false}},
        ],
      });
      expect(s['name'], 'Ann');
      expect(s['status'], true);
      expect(s['batch'], 'B1');
      expect(s['pivot_status'], false);

      final res = {
        '0': {
          'id': 1,
          'user': {'first_name': 'A'},
          'batches': [
            {'id': '9', 'name': 'X', 'pivot': {'status': true}},
          ],
        },
        '1': {
          'id': 2,
          'batches': [
            {'id': 9, 'pivot': {'status': false}},
          ],
        },
        'batchName': null,
      };
      final list = pivotStudentList(res, 9);
      expect(list.map((e) => e['id']), [1]);
    });

    test('withUserFallback / mapAssignedInstructor', () {
      expect((withUserFallback({'id': 1})['user'] as Map)['first_name'], '');
      final a = mapAssignedInstructor({'id': 1, 'status': true, 'user': {'first_name': 'Z', 'email': null}});
      expect((a['user'] as Map)['email'], '');
      expect((a['user'] as Map)['status'], true);
    });
  });

  group('user search', () {
    test('searchRows variants', () {
      expect(searchRows({'data': [1]}).length, 1);
      expect(searchRows({'data': {'data': [1, 2]}}).length, 2);
      expect(searchRows([1, 2, 3]).length, 3);
      expect(searchRows('x'), isEmpty);
    });

    test('filterUserRows matches name, email or phone', () {
      final rows = [
        {'user': {'id': 1, 'first_name': 'John', 'last_name': 'Doe', 'email': 'j@x.io', 'phone': 555}},
        {'id': 2, 'first_name': 'Amy', 'email': 'amy@x.io'},
      ];
      expect(filterUserRows(rows, 'doe').single.id, 1);
      expect(filterUserRows(rows, '555').single.fullName, 'John Doe');
      expect(filterUserRows(rows, 'AMY').single.id, 2);
      expect(filterInstructorRows(rows, 'amy'), isEmpty);
    });

    test('splitResultName falls back to full_name', () {
      final n = splitResultName({'full_name': 'Ann Lee Smith'});
      expect(n.first, 'Ann');
      expect(n.last, 'Lee Smith');
    });
  });

  group('template filters', () {
    final batches = [
      {'id': 1, 'status': 'published'},
      {'id': 2, 'status': 'draft'},
    ];
    test('filterBatchesByStatus / noBatchMatches', () {
      expect(filterBatchesByStatus(batches, 'all').length, 2);
      expect(filterBatchesByStatus(batches, 'draft').single['id'], 2);
      expect(noBatchMatches(batches, 'draft', false), isTrue);
      expect(noBatchMatches(batches, 'draft', true), isFalse);
    });

    test('isStudentActive / studentHasQuizSysCard / activeStudentEmails', () {
      expect(isStudentActive('TRUE'), isTrue);
      expect(isStudentActive(false), isFalse);
      expect(studentHasQuizSysCard({'quizsys_marker_id': 0, 'quizsys_qr_svg': '<svg/>'}), isTrue);
      expect(studentHasQuizSysCard({'id': 1}), isFalse);
      expect(
        activeStudentEmails([
          {'status': true, 'pivot_status': true, 'email': 'a@x'},
          {'status': true, 'pivot_status': null, 'email': 'b@x'},
        ]),
        ['a@x'],
      );
    });

    test('applyImportUpdate updates or appends', () {
      var rows = applyImportUpdate([], {'email': 'a', 'status': 'processing', 'stages': {'user': {'status': 'processing'}}});
      expect(rows.single['userStage'], {'status': 'processing'});
      rows = applyImportUpdate(rows, {'email': 'a', 'status': 'done', 'stages': {'student': {'status': 'completed'}}});
      expect(rows.single['status'], 'done');
      expect(rows.single['userStage'], isNull);
      expect(rows.single['studentStage'], {'status': 'completed'});
    });
  });

  group('mini SVG', () {
    test('numbers, colours and styles', () {
      expect(parseSvgNumbers('1.5.5-2e1'), [1.5, 0.5, -20]);
      expect(parseSvgColor('#fff'), const Color(0xFFFFFFFF));
      expect(parseSvgColor('none'), isNull);
      expect(parseSvgColor('rgb(255,0,0)'), const Color(0xFFFF0000));
      expect(parseStyleDeclarations('fill: #000; stroke:none'), {'fill': '#000', 'stroke': 'none'});
    });

    test('path tokenizer', () {
      expect(tokenizeSvgPath('M0 0h1v1H0z'), ['M', 0.0, 0.0, 'h', 1.0, 'v', 1.0, 'H', 0.0, 'z']);
    });

    test('parses a QR-like SVG with classes and transforms', () {
      const svg = '<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">'
          '<defs><style>.dark{fill:#000}.light{fill:#fff}</style></defs>'
          '<rect width="10" height="10" class="light"/>'
          '<g transform="translate(1,1)"><path class="dark" d="M0 0h2v2h-2z M4 4h2v2h-2z"/></g>'
          '<rect x="0" y="0" width="0" height="1"/></svg>';
      final s = MiniSvg.parse(svg);
      expect(s.viewBox, const Rect.fromLTWH(0, 0, 10, 10));
      expect(s.shapes.length, 2);
      expect(s.shapes[0].fill, const Color(0xFFFFFFFF));
      expect(s.shapes[1].fill, const Color(0xFF000000));
      expect(s.shapes[1].path.getBounds(), const Rect.fromLTRB(1, 1, 7, 7));
    });

    test('rejects non-SVG input', () {
      expect(() => MiniSvg.parse('<div></div>'), throwsFormatException);
    });
  });

  test('buildImagePdf writes a valid xref', () {
    final pdf = buildImagePdf([PdfImagePage(2, 1, Uint8List.fromList([255, 255, 255, 0, 0, 0]))]);
    final text = latin1.decode(pdf);
    expect(text.startsWith('%PDF-1.4'), isTrue);
    expect(text, contains('/Count 1 /Kids [3 0 R]'));
    expect(text, contains('/Filter /FlateDecode'));
    final startxref = int.parse(RegExp(r'startxref\n(\d+)').firstMatch(text)!.group(1)!);
    expect(text.substring(startxref).startsWith('xref\n0 6'), isTrue);
    // Each xref offset points at "<n> 0 obj".
    final offsets = RegExp(r'(\d{10}) 00000 n').allMatches(text).map((m) => int.parse(m.group(1)!)).toList();
    for (var i = 0; i < offsets.length; i++) {
      expect(text.substring(offsets[i]).startsWith('${i + 1} 0 obj'), isTrue);
    }
    expect(rgbaToRgb(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8])), [1, 2, 3, 5, 6, 7]);
  });
}
