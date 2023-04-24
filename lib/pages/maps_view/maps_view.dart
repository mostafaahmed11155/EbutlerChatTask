import 'package:ebutler_chat/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapsView extends StatefulWidget {
  Map position;
   MapsView({Key? key,required this.position}) : super(key: key);

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {

  Map? newPosition;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Location Details'),
        actions: [
          IconButton(onPressed: (){

              showDialog(context: context, builder: (context) => AlertDialog(title: Text('Delete This Location'),content: Text('Do you want to delete this location?'),actions: [TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text('Cancel',style: TextStyle(color: Colors.blue.shade900),)),TextButton(onPressed: () async{
                await Provider.of<ServiceProvider>(context,listen: false).deleteLocation(widget.position);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location Deleted')));

              }, child: Text('Delete',style: TextStyle(color: Colors.blue.shade900),))]),);

          }, icon: Icon(Icons.delete,color: Colors.white,))
        ],
      ),
      body: Stack(
        children: [

          FlutterMap(

            options: MapOptions(
                onTap: (tapPosition, point) {
                  setState(() {

                    newPosition = {
                      'longitude' : point.longitude,
                      'latitude' :point.latitude
                    };
                  });
                  showEditDialog();
                },
                center: LatLng(widget.position['latitude'], widget.position['longitude']),
                zoom: 9.2,

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
          Center(child: Icon(Icons.location_on,color: Colors.red.shade700,size: 50,))
        ],
      ),

    );
  }

  showEditDialog(){
    showDialog(context: context, builder: (context) => AlertDialog(title: Text('Edit This Location'),content: Text('Do you want to edit this location?'),actions: [TextButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text('Cancel',style: TextStyle(color: Colors.blue.shade900),)),TextButton(onPressed: editToDB, child: Text('Save',style: TextStyle(color: Colors.blue.shade900),))]),);
  }

  editToDB()async{
    await Provider.of<ServiceProvider>(context,listen: false).editLocation(widget.position, newPosition!);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location Saved')));
  }
}
