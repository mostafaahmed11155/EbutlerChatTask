import 'package:ebutler_chat/pages/maps_view/maps_view.dart';
import 'package:ebutler_chat/roles_view/customer_view/location_management/all_locations.dart';
import 'package:ebutler_chat/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelPage extends StatelessWidget {
  String? otherMemberUID;
   ChannelPage({
    Key? key,
    required this.otherMemberUID
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  StreamChannelHeader(
       onImageTap: () {
         Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllLocations(uid: otherMemberUID!),));

       },
      ),
      body: StreamChatTheme(
        data: StreamChatThemeData(),
        child: Column(
          children: const <Widget>[
            Expanded(
              child: StreamMessageListView(),
            ),
            StreamTypingIndicator(padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),),
            StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}