class FinancialInsight {
  final String category;
  final String title;
  final String description;
  final InsightType type;
  final String? value;
  final String? trend;
  final double? score;

  FinancialInsight({
    required this.category,
    required this.title,
    required this.description,
    required this.type,
    this.value,
    this.trend,
    this.score,
  });

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: InsightType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => InsightType.neutral,
      ),
      value: json['value'],
      trend: json['trend'],
      score: json['score']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'description': description,
      'type': type.name,
      'value': value,
      'trend': trend,
      'score': score,
    };
  }
}

enum InsightType {
  positive,
  negative,
  neutral,
  warning,
}

class FinancialReport {
  final String fileName;
  final String companyName;
  final String reportPeriod;
  final List<FinancialInsight> insights;
  final Map<String, dynamic> keyMetrics;
  final DateTime analysisDate;
  final String? id; // Supabase ID

  FinancialReport({
    required this.fileName,
    required this.companyName,
    required this.reportPeriod,
    required this.insights,
    required this.keyMetrics,
    required this.analysisDate,
    this.id,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      fileName: json['fileName'] ?? json['file_name'] ?? '',
      companyName: json['companyName'] ?? json['company_name'] ?? '',
      reportPeriod: json['reportPeriod'] ?? json['report_period'] ?? '',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((insight) => FinancialInsight.fromJson(insight))
              .toList() ??
          [],
      keyMetrics: json['keyMetrics'] ?? json['key_metrics'] ?? {},
      analysisDate: json['analysisDate'] != null
          ? DateTime.parse(json['analysisDate'])
          : json['analysis_date'] != null
              ? DateTime.parse(json['analysis_date'])
              : DateTime.now(),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'companyName': companyName,
      'reportPeriod': reportPeriod,
      'insights': insights.map((insight) => insight.toJson()).toList(),
      'keyMetrics': keyMetrics,
      'analysisDate': analysisDate.toIso8601String(),
      'id': id,
    };
  }

  // Convert to Supabase format
  Map<String, dynamic> toSupabaseJson() {
    return {
      'file_name': fileName,
      'company_name': companyName,
      'report_period': reportPeriod,
      'key_metrics': keyMetrics,
      'analysis_date': analysisDate.toIso8601String(),
      if (id != null) 'id': id,
    };
  }

  FinancialReport copyWith({
    String? fileName,
    String? companyName,
    String? reportPeriod,
    List<FinancialInsight>? insights,
    Map<String, dynamic>? keyMetrics,
    DateTime? analysisDate,
    String? id,
  }) {
    return FinancialReport(
      fileName: fileName ?? this.fileName,
      companyName: companyName ?? this.companyName,
      reportPeriod: reportPeriod ?? this.reportPeriod,
      insights: insights ?? this.insights,
      keyMetrics: keyMetrics ?? this.keyMetrics,
      analysisDate: analysisDate ?? this.analysisDate,
      id: id ?? this.id,
    );
  }
}
