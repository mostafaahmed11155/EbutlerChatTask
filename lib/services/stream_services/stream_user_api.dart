import 'package:ebutler_chat/services/stream_services/stream_api.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamUserApi {
  static Future createUser({
    required String idUser,
    required String username,
    required String urlImage,
    required String role,
  }) async {

    final token = StreamApi.client.devToken(idUser).rawValue;
    final user = User(
      id: idUser,
      extraData: {
        'name': username,
        'image': urlImage,
        'userRole' : role
      }
    );

    await StreamApi.client.connectUser(user,token);
     return true;
  }

  static Future connectUserForLogIn({required String idUser}) async {
    final token = StreamApi.client.devToken(idUser).rawValue;

    final user = User(id: idUser);
    await StreamApi.client.connectUser(user, token);
  }

}


