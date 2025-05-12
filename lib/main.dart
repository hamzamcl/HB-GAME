import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'pages/history_page.dart';

/// Jeu de Toro et Vache
/// 
/// Un jeu de déduction où le joueur doit deviner un nombre à 4 chiffres.
/// - Toro : chiffre correct à la bonne position
/// - Vache : chiffre correct mais mal placé
/// 
/// Règles :
/// - Le nombre contient 4 chiffres différents
/// - Le premier chiffre ne peut pas être 0
/// - Pour chaque essai, le jeu indique :
///   * Le nombre de Toro (chiffres bien placés)
///   * Le nombre de Vache (chiffres présents mais mal placés)
void main() {
  runApp(const ToroVacheApp());
}

class ToroVacheApp extends StatelessWidget {
  const ToroVacheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu Toro et Vache',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Page d'accueil du jeu
/// 
/// Permet au joueur de :
/// - Saisir son nom
/// - Commencer une nouvelle partie
/// - Consulter l'historique des parties
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cow-and-bull.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'TORO ET VACHE',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre nom',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  if (_nameController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePage(
                          playerName: _nameController.text,
                        ),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    'assets/animations/play_button.json',
                    repeat: true,
                    reverse: true,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Historique'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

/// Page principale du jeu
/// 
/// Fonctionnalités :
/// - Affichage du nombre à deviner (caché)
/// - Clavier numérique pour la saisie
/// - Historique des tentatives
/// - Sauvegarde des scores
/// - Système de record
class GamePage extends StatefulWidget {
  final String playerName;

  const GamePage({super.key, required this.playerName});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String _secret = '';
  List<String> _history = [];
  bool _gameOver = false;
  String _currentGuess = '';

  @override
  void initState() {
    super.initState();
    _secret = _generateSecretNumber();
  }

  void _onNumberPress(String number) {
    if (_currentGuess.length < 4 && !_gameOver) {
      setState(() {
        if (!_currentGuess.contains(number)) {
          _currentGuess += number;
        }
      });
    }
  }

  void _onDelete() {
    if (_currentGuess.isNotEmpty) {
      setState(() {
        _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
      });
    }
  }

  void _onSubmit() {
    if (_currentGuess.length == 4) {
      _checkGuess(_currentGuess);
      setState(() {
        _currentGuess = '';
      });
    } else {
      _showError("Entrez 4 chiffres différents.");
    }
  }

  /// Vérifie si la tentative est valide et calcule les Toro et Vache
  void _checkGuess(String guess) {
    if (guess.length != 4 || guess.split('').toSet().length != 4) {
      _showError("Entrez 4 chiffres différents.");
      return;
    }

    int toro = 0, vache = 0;
    for (int i = 0; i < 4; i++) {
      if (guess[i] == _secret[i]) {
        toro++;
      } else if (_secret.contains(guess[i])) {
        vache++;
      }
    }

    setState(() {
      _history.insert(0, '$guess → $toro Toro, $vache Vache');
      if (toro == 4) {
        _gameOver = true;
        _showVictoryDialog();
      }
    });
  }

  /// Génère un nombre secret valide de 4 chiffres différents
  String _generateSecretNumber() {
    final rand = Random();
    Set<int> digits = {};
    while (digits.length < 4) {
      int digit = rand.nextInt(10);
      if (digits.isEmpty && digit == 0) continue;
      digits.add(digit);
    }
    return digits.join();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Sauvegarde le score si c'est un nouveau record
  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBestScore = prefs.getString('bestScore');
    final attempts = _history.length;

    if (currentBestScore == null || attempts < int.parse(currentBestScore)) {
      await prefs.setString('bestScore', attempts.toString());
      await prefs.setString('bestPlayer', widget.playerName);
    }
  }

  /// Enregistre la partie dans l'historique
  Future<void> _saveGameToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('gameHistory') ?? [];
    
    final gameData = {
      'playerName': widget.playerName,
      'secretNumber': _secret,
      'attempts': _history.length,
      'date': DateTime.now().toString().substring(0, 16),
    };

    history.add(json.encode(gameData));
    await prefs.setStringList('gameHistory', history);
  }

  void _showVictoryDialog() {
    _saveGameToHistory();
    _saveScore();
    final attempts = _history.length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Félicitations !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/victory.json',
              width: 150,
              height: 150,
              repeat: true,
            ),
            Text('Bravo ${widget.playerName} !'),
            Text('Vous avez trouvé en $attempts coups.'),
            Text('Le nombre était : $_secret'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('Rejouer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Menu Principal'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _secret = _generateSecretNumber();
      _history.clear();
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu Toro et Vache'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildGameArea(),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo),
        ),
        child: Column(
          children: [
            _buildGuessDisplay(),
            const SizedBox(height: 20),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Expanded(
      child: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final parts = _history[index].split(' → ');
          return Card(
            child: ListTile(
              title: Text(
                parts[0],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                parts[1],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3', '4', '5'].map((e) => _buildKeypadButton(e)).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['6', '7', '8', '9', '0'].map((e) => _buildKeypadButton(e)).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _onDelete,
                child: const Icon(Icons.backspace),
              ),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Valider'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return ElevatedButton(
      onPressed: () => _onNumberPress(number),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildGuessDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.indigo),
          ),
          child: Center(
            child: Text(
              index < _currentGuess.length ? _currentGuess[index] : '',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
