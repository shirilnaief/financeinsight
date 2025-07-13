import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/financial_insight.dart';
import '../../services/financial_analysis_service.dart';
import './widgets/analysis_stream_widget.dart';
import './widgets/insights_list_widget.dart';
import './widgets/key_metrics_widget.dart';
import './widgets/upload_section_widget.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  State<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  final FinancialAnalysisService _analysisService = FinancialAnalysisService();
  FinancialReport? _currentReport;
  bool _isAnalyzing = false;
  File? _selectedFile;
  bool _isStreamingMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analysis Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isStreamingMode ? Icons.stream : Icons.analytics),
            onPressed: () {
              setState(() {
                _isStreamingMode = !_isStreamingMode;
              });
              Fluttertoast.showToast(
                msg: _isStreamingMode
                    ? 'Streaming mode enabled'
                    : 'Standard analysis mode',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            tooltip: _isStreamingMode
                ? 'Switch to Standard Mode'
                : 'Switch to Streaming Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadSectionWidget(
              onFileSelected: _onFileSelected,
              isAnalyzing: _isAnalyzing,
              selectedFile: _selectedFile,
            ),
            const SizedBox(height: 24),
            if (_isAnalyzing && _isStreamingMode) ...[
              AnalysisStreamWidget(
                analysisStream: _analysisService.streamAnalysis(_selectedFile!),
              ),
              const SizedBox(height: 24),
            ],
            if (_currentReport != null) ...[
              KeyMetricsWidget(keyMetrics: _currentReport!.keyMetrics),
              const SizedBox(height: 24),
              InsightsListWidget(insights: _currentReport!.insights),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onFileSelected() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _isAnalyzing = true;
          _currentReport = null;
        });

        if (_isStreamingMode) {
          // Just set up for streaming, actual streaming handled by AnalysisStreamWidget
          Fluttertoast.showToast(
            msg: 'Starting streaming analysis...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          await _analyzeFile(file);
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      Fluttertoast.showToast(
        msg: 'Error selecting file: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _analyzeFile(File file) async {
    try {
      final report = await _analysisService.analyzePDF(file);

      setState(() {
        _currentReport = report;
        _isAnalyzing = false;
      });

      Fluttertoast.showToast(
        msg: 'Analysis completed successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      Fluttertoast.showToast(
        msg: 'Analysis failed: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
