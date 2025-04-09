import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marcador.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final LatLng _initialPosition = LatLng(20.59361, -99.12694);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addMarker(LatLng position) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkerFormScreen(position: position),
      ),
    );
    
    if (result != null && result['action'] == 'save') {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: result['title'],
            snippet: result['description'],
          ),
          onTap: () => _editMarker(MarkerId(position.toString())),
        ));
      });
    }
  }

  void _editMarker(MarkerId markerId) async {
    final marker = _markers.firstWhere((m) => m.markerId == markerId);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkerFormScreen(
          position: marker.position,
          title: marker.infoWindow.title,
          description: marker.infoWindow.snippet,
          isEditing: true,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (result['action'] == 'delete') {
          _markers.removeWhere((m) => m.markerId == markerId);
        } else if (result['action'] == 'save') {
          _markers.removeWhere((m) => m.markerId == markerId);
          _markers.add(Marker(
            markerId: markerId,
            position: marker.position,
            infoWindow: InfoWindow(
              title: result['title'],
              snippet: result['description'],
            ),
            onTap: () => _editMarker(markerId),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Google'),
        backgroundColor: Colors.deepPurple, // Color atractivo de la barra superior
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 12.0,
          ),
          markers: _markers,
          onLongPress: _addMarker,
          onTap: (LatLng position) {
            mapController.hideMarkerInfoWindow(MarkerId(position.toString()));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple, // Color del botón flotante
        child: const Icon(Icons.add_location_alt, size: 30),
      ),
    );
  }
}

