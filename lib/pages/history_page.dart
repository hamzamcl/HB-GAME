import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> gameHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('gameHistory') ?? [];
    setState(() {
      gameHistory = history
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des parties'),
        centerTitle: true,
      ),
      body: gameHistory.isEmpty
          ? const Center(
              child: Text(
                'Aucune partie jouée',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: gameHistory.length,
              itemBuilder: (context, index) {
                final game = gameHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${game['attempts']}'),
                    ),
                    title: Text(game['playerName']),
                    subtitle: Text(
                      'Nombre secret: ${game['secretNumber']}',
                    ),
                    trailing: Text(
                      game['date'],
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
