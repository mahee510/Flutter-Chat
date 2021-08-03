import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/pages/auth/auth_screen.dart';
import 'package:flutterchat/pages/chat/chat_screen.dart';
import 'package:flutterchat/pages/splash/splash_screen.dart';
import 'package:flutterchat/provider/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: 'Flutter Chat',
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData(
            scaffoldBackgroundColor: Colors.grey.shade900,
            primaryColor: const Color(0xFF1A1B1E),
            colorScheme: const ColorScheme.dark(),
            iconTheme: const IconThemeData(color: Colors.white, opacity: 0.8),
            fontFamily: "OpenSans",
          ),
          theme: ThemeData.dark(),
          home: auth.isAuth
              ? ChatScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreeen()
                          : AuthScreen(),
                ),
          routes: {
            AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
