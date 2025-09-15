import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'dart:math'; // <-- Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The smartest Calculator by Adrian Mora', // <-- Put your name here
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 75, 183, 58)),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  String _accumulator = '';

  final List<String> _buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
    '%', 'x²', // <-- Added modulo and square buttons
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
        _accumulator = '';
      } else if (value == '=') {
        try {
          String parsedExpression = _expression
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('%', ' % ')
              .replaceAllMapped(
                RegExp(r'(\d+(\.\d+)?)x²'),
                (match) => 'pow(${match[1]},2)',
              );
          // Support for pow (square)
          final exp = Expression.parse(parsedExpression);
          final evaluator = const ExpressionEvaluator();
          final evalResult = evaluator.eval(exp, {
            'pow': pow, // <-- Use dart:math pow
          });
          _result = evalResult.toString();
          _accumulator = '$_expression = $_result';
          _expression = '';
        } catch (e) {
          _result = 'Error';
          _accumulator = '$_expression = Error';
          _expression = '';
        }
      } else if (value == 'x²') {
        if (_expression.isNotEmpty && RegExp(r'\d$').hasMatch(_expression)) {
          _expression += 'x²';
          _accumulator = _expression;
        }
      } else {
        if (_result.isNotEmpty) {
          // Start new expression after result
          _expression = '';
          _result = '';
          _accumulator = '';
        }
        _expression += value;
        _accumulator = _expression;
      }
    });
  }

  Widget _buildButton(String value) {
    Color bgColor;
    if (value == 'C') {
      bgColor = const Color.fromARGB(255, 241, 82, 255);
    } else if (value == '=' || value == '+' || value == '-' || value == '*' || value == '/') {
      bgColor = Colors.blue;
    } else {
      bgColor = Colors.blue[50]!;
    }
    return ElevatedButton(
      onPressed: () => _onButtonPressed(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: (value == 'C' || value == '=' || value == '+' || value == '-' || value == '*' || value == '/')
            ? Colors.white
            : Colors.blue[900],
        textStyle: const TextStyle(fontSize: 14), // Smaller font
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(36, 36), // Smaller button
        padding: const EdgeInsets.all(0),
        elevation: 0,
      ),
      child: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('the Smartest Calculator by Adrian Mora'),
        backgroundColor: Colors.blue,
        foregroundColor: const Color.fromARGB(255, 82, 80, 80),
        centerTitle: true,
        toolbarHeight: 40, // Smaller app bar
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4), // Less padding for smaller look
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                _accumulator,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue), // Smaller font
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) => _buildButton(_buttons[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
