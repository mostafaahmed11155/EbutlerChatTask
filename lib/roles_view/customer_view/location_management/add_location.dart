import 'package:ebutler_chat/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AddLocation extends StatefulWidget {
  const AddLocation({Key? key}) : super(key: key);

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {

  MapController _mapController = MapController();
  Map? position;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Add Location'),
      ),
      body: Stack(
        children: [

          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onTap: (tapPosition, point) {
                setState(() {

                  position = {
                    'longitude' : point.longitude,
                    'latitude' :point.latitude
                  };
                });
                showSaveDialog();
              },
              center:  null,//LatLng(51.509364, -0.128928),
              zoom: 9.2,
              scrollWheelVelocity: 5
            ),
            nonRotatedChildren: [
            /*  AttributionWidget.defaultWidget(
                source: 'OpenStreetMap contributors',
                onSourceTapped: null,
              ),*/
            ],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
          Center(child: Icon(Icons.location_on,color: Colors.red.shade700,size: 50,))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue.shade900,
          onPressed: _determinePosition, label: Text('Detect My Location')),
    );
  }

  showSaveDialog(){
    showDialog(context: context, builder: (context) => AlertDialog(title: Text('Save This Location'),content: Text('Do you want to save this location?'),actions: [TextButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text('Cancel',style: TextStyle(color: Colors.blue.shade900),)),TextButton(onPressed: saveToDB, child: Text('Save',style: TextStyle(color: Colors.blue.shade900),))]),);
  }

   _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var latlng = await Geolocator.getCurrentPosition();

      position = {
       'longitude' : latlng.longitude,
        'latitude' : latlng.latitude
      };
    setState(() {

    });
    _mapController.move(LatLng(position!['latitude'], position!['longitude']), 5);

   // Future.delayed(Duration(seconds: 1,),() => showSaveDialog(),);
   return position!;
  }

  saveToDB()async{
    await Provider.of<ServiceProvider>(context,listen: false).saveUserLocation(LatLng(position!['latitude'], position!['longitude']));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location Saved')));
  }

}
