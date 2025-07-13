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

  FinancialReport({
    required this.fileName,
    required this.companyName,
    required this.reportPeriod,
    required this.insights,
    required this.keyMetrics,
    required this.analysisDate,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      fileName: json['fileName'] ?? '',
      companyName: json['companyName'] ?? '',
      reportPeriod: json['reportPeriod'] ?? '',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((insight) => FinancialInsight.fromJson(insight))
              .toList() ??
          [],
      keyMetrics: json['keyMetrics'] ?? {},
      analysisDate: DateTime.parse(json['analysisDate']),
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
    };
  }
}
