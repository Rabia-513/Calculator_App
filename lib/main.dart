import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String display = '';
  List<String> history = [];
  double memory = 0.0;

  void input(String value) {
    setState(() {
      display += value;
    });
  }

  void calculate() {
    try {
      final result = evaluateExpression(display);
      setState(() {
        history.add('$display = $result');
        display = result.toString();
      });
    } catch (e) {
      setState(() {
        display = 'Error';
      });
    }
  }

  double evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll('x', '*');
      final result = _parseAndEvaluate(expression);
      return result;
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  double _parseAndEvaluate(String expression) {
    List<String> tokens = _tokenize(expression);
    List<double> values = [];
    List<String> ops = [];

    for (var token in tokens) {
      if (_isNumeric(token)) {
        values.add(double.parse(token));
      } else {
        while (ops.isNotEmpty && _precedence(ops.last) >= _precedence(token)) {
          values.add(_applyOperation(ops.removeLast(), values.removeLast(), values.removeLast()));
        }
        ops.add(token);
      }
    }

    while (ops.isNotEmpty) {
      values.add(_applyOperation(ops.removeLast(), values.removeLast(), values.removeLast()));
    }

    return values.first;
  }

  List<String> _tokenize(String expression) {
    List<String> tokens = [];
    String number = '';
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if (_isNumeric(char) || char == '.') {
        number += char;
      } else {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = '';
        }
        tokens.add(char);
      }
    }
    if (number.isNotEmpty) tokens.add(number);
    return tokens;
  }

  bool _isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  double _applyOperation(String op, double b, double a) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) throw Exception('Division by zero');
        return a / b;
      default:
        throw Exception('Unknown operator');
    }
  }

  void clear() {
    setState(() {
      display = '';
    });
  }

  void storeMemory() {
    setState(() {
      memory = double.tryParse(display) ?? 0.0;
    });
  }

  void recallMemory() {
    setState(() {
      display = memory.toString();
    });
  }

  void clearMemory() {
    setState(() {
      memory = 0.0;
    });
  }

  void openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Text('Settings options can be added here.'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Calculator')),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,

      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(20),
                child: Text(
                  display,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Divider(color: Colors.black),
            Expanded(
              child: Container(
                color: Colors.grey.shade900,
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return Text(
                      history[index],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            Divider(color: Colors.grey),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: [
                button('7'), button('8'), button('9'), button('/', color: Colors.yellow),
                button('4'), button('5'), button('6'), button('*', color: Colors.yellow),
                button('1'), button('2'), button('3'), button('-', color: Colors.yellow),
                button('0'), button('.'), button('=', onPressed: calculate, color: Colors.yellow), button('+', color: Colors.yellow),
              ],
            ),
            Row(
              children: [
                Expanded(child: button('C', onPressed: clear)),
                Expanded(child: button('M+', onPressed: storeMemory)),
                Expanded(child: button('MR', onPressed: recallMemory)),
                Expanded(child: button('MC', onPressed: clearMemory)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget button(String label, {void Function()? onPressed, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color ?? Colors.grey,
          onPrimary: Colors.black,
          padding: EdgeInsets.all(15),
        ),
        onPressed: onPressed ?? () => input(label),
        child: Text(label, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
