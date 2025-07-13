import 'dart:convert';
import 'dart:io';

import '../models/financial_insight.dart';
import './openai_client.dart';
import './openai_service.dart';

class FinancialAnalysisService {
  late final OpenAIClient _openAIClient;

  FinancialAnalysisService() {
    final openAIService = OpenAIService();
    _openAIClient = OpenAIClient(openAIService.dio);
  }

  Future<FinancialReport> analyzePDF(File pdfFile) async {
    try {
      // For demonstration, we'll use a mock analysis prompt
      // In a real implementation, you would extract text from the PDF first
      final analysisPrompt =
          _createAnalysisPrompt(pdfFile.path.split('/').last);

      final messages = [
        Message(
          role: 'system',
          content: _getSystemPrompt(),
        ),
        Message(
          role: 'user',
          content: analysisPrompt,
        ),
      ];

      final response = await _openAIClient.createChatCompletion(
        messages: messages,
        model: 'gpt-4o',
        options: {
          'temperature': 0.3,
          'max_tokens': 2000,
        },
      );

      return _parseAnalysisResponse(
          response.text, pdfFile.path.split('/').last);
    } catch (e) {
      throw Exception('Failed to analyze PDF: $e');
    }
  }

  Stream<String> streamAnalysis(File pdfFile) async* {
    try {
      final analysisPrompt =
          _createAnalysisPrompt(pdfFile.path.split('/').last);

      final messages = [
        Message(
          role: 'system',
          content: _getSystemPrompt(),
        ),
        Message(
          role: 'user',
          content: analysisPrompt,
        ),
      ];

      await for (final chunk in _openAIClient.streamContentOnly(
        messages: messages,
        model: 'gpt-4o',
        options: {
          'temperature': 0.3,
          'max_tokens': 2000,
        },
      )) {
        yield chunk;
      }
    } catch (e) {
      throw Exception('Failed to stream analysis: $e');
    }
  }

  String _getSystemPrompt() {
    return '''
You are a professional financial analyst AI specialized in analyzing annual reports and quarterly financial statements. Your task is to:

1. Identify key financial health indicators
2. Detect red flags such as falling margins, rising debt, declining revenue
3. Highlight important trends and patterns
4. Provide actionable insights for investors
5. Return analysis in structured JSON format

Focus on:
- Revenue trends and growth patterns
- Profitability margins (gross, operating, net)
- Debt levels and debt-to-equity ratios
- Cash flow patterns
- Working capital management
- Return on equity and assets
- Market position and competitive advantages
- Risk factors and potential concerns

Return your analysis in this JSON structure:
{
  "companyName": "Company Name",
  "reportPeriod": "Period (e.g., Q3 2024)",
  "insights": [
    {
      "category": "Revenue",
      "title": "Insight Title",
      "description": "Detailed description",
      "type": "positive|negative|neutral|warning",
      "value": "Specific value if applicable",
      "trend": "up|down|stable",
      "score": 0-100
    }
  ],
  "keyMetrics": {
    "revenue": "value",
    "netIncome": "value",
    "totalDebt": "value",
    "cashFlow": "value"
  }
}
''';
  }

  String _createAnalysisPrompt(String fileName) {
    return '''
Analyze this financial report: $fileName

Since I cannot access the actual PDF content in this demo, please provide a comprehensive financial analysis based on typical patterns found in annual reports and quarterly statements. 

Focus on creating realistic insights that would be valuable for investors, including:
- Revenue growth trends
- Margin analysis
- Debt management
- Cash flow health
- Profitability metrics
- Risk assessment

Please provide the analysis in the specified JSON format.
''';
  }

  FinancialReport _parseAnalysisResponse(String response, String fileName) {
    try {
      // Extract JSON from the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No valid JSON found in response');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      final jsonData = jsonDecode(jsonString);

      return FinancialReport(
        fileName: fileName,
        companyName: jsonData['companyName'] ?? 'Unknown Company',
        reportPeriod: jsonData['reportPeriod'] ?? 'Unknown Period',
        insights: (jsonData['insights'] as List<dynamic>?)
                ?.map((insight) => FinancialInsight.fromJson(insight))
                .toList() ??
            [],
        keyMetrics: jsonData['keyMetrics'] ?? {},
        analysisDate: DateTime.now(),
      );
    } catch (e) {
      // Fallback to creating a basic report if JSON parsing fails
      return FinancialReport(
        fileName: fileName,
        companyName: 'Analysis Error',
        reportPeriod: 'N/A',
        insights: [
          FinancialInsight(
            category: 'Analysis',
            title: 'Processing Error',
            description: 'Unable to parse analysis response: $e',
            type: InsightType.warning,
          ),
        ],
        keyMetrics: {},
        analysisDate: DateTime.now(),
      );
    }
  }
}
