import 'package:flutter/material.dart';
import 'pdf_viewer_page.dart';
import 'youtube_list_page.dart';
import 'pdf_launcher_page.dart';

class KnowledgeHubPage extends StatelessWidget {
  static const routeName = '/knowledge-hub';

  const KnowledgeHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          // Tab bar directly below AppShell’s title
          TabBar(
            labelColor: Colors.teal,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'PDF'),
              Tab(icon: Icon(Icons.ondemand_video), text: 'YouTube'),
            ],
          ),
          // Fill remaining space
          Expanded(
            child: TabBarView(
              children: [
                PdfLauncherPage(),
                YoutubeListPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
