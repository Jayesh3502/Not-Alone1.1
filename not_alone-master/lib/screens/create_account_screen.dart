import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:not_alone/components/login_fields.dart';
import 'package:not_alone/screens/home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _auth = FirebaseAuth.instance;
  late bool showSpinner = false;

  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 150,
                ),
                const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      // color: Colors.white,
                      fontFamily: 'Montserrat-Bold',
                      fontSize: 35,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                LoginFields(
                  formHintText: 'Enter Your Email',
                  formPrefixIcon: Icons.email,
                  obscureText: false,
                  onChanged: (val) {
                    setState(() {
                      email = val;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                LoginFields(
                  formHintText: 'Enter Your Password',
                  formPrefixIcon: Icons.password,
                  obscureText: true,
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                ),
                const SizedBox(
                  height: 13,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);

                        if (context.mounted) {
                          Navigator.popUntil(
                              context, ModalRoute.withName('/welcome_screen'));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                        }

                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        log('Oops! Some error occurred.');
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
