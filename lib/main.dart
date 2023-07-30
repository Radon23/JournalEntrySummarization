import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(JournalApp());
}

class JournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class JournalEntry {
  final String title;
  final String entry;
  final String summary;
  final DateTime timestamp;

  JournalEntry({
    required this.title,
    required this.entry,
    required this.summary,
    required this.timestamp,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<JournalEntry> journalEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: journalEntries.length,
                itemBuilder: (context, index) {
                  final entry = journalEntries[index];
                  final formattedDate = DateFormat('MMM dd, yyyy').format(entry.timestamp);
                  final formattedTime = DateFormat('h:mm a').format(entry.timestamp);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        entry.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),
                      subtitle: Text(
                        '$formattedDate - $formattedTime',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown[700],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EntryDetailsPage(entry)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text(
                'Create New Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              onPressed: () async {
                final entry = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EntryFormPage()),
                );

                if (entry != null) {
                  setState(() {
                    journalEntries.insert(0, entry);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EntryFormPage extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _entryEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Journal Entry'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleEditingController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _entryEditingController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter your journal entry',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text(
                'Save Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              onPressed: () async{
                final title = _titleEditingController.text;
                final entry = _entryEditingController.text;
                final timestamp = DateTime.now();
                // final summary = generateSummary(title, entry);
                final summary = await generateSummary(title, entry);

                Navigator.pop(
                  context,
                  JournalEntry(title: title, entry: entry, summary: summary, timestamp: timestamp),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future generateSummary(String title, String content) async {
    BaseOptions options = BaseOptions(
      baseUrl: "http://radon23.pythonanywhere.com",
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 20000),);
    Dio dio =  Dio(options);
    Map<String, String> params = {};
    params['article'] = content;
    var response = await dio.post("/summary", data: FormData.fromMap(params));
    String summary = response.data['summary'];
    return summary ;
  }
}

class EntryDetailsPage extends StatelessWidget {
  final JournalEntry entry;

  EntryDetailsPage(this.entry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entry Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              entry.entry,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                child: Text(
                  'View Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SummaryPage(entry.summary)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SummaryPage extends StatelessWidget {
  final String summary;

  SummaryPage(this.summary);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Summary:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  summary,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

