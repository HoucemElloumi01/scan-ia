import 'package:flutter/material.dart';
import 'package:project/widgets/CustomAppBar.dart';
import '../models/scan_result.dart';
import '../services/feedback_service.dart';
import '../services/storage_service.dart';
import '../utils/app_text.dart';

class HistoryView extends StatefulWidget {
  final String language;

  const HistoryView({super.key, required this.language});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final StorageService storage = StorageService();
  final FeedbackService feedback = FeedbackService();

  List<ScanResult> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await storage.getResults();

    setState(() {
      history = data;
    });
  }

  Future<void> clearHistory() async {
    await storage.clear();

    loadHistory();
  }

  Future<void> deleteItem(int index) async {
    await storage.deleteOne(index);
    await feedback.playDelete();
    loadHistory(); // refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppText.get(widget.language, "history"),
        icon: Icons.history,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: clearHistory,
          ),
        ],
      ),

      body: history.isEmpty
          ? Center(
              child: Text("${AppText.get(widget.language, "no_history")} 📭"),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      item.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${AppText.get(widget.language, "language_label")}: ${item.language}",
                    ),

                    // 🔥 bouton supprimer
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteItem(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
