import 'package:flutter/material.dart';
import 'package:not_alone/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            const Text(
              'you are',
              style: TextStyle(
                fontFamily: 'Montserrat-Bold',
              ),
            ),
            const Text(
              'NotAlone',
              style: TextStyle(
                fontFamily: 'Satisfy',
                fontSize: 50,
              ),
            ),
            const SizedBox(
              height: 150,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
