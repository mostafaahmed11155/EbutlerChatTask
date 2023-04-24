import 'dart:io';

import 'package:ebutler_chat/services/stream_services/stream_channel_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ServiceProvider with ChangeNotifier{
  final authInstance = FirebaseAuth.instance;
  final fireStoreInstance = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  signUp({required String email,required String password})async{
    final res = await authInstance.createUserWithEmailAndPassword(email: email, password: password).then((value) {
      return value;
    });

    return res;
  }

  login({required String email,required String password})async{
    final res = await authInstance.signInWithEmailAndPassword(email: email, password: password).then((value) {
      return value;
    });

    return res;
  }

  Future<bool> storeUserData({required String name,required String email, required String phone,required String imageUrl,required String role})async{
   await fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).set({
     'name' : name,
     'email' : email,
     'phone' : phone,
     'imageUrl' : imageUrl,
     "role" : role,
     "locations" : []
   });

   return true;
  }

  uploadPicture({required File file})async{
    var snapshot = await _firebaseStorage.ref()
        .child('images/${file.path}')
        .putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  getUserData()async{
    return await fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).get();
  }


  saveUserLocation(LatLng newLocation)async{
    final List locations = await fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).get().then((value) =>value['locations'] ?? []);
    locations.add({
      'longitude': newLocation.longitude,
      'latitude':newLocation.latitude
    });
    await fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).update({
      'locations' : locations
    });
  }

  Stream getUserDataAsStream(){
    final data = fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).snapshots();
    notifyListeners();
    return data;
  }

  Stream getAnotherUserDataAsStream({required String uId}){
    final data = fireStoreInstance.collection('users').doc(uId).snapshots();
    notifyListeners();
    return data;
  }

  deleteLocation(Map location)async{
    final List locations = await fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).get().then((value) =>value['locations'] ?? []);
    int index = locations.indexWhere((element) => element['longitude'] == location['longitude'] && element['latitude'] == location['latitude'],);
    locations.removeAt(index);
    fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).update({
      'locations': locations
    });
  }

  editLocation(Map oldLocation,Map newLocation)async{
    final List locations = await fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).get().then((value) =>value['locations'] ?? []);
    int index = locations.indexWhere((element) => element['longitude'] == oldLocation['longitude'] && element['latitude'] == oldLocation['latitude'],);
    locations.removeAt(index);
    locations.add(newLocation);
    fireStoreInstance.collection('users').doc(authInstance.currentUser!.uid).update({
      'locations': locations
    });
  }

  createChannelForUsers({required bool isCustomer})async{
     await fireStoreInstance.collection('users').get().then((value) async{
       for (var element in value.docs) {
         if(isCustomer){
           if(element.id != authInstance.currentUser!.uid && element.data()['role'] == 'operator'){
             await StreamChannelApi.createChannelWithUsers(idMembers: [
               authInstance.currentUser!.uid,
               element.id,
             ]);
           }
         }else{
           if(element.id != authInstance.currentUser!.uid){
             await StreamChannelApi.createChannelWithUsers(idMembers: [
               authInstance.currentUser!.uid,
               element.id,
             ]);
           }
         }
       }
     });
  }

}