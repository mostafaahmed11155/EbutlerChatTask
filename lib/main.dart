import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebutler_chat/pages/authentication/sign_up.dart';
import 'package:ebutler_chat/roles_view/customer_view/customer_view.dart';
import 'package:ebutler_chat/roles_view/operator_view/operator_view.dart';
import 'package:ebutler_chat/services/service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'firebase_options.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'services/stream_services/stream_api.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signOut();
  await StreamApi.client.disconnectUser();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ServiceProvider>(create: (context) => ServiceProvider(),)
  ],
  child:  MyApp(),
  ));
}


class MyApp extends StatefulWidget {
  const MyApp({super.key,});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter EButler Chat',
      debugShowCheckedModeBanner: false,
        builder: (context, child) => StreamChat(
          client: StreamApi.client,
          child: ResponsiveWrapper.builder(
            BouncingScrollWrapper.builder(context, child!),
            maxWidth: 1200,
            minWidth: 450,
            defaultScale: true,
            breakpoints: [
              const ResponsiveBreakpoint.resize(450, name: 'MOBILE'),
              const ResponsiveBreakpoint.autoScale(800, name: 'TABLET'),
              const ResponsiveBreakpoint.autoScale(1000, name: 'TABLET'),
              const ResponsiveBreakpoint.resize(1200, name: 'DESKTOP'),
              const ResponsiveBreakpoint.autoScale(1200, name: 'DESKTOP'),
              const ResponsiveBreakpoint.autoScale(2460, name: '4K'),
            ],
            background: Container(
              color: const Color(0xFFF5F5F5),
            ),
          ),
        ),

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

        home: SignUpScreen() /*StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.data == null){
              return SignUpScreen();
            }else{
              return FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
                builder: (context, snapshott) {
                  if(snapshott.hasData){
                    if(snapshott.data!.data()!['role'] == 'customer'){
                      return CustomerView();
                    }else if(snapshott.data!.data()!['role'] == 'operator'){
                      return OperatorView();
                    }else{
                      return Container();
                    }
                  }
                  return Container();
                },
              );
            }
          },
    )*/);
  }
}


