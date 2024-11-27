import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: RegisterWidget(),
        ),
      ),
    );
  }
}

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  String userName = "";
  String passWord = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Registrieren",
            style: TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 32),
          TextField(
            onChanged: (value) => userName = value,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => passWord = value,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 32),
          const ElevatedButton(onPressed: null, child: Text("Register"))
        ],
      ),
    );
  }
}
