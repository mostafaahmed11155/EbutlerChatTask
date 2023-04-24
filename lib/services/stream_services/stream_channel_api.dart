import 'package:ebutler_chat/services/stream_services/stream_api.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Channel;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';


class StreamChannelApi {
  static Future<Channel> createChannelWithUsers({
    List<String> idMembers = const [],
  }) async {
    final channel = StreamApi.client.channel(
      'messaging',
      extraData: {
        'members': idMembers,
      },
    );

    await channel.watch();
    return channel;
  }

}
