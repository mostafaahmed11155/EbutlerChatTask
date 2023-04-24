import 'package:ebutler_chat/pages/authentication/sign_up.dart';
import 'package:ebutler_chat/pages/conversations/channels_list_page.dart';
import 'package:ebutler_chat/services/stream_services/stream_api.dart';
import 'package:ebutler_chat/services/stream_services/stream_user_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OperatorView extends StatefulWidget {
  const OperatorView({Key? key}) : super(key: key);

  @override
  State<OperatorView> createState() => _OperatorViewState();
}

class _OperatorViewState extends State<OperatorView> {
  int index = 0;

  onTap(int ind){
    setState(() {
      index = ind;
    });
  }

  List<Widget> pages = [
    ChannelListPage(isCustomers: true), // Which is for Users/Customer
    ChannelListPage(isCustomers: false), // Which is for Saloon

  ];

  @override
  void didChangeDependencies() async{
      await StreamUserApi.connectUserForLogIn(idUser: FirebaseAuth.instance.currentUser!.uid);
      // TODO: implement didChangeDependencies
      super.didChangeDependencies();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operator Space'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
            StreamApi.client.disconnectUser();
            StreamApi.client.closeConnection();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpScreen(),));
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTap,
          currentIndex: index,
          selectedItemColor:Colors.blue.shade900,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Inbox'),
            BottomNavigationBarItem(icon: Icon(Icons.solar_power),label: 'Saloon'),
          ]),
    );
  }
}
