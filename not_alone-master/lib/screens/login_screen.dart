import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:not_alone/screens/create_account_screen.dart';
import 'package:not_alone/screens/home_screen.dart';
import 'package:not_alone/components/login_fields.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late bool showSpinner = false;

  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 150,
                      ),
                      const Text(
                        'Hey!',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Bold',
                          fontSize: 50,
                        ),
                      ),
                      const Text(
                        'Let\'s Make this world a better place to live!',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
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
                              FocusManager.instance.primaryFocus?.unfocus();

                              await _auth.signInWithEmailAndPassword(
                                  email: email, password: password);

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              }

                              setState(() {
                                showSpinner = false;
                              });
                            } catch (e) {
                              log(e.toString());
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountScreen()),
                          );
                        },
                        child: Text(
                          'Create New Account',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.labelMedium,
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
