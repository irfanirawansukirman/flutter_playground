import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:permission_handler/permission_handler.dart';

class DefaultMaps extends StatefulWidget {
  const DefaultMaps({super.key});

  @override
  State<DefaultMaps> createState() => _DefaultMapsState();
}

class _DefaultMapsState extends State<DefaultMaps> {
  late GoogleMapController _googleMapController;

  final Map<String, Marker> _markers = {};
  final _location = Location();
  final _initialLocation = const LatLng(0.0, 0.0);
  final key = "My Location";

  _onMapCreated(
    GoogleMapController googleMapController,
    BuildContext context,
  ) async {
    const permission = Permission.location;
    if (await permission.isGranted == false || await permission.isDenied) {
      final result = await permission.request();

      if (result.isGranted) {
        // granted
        _googleMapController = googleMapController;

        final location = await _location.getLocation();
        final position = LatLng(
          location.latitude ?? 0.0,
          location.longitude ?? 0.0,
        );

        _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: 15.0,
            ),
          ),
        );

        final address = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final place = address[0];

        log('PLACE $place');

        final street = '${place.street}, ${place.subAdministrativeArea}';
        final marker = Marker(
          markerId: MarkerId(key),
          position: position,
          infoWindow: InfoWindow(
            title: key,
            snippet: street,
          ),
        );

        setState(() {
          _markers.clear();
          _markers[key] = marker;
        });

        // or
        // _location.onLocationChanged.listen(
        //   (location) async {
        //
        //   },
        // );
      } else if (result.isDenied) {
        // denied when show dialog
        _showSnackBar();
      } else {
        // permanent denied
        _showSnackBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Default Maps"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 15.0,
        ),
        mapType: MapType.normal,
        onMapCreated: (googleMapController) => _onMapCreated(
          googleMapController,
          context,
        ),
        myLocationEnabled: true,
        markers: _markers.values.toSet(),
      ),
    );
  }

  _showSnackBar() {
    final snackBar = SnackBar(
      content: const Text("Opps, please open setting page to allow permission request."),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () => openAppSettings(),
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
