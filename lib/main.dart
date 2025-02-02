import 'package:flutter/material.dart';
import 'package:number_trivia/features/number_trivia/presentation/screens/number_trivia_page.dart';
import 'injection_container.dart' as di;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
      ),
   title: "Number Trivia",
      home:  NumberTriviaPage(),
    );
  }
}

