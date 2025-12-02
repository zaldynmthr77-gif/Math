import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MathGameApp());
}

class MathGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: KidsMathGame());
  }
}

class MathProblem {
  final int num1;
  final int num2;
  final String operation;
  final int answer;

  MathProblem({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.answer,
  });
}

class KidsMathGame extends StatefulWidget {
  @override
  _KidsMathGameState createState() => _KidsMathGameState();
}

class _KidsMathGameState extends State<KidsMathGame> {
  MathProblem? currentProblem;
  String userAnswer = "";
  int score = 0;
  int streak = 0;
  int stars = 0;
  String? feedback; // "correct" or "incorrect"
  String operationMode = "mixed"; // addition, subtraction, mixed

  final Random random = Random();
  bool waitingNext = false; // to disable inputs while waiting for next problem

  @override
  void initState() {
    super.initState();
    generateProblem();
  }

  @override
  void dispose() {
    // nothing special needed here; we rely on mounted checks before setState
    super.dispose();
  }

  void generateProblem() {
    // Safety: don't call setState if widget is not mounted
    if (!mounted) return;

    int num1, num2, answer;
    String op;

    if (operationMode == "mixed") {
      op = random.nextBool() ? "addition" : "subtraction";
    } else {
      op = operationMode;
    }

    if (op == "addition") {
      num1 = random.nextInt(20) + 1;
      num2 = random.nextInt(20) + 1;
      answer = num1 + num2;
    } else {
      num1 = random.nextInt(20) + 1;
      num2 = random.nextInt(num1) + 1;
      answer = num1 - num2;
    }

    if (!mounted) return;
    setState(() {
      currentProblem = MathProblem(
        num1: num1,
        num2: num2,
        operation: op,
        answer: answer,
      );
      userAnswer = "";
      feedback = null;
      waitingNext = false;
    });
  }

  void handleInput(String value) {
    if (waitingNext) return;
    if (userAnswer.length < 3) {
      setState(() {
        userAnswer += value;
      });
    }
  }

  void handleSubmit() {
    if (waitingNext) return;
    if (userAnswer.isEmpty || currentProblem == null) return;

    int? parsed;
    try {
      parsed = int.parse(userAnswer);
    } catch (_) {
      // invalid number — ignore
      return;
    }

    final bool correct = parsed == currentProblem!.answer;

    if (!mounted) return;
    setState(() {
      waitingNext = true;
      if (correct) {
        feedback = "correct";
        score++;
        streak++;
        if (streak > 0 && streak % 3 == 0) {
          stars++;
        }
      } else {
        feedback = "incorrect";
        streak = 0;
      }
    });

    // Show feedback briefly, then generate next problem — check mounted before updating
    Future.delayed(Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        // keep feedback visible a short moment (we might clear it in generateProblem)
      });
    });

    Future.delayed(Duration(milliseconds: 1400), () {
      if (!mounted) return;
      generateProblem();
    });
  }

  void clearInput() {
    if (waitingNext) return;
    setState(() {
      userAnswer = "";
    });
  }

  Widget operationSymbol() {
    if (currentProblem == null) return Text("");
    return Text(
      currentProblem!.operation == "addition" ? "+" : "-",
      style: TextStyle(fontSize: 50, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    // responsive progress bar base width
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fullBarWidth = (screenWidth - 40).clamp(100.0, 600.0);

    return Scaffold(
      backgroundColor: Color(0xfff0f2ff),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Math Adventure!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Solve problems and earn stars!",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 18),

                // Stats bar
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 30),
                          SizedBox(width: 6),
                          Text(
                            "$stars",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Score",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            "$score",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Streak",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            "$streak",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14),

                // Mode buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    modeBtn("addition", "Add"),
                    SizedBox(width: 8),
                    modeBtn("subtraction", "Subtract"),
                    SizedBox(width: 8),
                    modeBtn("mixed", "Mixed"),
                  ],
                ),

                SizedBox(height: 18),

                // Problem card
                problemCard(),

                SizedBox(height: 12),

                // Feedback
                if (feedback != null)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: feedback == "correct"
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          feedback == "correct"
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: feedback == "correct"
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                        SizedBox(width: 8),
                        Text(
                          feedback == "correct" ? "Great job!" : "Try again!",
                          style: TextStyle(
                            fontSize: 16,
                            color: feedback == "correct"
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 14),

                // Answer box
                answerBox(),

                SizedBox(height: 14),

                // Keypad
                keypad(),

                SizedBox(height: 14),

                // Progress bar (responsive)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: fullBarWidth,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 350),
                            width: ((streak % 3) / 3) * fullBarWidth,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "${streak % 3}/3 for next star",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget modeBtn(String mode, String text) {
    bool active = operationMode == mode;

    return ElevatedButton(
      onPressed: () {
        if (waitingNext) return;
        setState(() {
          operationMode = mode;
        });
        // regenerate a problem with the new mode
        generateProblem();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.indigo : Colors.white,
        foregroundColor: active ? Colors.white : Colors.indigo,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: TextStyle(fontSize: 14)),
    );
  }

  Widget problemCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: currentProblem == null
          ? SizedBox(height: 80)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${currentProblem!.num1}",
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                operationSymbol(),
                SizedBox(width: 12),
                Text(
                  "${currentProblem!.num2}",
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "=",
                  style: TextStyle(fontSize: 48, color: Colors.grey[400]),
                ),
                SizedBox(width: 12),
                Text(
                  "?",
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget answerBox() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            "Your Answer",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Text(
            userAnswer.isEmpty ? "_" : userAnswer,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget keypad() {
    return Column(
      children: [
        for (var row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((n) => keypadButton(n.toString())).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [clearBtn(), keypadButton("0"), submitBtn()],
        ),
      ],
    );
  }

  Widget keypadButton(String number) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: (waitingNext) ? null : () => handleInput(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          minimumSize: Size(78, 78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          number,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget clearBtn() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: (waitingNext) ? null : clearInput,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[100],
          foregroundColor: Colors.red[700],
          minimumSize: Size(78, 78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Clear",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget submitBtn() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: (userAnswer.isEmpty || waitingNext) ? null : handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: (userAnswer.isEmpty || waitingNext)
              ? Colors.green[300]
              : Colors.green,
          foregroundColor: Colors.white,
          minimumSize: Size(78, 78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "OK",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
