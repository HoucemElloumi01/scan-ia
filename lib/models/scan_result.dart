import 'dart:convert';

class ScanResult {
  final String text;
  final String language;

  ScanResult({required this.text, required this.language});

  Map<String, dynamic> toJson() {
    return {'text': text, 'language': language};
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(text: json['text'], language: json['language']);
  }

  static String encode(List<ScanResult> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ScanResult> decode(String data) =>
      (jsonDecode(data) as List<dynamic>)
          .map((e) => ScanResult.fromJson(e))
          .toList();
}
