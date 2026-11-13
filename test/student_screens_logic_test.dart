import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/features/student_dashboard_layout/student_dashboard_layout_logic.dart';
import 'package:elab_app/features/student_payment/student_payment_logic.dart';
import 'package:elab_app/features/student_reports/student_reports_logic.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _same(DateTime d) => d;
DateTime _ist(DateTime d) => d.toUtc().add(const Duration(hours: 5, minutes: 30));

void main() {
  group('studentpayment — totals', () {
    test('jsToFixed follows JS toFixed', () {
      expect(jsToFixed(1.005, 2), '1.00');
      expect(jsToFixed(2.5, 2), '2.50');
      expect(jsToFixed(-0.0, 2), '0.00');
      expect(jsToFixed(double.nan, 2), 'NaN');
      expect(jsToFixed(89.82, 2), '89.82');
    });

    test('subtotal, discount, 18% GST and grand total', () {
      final plans = [
        {'id': 1, 'price': '499'},
      ];
      final none = OrderTotals.of(plans, 0);
      expect(none.subtotal, 499);
      expect(none.discountAmount, '0.00');
      expect(none.gstAmount, '89.82');
      expect(none.grandTotal, '588.82');

      final ten = OrderTotals.of(plans, 10);
      expect(ten.discountAmount, '49.90');
      expect(ten.subtotalAfterDiscount, closeTo(449.1, 1e-9));
      expect(ten.gstAmount, '80.84');
      expect(ten.grandTotal, '529.94');

      expect(OrderTotals.of(const [], 0).grandTotal, '0.00');
    });
  });

  group('studentpayment — plans', () {
    test('rawPlansOf', () {
      expect(rawPlansOf([1]), [1]);
      expect(rawPlansOf({'data': [2]}), [2]);
      expect(rawPlansOf({'plans': [3]}), [3]);
      expect(rawPlansOf({}), isEmpty);
      expect(rawPlansOf({'data': {'data': []}}), isNull);
    });

    test('only active paid plans, normalised', () {
      final plans = paidPlansOf([
        {'id': 1, 'name': 'Class 5', 'price': 499, 'days': 365, 'all_classes': true, 'plan_type': 'paid', 'is_active': true, 'syllabus': ''},
        {'id': 2, 'name': 'Free', 'plan_type': 'free', 'is_active': true},
        {'id': 3, 'name': 'Inactive', 'plan_type': 'paid', 'is_active': 1},
        {'id': 4, 'name': 'No ref', 'plan_type': 'paid', 'is_active': true, 'syllabus': 'CBSE', 'allow_referral_code': false},
      ]);
      expect(plans.map((p) => p['id']), [1, 4]);
      expect(plans.first, {
        'id': 1,
        'class_name': 'Class 5',
        'price': 499,
        'duration': 365,
        'full_access': true,
        'syllabus': null,
        'allow_referral_code': null,
      });
      expect(plans.last['syllabus'], 'CBSE');
      expect(showReferralCodeSection([plans.first]), isTrue);
      expect(showReferralCodeSection([plans.last]), isFalse);
      expect(showReferralCodeSection(const []), isFalse);
    });

    test('currentPlanName', () {
      final plans = [
        {'id': 7, 'class_name': 'Gold'},
      ];
      expect(currentPlanName({'subscription': {'subscription_plan_id': 7}}, plans), 'Gold');
      expect(currentPlanName({'subscription': {'subscription_plan_id': '7'}}, plans), 'Active Plan');
      expect(currentPlanName(null, plans), 'Active Plan');
    });
  });

  group('studentpayment — order and status', () {
    test('payment URL: payment_link || url || data.url', () {
      expect(studentPaymentUrl({'url': 'u', 'payment_link': 'p'}), 'p');
      expect(studentPaymentUrl({'url': 'u'}), 'u');
      expect(studentPaymentUrl({'data': {'url': 'd'}}), 'd');
      expect(studentPaymentUrl({}), isNull);
    });

    test('poll status normalisation', () {
      final ok = PollReading.of({
        'data': {
          'data': {'status': ' SUCCESS ', 'amount': 588.82, 'transaction_id': 'T1'},
        },
      });
      expect(ok.outcome, PollOutcome.success);
      expect(ok.amount, 588.82);
      expect(ok.transactionId('O1'), 'T1');

      final abandoned = PollReading.of({
        'payment': {'order_status': 'Abandoned'},
      });
      expect(abandoned.outcome, PollOutcome.failed);
      expect(abandoned.failureToast, 'Payment abandoned.');
      expect(abandoned.failureMessage, 'Payment was not completed.');
      expect(abandoned.transactionId('O2'), 'O2');

      final failed = PollReading.of({'status': 'failed', 'message': 'Declined', 'price': 10});
      expect(failed.outcome, PollOutcome.failed);
      expect(failed.failureToast, 'Payment failed.');
      expect(failed.failureMessage, 'Declined');
      expect(failed.amount, 10);

      expect(PollReading.of({'status': 'pending'}).outcome, PollOutcome.pending);
      expect(PollReading.of(null).status, '');
      expect(PollReading.of({'payment_status': 'buyed'}).outcome, PollOutcome.success);
    });
  });

  group('studentpayment — history and invoice', () {
    test('history newest first', () {
      expect(historyFromResponse([1, 2, 3]), [3, 2, 1]);
      expect(historyFromResponse({'payments': [1, 2]}), [2, 1]);
      expect(historyFromResponse({}), isEmpty);
      expect(historyFromResponse({'data': {'data': []}}), isNull);
    });

    test('status labels', () {
      expect(payStatusLabel({'status': 'Completed'}), 'Paid');
      expect(payStatusLabel({'order_status': 'cancelled'}), 'Failed');
      expect(payStatusLabel({'status': 'abondand'}), 'Abandoned');
      expect(payStatusLabel({'status': 'initiated'}), 'Initiated');
      expect(payStatusLabel({'status': 'refunded'}), 'refunded');
      expect(payStatusLabel({}), 'Unknown');
      expect(payStatusKind({'status': 'paid'}), PayStatusKind.paid);
      expect(payStatusKind({'status': 'pending'}), PayStatusKind.other);
    });

    test('totalWithGst', () {
      expect(totalWithGst({'amount': '100'}), '118.00');
      expect(totalWithGst({'amount': '100', 'final_amount': '118.5'}), '118.50');
      expect(totalWithGst({'final_amount': 59}), '59.00');
      expect(totalWithGst({}), '—');
      expect(totalWithGst({'amount': 'abc'}), '—');
    });

    test('invoice helpers', () {
      expect(invoiceOrderId({'id': 5, 'transaction_id': 'T'}), '5');
      expect(invoiceOrderId({}), isNull);
      expect(mergeInvoice({'a': 1, 'b': 1}, {'data': {'b': 2}}), {'a': 1, 'b': 2});
      expect(mergeInvoice({'a': 1}, {'c': 3}), {'a': 1, 'c': 3});
      expect(invoiceTotal({'final_amount': 0, 'amount': 100}), '0');
      expect(invoiceTotal({'amount': 100}), '118.00');
      expect(invoiceGstPercentage({}), '18');
      expect(invoiceGstAmount({'gst_amount': '18'}), '₹18.00');
      expect(invoiceGstAmount({}), '₹0.00');
      expect(
          invoicePlanName({
            'subscription_plans': [
              {'name': 'Gold'},
            ],
          }),
          'Gold');
      expect(invoicePlanName({'plan_name': 'P'}), 'P');
      expect(invoicePlanName({}), 'Subscription Plan');

      final rows = invoiceRows({'order_id': 'O', 'status': 'paid'}, toLocal: _same);
      final visible = {for (final r in rows) if (r.visible) r.key: '${r.value}'};
      expect(visible, {'order': 'O', 'currency': 'INR', 'status': 'Paid'});
    });

    test('formatPaymentDate (en-IN)', () {
      expect(formatPaymentDate('2026-11-12T15:45:00Z', toLocal: _same), '12 Nov 2026, 03:45 pm');
      expect(formatPaymentDate('2026-11-12T00:05:00.000000Z', toLocal: _same), '12 Nov 2026, 12:05 am');
      // ISO date-only strings are UTC, like JS.
      expect(formatPaymentDate('2026-09-01', toLocal: _ist), '1 Sept 2026, 05:30 am');
      expect(formatPaymentDate('not a date'), 'not a date');
      expect(formatPaymentDate(null), '');
    });

    test('error messages', () {
      expect(jsErrorMessage(const ApiError('Institute ID not available'), 'x'), 'Institute ID not available');
      expect(jsErrorMessage(Exception(), 'Failed to load plans'), 'Failed to load plans');
      expect(referralErrorText(const ApiError('')), 'Invalid referral code');
    });
  });

  group('studentdashbaordlayout', () {
    test('available exams', () {
      final exams = [
        {'id': 1, 'exam_type': 'EXAM', 'status': 'scheduled', 'max_attempts': 2},
        {'id': 2, 'exam_type': 'quiz', 'status': 'SCHEDULED'},
        {'id': 3, 'exam_type': 'EXAM', 'status': 'DRAFT'},
        {'id': 4, 'exam_type': 'Exam', 'status': 'Scheduled'},
        {'id': 5, 'exam_type': 'EXAM', 'status': 'SCHEDULED', 'max_attempts': '3'},
      ];
      final attempts = [
        {'exam_id': 1, 'status': 'SUBMITTED'},
        {'exam_id': '4', 'status': 'submitted'},
        {
          'exam': {'id': 5},
          'status': 'SUBMITTED',
        },
        {'exam_id': 5, 'status': 'IN_PROGRESS'},
      ];
      expect(availableExams(exams, attempts).map((e) => e['id']), [1, 5]);
      expect(availableExams(exams, const []).map((e) => e['id']), [1, 4, 5]);
      expect(examArrayOf({'data': [1]}), [1]);
      expect(examArrayOf(null), isEmpty);
    });

    test('exam helpers', () {
      expect(examTypeKind({'exam_type': 'practice'}), ExamTypeKind.practice);
      expect(examTypeKind({}), ExamTypeKind.exam);
      expect(examStatusKind('ongoing'), ExamStatusKind.ongoing);
      expect(examStatusKind(null), ExamStatusKind.other);
      expect(fmtExamDate('2026-11-05T10:00:00Z', toLocal: _same), '05 Nov 2026');
      expect(fmtExamDate('2026-09-30', toLocal: _ist), '30 Sept 2026');
      expect(fmtExamDate('soon'), 'Invalid Date');
      expect(fmtExamDate(''), '—');
      expect(examDurationLabel({'duration_minutes': 45}), '45 min');
      expect(examDurationLabel({'duration_minutes': 0}), '—');
    });
  });

  group('studentreports — ranges', () {
    // Wednesday 11 Nov 2026, 10:00 local.
    final now = DateTime(2026, 11, 11, 10);

    test('date ranges in UTC (offset 0)', () {
      String r(String key) {
        final x = reportRange(key, now, utcOffset: Duration.zero);
        return '${x.from}..${x.to}';
      }

      expect(r('today'), '2026-11-11..2026-11-11');
      expect(r('this_week'), '2026-11-09..2026-11-11');
      expect(r('last_week'), '2026-11-02..2026-11-08');
      expect(r('past_30'), '2026-10-13..2026-11-11');
      expect(r('this_month'), '2026-11-01..2026-11-11');
      expect(r('last_month'), '2026-10-01..2026-10-31');
    });

    test('toISOString shifts the start date in IST (as on the web)', () {
      const ist = Duration(hours: 5, minutes: 30);
      final today = reportRange('today', now, utcOffset: ist);
      expect(today.from, '2026-11-10');
      expect(today.to, '2026-11-11');
      final sunday = reportRange('this_week', DateTime(2026, 11, 15, 9), utcOffset: Duration.zero);
      expect(sunday.from, '2026-11-09');
      expect(reportRangeLabel('past_30'), 'Past 30 Days');
      expect(reportRangeLabel('nope'), 'This Week');
      expect(yearRange(now), (from: '2026-01-01', to: '2026-12-31'));
    });
  });

  group('studentreports — aggregation', () {
    test('parseUsageString / formatReportMinutes / dayLabel', () {
      expect(parseUsageString('1h 20m 40s'), 81);
      expect(parseUsageString('30s'), 1);
      expect(parseUsageString('29s'), 0);
      expect(parseUsageString('2 h'), 120);
      expect(parseUsageString(''), 0);
      expect(parseUsageString(null), 0);
      expect(formatReportMinutes(0), '0m');
      expect(formatReportMinutes(45), '45m');
      expect(formatReportMinutes(120), '2h');
      expect(formatReportMinutes(65.0), '1h 5m');
      expect(dayLabel('2026-11-09', 3), 'Mon');
      expect(dayLabel('2026-11-15', 7), 'Sun');
      expect(dayLabel('2026-11-09', 8), '11/9');
    });

    test('usage response → chart series and yearly total', () {
      final data = [
        {'period': '2026-11-09', 'total_usage': '1h 5m'},
        {'period': '2026-11-10', 'total_usage': '20m 30s'},
      ];
      final mapped = mapUsageResponse(data);
      expect(mapped.labels, ['Mon', 'Tue']);
      expect(mapped.minutes, [65, 21]);
      expect(mapUsageResponse({'data': data}).labels, isEmpty);
      expect(yearlyTotalMinutes(data), 86);
      expect(yearlyTotalMinutes(null), 0);
    });

    test('activity stats → per-day minutes and pills', () {
      final report = mapActivityResponse({
        '12': {
          'user': {'name': 'A'},
          'science_lab': {
            '2026-11-10': {'duration': 600},
            '2026-11-09': {'duration': 90},
          },
          'math_play': {
            'chapter': {
              '2026-11-10': {'duration': 120},
            },
          },
          'ignored': 5,
        },
      });
      expect(report.labels, ['Mon', 'Tue']);
      expect(report.minutes, [2, 12]);
      expect(report.counts, [1, 1]);
      expect(report.summary.map((p) => '${p.label}=${p.value}'),
          ['Total Time=14m', 'Active Days=2', 'Peak Day=2026-11-10']);
    });

    test('peak day tie keeps the first inserted date (web quirk)', () {
      final report = mapActivityResponse({
        '1': {
          'a': {
            '2026-11-10': {'duration': 60},
            '2026-11-09': {'duration': 60},
          },
        },
      });
      expect(report.summary.last.value, '2026-11-10');
    });

    test('empty activity response', () {
      final report = mapActivityResponse([]);
      expect(report.labels, isEmpty);
      expect(report.summary.map((p) => p.value), ['0m', '0']);
    });

    test('chart axes', () {
      final empty = usageAxis(const []);
      expect([empty.max, empty.interval], [1.2, 0.2]);
      final hundred = usageAxis(const [100, 40]);
      expect([hundred.max, hundred.interval], [120, 20]);
      final small = usageAxis(const [45]);
      expect([small.max, small.interval], [60, 10]);
      final a = activityAxis(const []);
      expect([a.max, a.interval], [10, 2]);
      final b = activityAxis(const [37, 4]);
      expect([b.max, b.interval], [37, 8]);
    });
  });
}
