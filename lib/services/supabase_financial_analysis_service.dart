import 'dart:io';

import '../models/financial_insight.dart';
import './financial_analysis_service.dart';
import './supabase_service.dart';

class SupabaseFinancialAnalysisService extends FinancialAnalysisService {
  static final SupabaseService _supabase = SupabaseService.instance;

  @override
  Future<FinancialReport> analyzePDF(File pdfFile) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      // First perform the AI analysis
      final report = await super.analyzePDF(pdfFile);

      // Save to Supabase
      final savedReport = await _saveReportToDatabase(report);
      return savedReport;
    } catch (e) {
      throw Exception('Failed to analyze and save PDF: $e');
    }
  }

  @override
  Stream<String> streamAnalysis(File pdfFile) async* {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      String fullAnalysis = '';
      
      await for (final chunk in super.streamAnalysis(pdfFile)) {
        fullAnalysis += chunk;
        yield chunk;
      }

      // After streaming is complete, save the report
      try {
        final report = await super.analyzePDF(pdfFile);
        await _saveReportToDatabase(report);
      } catch (e) {
        // Don't stop the stream if saving fails
        print('Failed to save streamed analysis: $e');
      }
    } catch (e) {
      throw Exception('Failed to stream analysis: $e');
    }
  }

  // Save financial report to database
  Future<FinancialReport> _saveReportToDatabase(FinancialReport report) async {
    try {
      // Insert financial report
      final reportData = {
        'user_id': _supabase.currentUser!.id,
        'file_name': report.fileName,
        'company_name': report.companyName,
        'report_period': report.reportPeriod,
        'key_metrics': report.keyMetrics,
        'analysis_date': report.analysisDate.toIso8601String(),
      };

      final reportResponse = await _supabase
          .insert('financial_reports', reportData);

      final reportId = reportResponse['id'];

      // Insert financial insights
      for (final insight in report.insights) {
        final insightData = {
          'report_id': reportId,
          'category': insight.category,
          'title': insight.title,
          'description': insight.description,
          'insight_type': insight.type.name,
          'value': insight.value,
          'trend': insight.trend,
          'score': insight.score,
        };
        await _supabase.insert('financial_insights', insightData);
      }

      return FinancialReport(
        fileName: report.fileName,
        companyName: report.companyName,
        reportPeriod: report.reportPeriod,
        insights: report.insights,
        keyMetrics: report.keyMetrics,
        analysisDate: report.analysisDate,
        id: reportId);
    } catch (e) {
      throw Exception('Failed to save report to database: $e');
    }
  }

  // Get user's financial reports
  Future<List<FinancialReport>> getUserReports() async {
    if (!_supabase.isAuthenticated) return [];

    try {
      final response = await _supabase
          .from('financial_reports')
          .select('''
            *,
            financial_insights(*)
          ''')
          .eq('user_id', _supabase.currentUser!.id)
          .order('analysis_date', ascending: false);

      return (response as List).map((json) {
        final insights = (json['financial_insights'] as List)
            .map((insightJson) => FinancialInsight(
                  category: insightJson['category'],
                  title: insightJson['title'],
                  description: insightJson['description'],
                  type: InsightType.values.firstWhere(
                    (type) => type.name == insightJson['insight_type'],
                    orElse: () => InsightType.neutral),
                  value: insightJson['value'],
                  trend: insightJson['trend'],
                  score: insightJson['score']?.toDouble()))
            .toList();

        return FinancialReport(
          fileName: json['file_name'],
          companyName: json['company_name'],
          reportPeriod: json['report_period'],
          insights: insights,
          keyMetrics: json['key_metrics'] ?? {},
          analysisDate: DateTime.parse(json['analysis_date']),
          id: json['id']);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  // Get report by ID
  Future<FinancialReport?> getReportById(String reportId) async {
    if (!_supabase.isAuthenticated) return null;

    try {
      final response = await _supabase
          .from('financial_reports')
          .select('''
            *,
            financial_insights(*)
          ''')
          .eq('id', reportId)
          .eq('user_id', _supabase.currentUser!.id)
          .single();

      final insights = (response['financial_insights'] as List)
          .map((insightJson) => FinancialInsight(
                category: insightJson['category'],
                title: insightJson['title'],
                description: insightJson['description'],
                type: InsightType.values.firstWhere(
                  (type) => type.name == insightJson['insight_type'],
                  orElse: () => InsightType.neutral),
                value: insightJson['value'],
                trend: insightJson['trend'],
                score: insightJson['score']?.toDouble()))
          .toList();

      return FinancialReport(
        fileName: response['file_name'],
        companyName: response['company_name'],
        reportPeriod: response['report_period'],
        keyMetrics: response['key_metrics'] ?? {},
        analysisDate: DateTime.parse(response['analysis_date']),
        id: response['id'],
        insights: insights);
    } catch (e) {
      return null;
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    if (!_supabase.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase
          .from('financial_reports')
          .delete()
          .eq('id', reportId)
          .eq('user_id', _supabase.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Real-time subscription for report updates
  void subscribeToReportUpdates(void Function() onUpdate) {
    if (!_supabase.isAuthenticated) return;

    _supabase.subscribe(
      'financial_reports',
      callback: (payload) {
        if (payload.newRecord['user_id'] == _supabase.currentUser!.id ||
            payload.oldRecord['user_id'] == _supabase.currentUser!.id) {
          onUpdate();
        }
      });
  }
}