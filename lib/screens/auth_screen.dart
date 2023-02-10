import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/http_exception.dart';
import 'dart:math';

import '../Providers/auth.dart';

enum AuthMode {
  signup,
  login,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var authMode = AuthMode.login;
  final Map<String, String> authData = {
    'email': '',
    'password': '',
  };

  final passwordController = TextEditingController();
  var form = GlobalKey<FormState>();

  void switchAuthMode() {
    setState(() {
      if (authMode == AuthMode.login) {
        authMode = AuthMode.signup;
      } else {
        authMode = AuthMode.login;
      }
    });
  }

  Future<void> saveForm() async {
    final isValid = form.currentState!.validate();
    if (!isValid) {
      return;
    }
    form.currentState!.save();
    try {
      if (authMode == AuthMode.signup) {
        await Provider.of<Auth>(context, listen: false).signup(
          authData['email'],
          authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).login(
          authData['email'],
          authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Something went wrong';
      if (error.message.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage =
            'Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.';
      } else if (error.message.contains('INVALID_EMAIL')) {
        errorMessage = 'Please provide a valid email.';
      } else if (error.message.contains('EMAIL_EXISTS')) {
        errorMessage = 'The email address is already in use by another account';
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        errorMessage =
            'There is no user record corresponding to this identifier. The user may have been deleted.';
      } else if (error.message.contains('INVALID_PASSWORD')) {
        errorMessage = 'The password is incorrect.';
      } else if (error.message.contains('USER_DISABLED')) {
        errorMessage =
            'The user account has been disabled by an administrator.';
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred'),
          content: const Text('Something went wrong. Try again later'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 94.0),
                  transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
                  // ..translate(-10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.deepOrange.shade900,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text(
                    'MyShop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontFamily: 'Anton',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  height: authMode == AuthMode.login ? 325 : 420,
                  width: 300,
                  child: Card(
                    elevation: 7,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Form(
                      key: form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              right: 15,
                              bottom: 15,
                              top: 25,
                              left: 15,
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide an email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please provide a valid email';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              onSaved: (enteredValue) {
                                authData['email'] = enteredValue!;
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              right: 15,
                              bottom: 15,
                              left: 15,
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide a password';
                                }
                                if (value.length < 6) {
                                  return 'provide a password longer than 6 character';
                                }
                                return null;
                              },
                              obscureText: true,
                              controller: passwordController,
                              textInputAction: TextInputAction.next,
                              onSaved: (enteredValue) {
                                authData['password'] = enteredValue!;
                              },
                            ),
                          ),
                          if (authMode == AuthMode.signup)
                            Container(
                              margin: const EdgeInsets.only(
                                right: 15,
                                bottom: 15,
                                left: 15,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please confirm the password';
                                  }
                                  if (value != passwordController.text) {
                                    return 'it does not match with the password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                              ),
                              onPressed: saveForm,
                              child: Text(authMode == AuthMode.login
                                  ? 'LOGIN'
                                  : 'SIGN UP'),
                            ),
                          ),
                          TextButton(
                            onPressed: switchAuthMode,
                            child: Text(authMode == AuthMode.login
                                ? 'SIGNUP INSTEAD'
                                : 'LOGIN INSTEAD'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
