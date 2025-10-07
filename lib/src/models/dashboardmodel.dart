class DashboardModel {
  final Map<String, dynamic> summary;
  final Map<String, List<Map<String, dynamic>>> tables;
  final Map<String, dynamic> charts;

  DashboardModel({
    required this.summary,
    required this.tables,
    required this.charts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      summary: Map<String, dynamic>.from(json['summary'] ?? {}),
      tables: (json['tables'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          key,
          List<Map<String, dynamic>>.from(
            (value as List).map((e) => Map<String, dynamic>.from(e)),
          ),
        ),
      ),
      charts: Map<String, dynamic>.from(json['charts'] ?? {}),
    );
  }
}
