import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const LudoApp());

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LudoGame(),
    );
  }
}

class LudoGame extends StatefulWidget {
  const LudoGame({super.key});

  @override
  State<LudoGame> createState() => _LudoGameState();
}

class _LudoGameState extends State<LudoGame> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _players = [];
  final Map<String, int> _scores = {};
  final int _maxRounds = 5;
  int _currentRound = 1;
  int _currentPlayerIndex = 0;
  int _diceNumber = 1;
  bool _gameOver = false;

  final List<String> diceImages = [
    // NOTE: For this code to run, you must have assets/dice1.png to assets/dice6.png in your project.
    'assets/dice1.png',
    'assets/dice2.png',
    'assets/dice3.png',
    'assets/dice4.png',
    'assets/dice5.png',
    'assets/dice6.png',
  ];

  void _addPlayer() {
    String name = _nameController.text.trim();
    if (name.isNotEmpty && _players.length < 4) {
      setState(() {
        _players.add(name);
        _scores[name] = 0;
        _nameController.clear();
      });
    }
  }

  void _clearGame() {
    setState(() {
      _players.clear();
      _scores.clear();
      _currentRound = 1;
      _currentPlayerIndex = 0;
      _diceNumber = 1;
      _gameOver = false;
      _nameController.clear();
    });
  }

  void _rollDice() {
    if (_players.length < 2 || _gameOver) return;

    setState(() {
      _diceNumber = Random().nextInt(6) + 1;
      String currentPlayer = _players[_currentPlayerIndex];
      _scores[currentPlayer] = (_scores[currentPlayer] ?? 0) + _diceNumber;

      // Only move to next player if not a 6
      if (_diceNumber != 6) {
        _currentPlayerIndex++;
        if (_currentPlayerIndex >= _players.length) {
          _currentPlayerIndex = 0;
          _currentRound++;
          if (_currentRound > _maxRounds) {
            _gameOver = true;
          }
        }
      }
    });
  }

  String _getWinner() {
    if (_scores.isEmpty) return '';
    // Find the player with the highest score
    String winner = _scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return winner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // FIX: Force the container to take up the entire screen height
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ludo Game By Abdullah',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter player name',
                            // Added filled/fillColor for better visibility against the gradient
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _addPlayer,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Player'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _clearGame,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear Game'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_gameOver && _players.length >= 2)
                    Text(
                      "It's ${_players[_currentPlayerIndex]}'s Turn!",
                      style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  if (_players.length < 2)
                    const Text(
                      "Add at least 2 players to start.",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _players.length >= 2 && !_gameOver ? _rollDice : null,
                    child: Image.asset(
                      diceImages[_diceNumber - 1],
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!_gameOver && _players.length >= 2)
                    ElevatedButton.icon(
                      onPressed: _rollDice,
                      icon: const Icon(Icons.casino),
                      label: const Text('Roll Dice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    _gameOver ? '🏆 Game Over!' : 'Scoreboard',
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      String player = _players[index];
                      int score = _scores[player] ?? 0;
                      Color color = [Colors.red, Colors.blue, Colors.green, Colors.amber][index % 4];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          // Highlight the current player
                          border: (_players.length >= 2 && !_gameOver && index == _currentPlayerIndex)
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(player, style: const TextStyle(color: Colors.white, fontSize: 18)),
                            Text('$score', style: const TextStyle(color: Colors.white, fontSize: 18)),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_gameOver)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        "Winner Ha Apka  ${_getWinner()} 🎉",
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // Added a small spacing widget to push content up if needed and fill space
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}