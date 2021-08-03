import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterchat/provider/auth_provider.dart';
import 'package:flutterchat/widgets/nini_widgets.dart';
import 'package:flutterchat/widgets/top_circule.dart';
import 'package:provider/provider.dart';

enum AuthType { login, signup }

class AuthScreen extends StatefulWidget {
  static const routeName = "/auth-screen";
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool spinKit = false;
  var _authType = AuthType.login, _isLoading = false;

  Future<bool> onBackPressed() {
    setState(() {
      if (_authType == AuthType.signup) {
        _authType = AuthType.login;
      } else {
        _authType = AuthType.signup;
      }
    });
    return Future.value(false);
  }

  Future<void> _submit() async {
    // if (!_formKey.currentState!.validate()) {
    //   // Invalid!
    //   return;
    // }
    // _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    try {
      if (_authType == AuthType.login) {
        await Provider.of<Auth>(context, listen: false).loginWithGoogle();
      } else {
        await Provider.of<Auth>(context, listen: false).loginWithGoogle();
      }
    } catch (errorMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage'),
          duration: Duration(
            seconds: 3,
          ),
        ),
      );
      setState(() {
        _isLoading = false;
        FocusScope.of(context).unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  CurvedCircle(),
                  Padding(
                      padding: const EdgeInsets.only(top: 110, left: 25),
                      child: Center(
                        child: Text(
                          "Flutter Chat",
                          style: TextStyle(
                            fontSize: 40,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            foreground: Paint()
                              ..shader = textGradient(
                                const Color(0xFF2F308F),
                                const Color(0xFF1B68EC),
                              ),
                          ),
                        ),
                      )),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 390),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            _submit();
                          });
                        },
                        child: Container(
                          width: deviceSize.width * 0.7,
                          height: deviceSize.height * 0.055,
                          decoration: fieldBuildBoxDecoration(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/google.svg",
                                width: 30,
                              ),
                              const SizedBox(width: 10),
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                )
                              else
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    fontFamily: "OpenSans",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
