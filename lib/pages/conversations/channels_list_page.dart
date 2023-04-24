import 'package:ebutler_chat/pages/conversations/channel.dart';
import 'package:ebutler_chat/services/stream_services/stream_api.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelListPage extends StatefulWidget {
  final bool isCustomers;
  const ChannelListPage({
    Key? key,
    required this.isCustomers
  }) : super(key: key);

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late var _listController = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id] ,

    ),
    channelStateSort: const [SortOption('last_message_at')],
    limit: 20,
  );

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.transparent,
       elevation: 0,
       surfaceTintColor: Colors.blue.shade900,
       shadowColor: Colors.blue.shade900,
       title: TextField(
         onChanged: (value) {
           setState(() {
             _listController = StreamChannelListController(
               client: StreamChat.of(context).client,
               filter: Filter.and([
                 Filter.in_('members', [StreamChat.of(context).currentUser!.id] ),

               ]),
               channelStateSort: const [SortOption('last_message_at')],
               limit: 20,
             );
           });
         },
         decoration: InputDecoration
           (
           hintText: 'Search Conversations'
         ),
       ),
     ),
      body:StreamChat.of(context).currentUser != null ? StreamChannelListView(
        controller: _listController,
        itemBuilder: _channelTileBuilder,
        emptyBuilder: (context) {
          return SizedBox(height: MediaQuery.of(context).size.height * 80 /100,width:MediaQuery.of(context).size.width, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Text('Not Chatlist Available')],));
        },
        onChannelTap: (channel) async{
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return StreamChannel(
                  channel: channel,
                  child: ChannelPage(otherMemberUID: channel.state?.members.firstWhere(
                (member) => member.user?.id != StreamApi.client.state.currentUser?.id,).userId,
                ));
              },
            ),
          ).then((_){
            setState(() {

            });
          });
        },
      ) : Center(child: Text('Contact with EButler Team')),
    );
  }

  Widget _channelTileBuilder(BuildContext context, List<Channel> channels,
      int index, StreamChannelListTile defaultChannelTile) {
    final channel = channels[index];

    final lastMessage = channel.state?.messages.reversed.firstWhere(
          (message) => !message.isDeleted,orElse: () => Message(text: 'Start Chatting'),
    );

    final otherMember = channel.state?.members.firstWhere(
          (member) => member.user?.id != StreamApi.client.state.currentUser?.id,
    );


    final subtitle = lastMessage == null ? 'nothing yet' :  lastMessage.text!;

    final opacity = (channel.state?.unreadCount ?? 0) > 0 ? 1.0 : 0.5;

    final theme = StreamChatTheme.of(context);

    if(widget.isCustomers){
      if(otherMember!.user!.extraData['userRole'] == 'user')
      {
        return ListTile(
          onTap: ()async {
           await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamChannel(
                  channel: channel,
                  child:  ChannelPage(otherMemberUID: otherMember.userId),
                ),
              ),
            ).then((value) {
              setState(() {

              });
           });
          },
          leading: StreamUserAvatar(
            user: otherMember?.user as User,
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            otherMember?.user?.name ?? 'Unknown',
            style: theme.channelPreviewTheme.titleStyle!.copyWith(
              color: theme.colorTheme.textHighEmphasis.withOpacity(opacity),
            ),
          ),
          subtitle: Text(subtitle),
          trailing: channel.state!.unreadCount > 0
              ? CircleAvatar(
            radius: 10,
            child: Text(channel.state!.unreadCount.toString()),
          )
              : const SizedBox(),
        );
      }
      return Container();
    }else{
      if(otherMember!.user!.extraData['userRole'] == 'operator')
      {
        return ListTile(
          onTap: () async{
           await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamChannel(
                  channel: channel,
                  child: ChannelPage(otherMemberUID: otherMember.userId),
                ),
              ),
            ).then((_){
setState(() {

});
           });
          },
          leading: StreamUserAvatar(
            user: otherMember?.user as User,
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            otherMember?.user?.name ?? 'Unknown',
            style: theme.channelPreviewTheme.titleStyle!.copyWith(
              color: theme.colorTheme.textHighEmphasis.withOpacity(opacity),
            ),
          ),
          subtitle: Text(subtitle),
          trailing: channel.state!.unreadCount > 0
              ? CircleAvatar(
            radius: 10,
            child: Text(channel.state!.unreadCount.toString()),
          )
              : const SizedBox(),
        );
      }else{
       return Container();
      }
    }
  }

  Filter _buildNameFilter(String value) {
    final query = value;
    if (query.isEmpty) {
      return Filter.empty();
    }
    return Filter.or([
      for (final word in query.split(' '))
        Filter.contains('members.name', word),
    ]);
  }
}

