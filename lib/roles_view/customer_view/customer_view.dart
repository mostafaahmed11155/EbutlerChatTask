import 'package:ebutler_chat/pages/authentication/sign_up.dart';
import 'package:ebutler_chat/pages/conversations/channels_list_page.dart';
import 'package:ebutler_chat/roles_view/customer_view/location_management/all_locations.dart';
import 'package:ebutler_chat/services/stream_services/stream_api.dart';
import 'package:ebutler_chat/services/stream_services/stream_user_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({Key? key}) : super(key: key);

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  int index = 0;

  onTap(int ind){
    setState(() {
      index = ind;
    });
  }

  List<Widget> pages = [
    ChannelListPage(isCustomers: false), // Which is Chat with us
    AllLocations(uid: FirebaseAuth.instance.currentUser!.uid),
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
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color: Colors.black,),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              StreamApi.client.disconnectUser();
              StreamApi.client.closeConnection();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpScreen(),));

            },
          ),
        ],
        title: const Text("Chats",style: TextStyle(color: Colors.black),),
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTap,
          currentIndex: index,
          selectedItemColor:Colors.blue.shade900,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Chat with us'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on),label: 'Locations'),
      ]),
    );
  }
}
