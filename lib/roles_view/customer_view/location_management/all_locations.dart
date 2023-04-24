import 'package:ebutler_chat/pages/maps_view/maps_view.dart';
import 'package:ebutler_chat/roles_view/customer_view/location_management/add_location.dart';
import 'package:ebutler_chat/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AllLocations extends StatefulWidget {
  String uid;
   AllLocations({Key? key, required this.uid}) : super(key: key);

  @override
  State<AllLocations> createState() => _AllLocationsState();
}

class _AllLocationsState extends State<AllLocations> {
  late var _getUserData= Provider.of<ServiceProvider>(context).getAnotherUserDataAsStream(uId: widget.uid);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Locations'),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddLocation(),));
          },child:  Icon(Icons.add,color: Colors.white,))
        ],
      ),
      body: StreamBuilder(
        stream: _getUserData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            print(snapshot.data['locations']);
            return SingleChildScrollView(child: Column(children: snapshot.data!['locations'].map<Widget>((loc)=> buildUserContainer(loc)).toList(),));
          }
          return CircularProgressIndicator(color: Colors.blue.shade900,);
        },
      ),
    );
  }

  Widget buildUserContainer(Map location){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      height: 200,
      child: Stack(
        children: [

          FlutterMap(
            options: MapOptions(
                center: LatLng(location['latitude'], location['longitude']),
                zoom: 5,
              onTap: (tapPosition, point) {
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapsView(position: location),));
              },
            ),
            nonRotatedChildren: [

            ],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
          Center(child: Icon(Icons.location_on,color: Colors.red.shade700,size: 50,)),
         // Positioned(bottom: 1,child: Text('Longitude : ${location['longitude']} Latitude : ${location['latitude']}'))
        ],
      ),
    );
  }
}
