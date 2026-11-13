import 'package:elab_app/core/utils/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('visiblePageGroup (userlist.vue visiblePages)', () {
    test('single page', () {
      expect(visiblePageGroup(1, 1, 10), [1]);
      expect(visiblePageGroup(1, 0, 10), [1]);
    });

    test('first group of 10', () {
      expect(visiblePageGroup(3, 25, 10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('later group stops at last page', () {
      expect(visiblePageGroup(21, 25, 10), [21, 22, 23, 24, 25]);
      expect(visiblePageGroup(10, 25, 10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(visiblePageGroup(11, 25, 10), [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
    });

    test('mobile groups of 5', () {
      expect(visiblePageGroup(7, 12, 5), [6, 7, 8, 9, 10]);
      expect(visiblePageGroup(12, 12, 5), [11, 12]);
    });
  });

  group('PageMeta.find', () {
    test('root paginator', () {
      final m = PageMeta.find({'current_page': 2, 'last_page': 5, 'per_page': 15, 'total': 70, 'data': []});
      expect(m!.currentPage, 2);
      expect(m.lastPage, 5);
      expect(m.perPage, 15);
      expect(m.total, 70);
    });

    test('nested under data', () {
      final m = PageMeta.find({
        'status': true,
        'data': {'current_page': '3', 'last_page': '4', 'per_page': '10', 'total': '33', 'data': []},
      });
      expect(m!.currentPage, 3);
      expect(m.lastPage, 4);
      expect(m.total, 33);
    });

    test('API resource meta', () {
      final m = PageMeta.find({'data': [], 'meta': {'current_page': 1, 'last_page': 9, 'per_page': 10, 'total': 88}});
      expect(m!.lastPage, 9);
    });

    test('unpaginated list → null', () {
      expect(PageMeta.find([1, 2, 3]), isNull);
      expect(PageMeta.find({'data': [1, 2]}), isNull);
    });

    test('last_page is at least 1', () {
      expect(PageMeta.find({'current_page': 1, 'last_page': 0})!.lastPage, 1);
    });
  });
}
