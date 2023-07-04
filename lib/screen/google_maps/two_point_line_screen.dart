import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_playgorund/core/secret.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class TwoPointLineScreen extends StatefulWidget {
  const TwoPointLineScreen({super.key});

  @override
  State<TwoPointLineScreen> createState() => _TwoPointLineScreenState();
}

class _TwoPointLineScreenState extends State<TwoPointLineScreen> {
  late GoogleMapController _googleMapController;

  final _initialLocation = const LatLng(0.0, 0.0);
  final _origin = const LatLng(-6.9535157, 107.6087301);
  final _destination = const LatLng(-6.8799933, 107.5846024);
  final Map<MarkerId, Marker> markers = {};
  final Map<PolylineId, Polyline> polylines = {};
  final List<LatLng> polylineCoordinates = [];
  final polylinePoints = PolylinePoints();

  @override
  void initState() {
    _addMarker(
      _origin,
      "Origin",
      BitmapDescriptor.defaultMarker,
    );
    _addMarker(
      _destination,
      "Destination",
      BitmapDescriptor.defaultMarkerWithHue(
        90.0,
      ),
    );

    _getPolyline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Two Point Line"),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialLocation,
            zoom: 15.0,
          ),
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          tiltGesturesEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          markers: Set<Marker>.of(markers.values),
          polylines: Set<Polyline>.of(polylines.values),
        ),
      ),
    );
  }

  _onMapCreated(GoogleMapController googleMapController) async {
    _googleMapController = googleMapController;
    await _updateCameraLocation(_origin, _destination, _googleMapController);
  }

  _updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: destination,
        northeast: source,
      );
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(
        southwest: source,
        northeast: destination,
      );
    }

    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return _checkCameraLocation(cameraUpdate, mapController);
  }

  _checkCameraLocation(
    CameraUpdate cameraUpdate,
    GoogleMapController mapController,
  ) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return _checkCameraLocation(
        cameraUpdate,
        mapController,
      );
    }
  }

  _addMarker(LatLng latLng, String id, BitmapDescriptor bitmapDescriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: bitmapDescriptor,
      position: latLng,
    );
    markers[markerId] = marker;
  }

  _addPolyline() {
    const id = PolylineId("poly");
    final polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    final result = await polylinePoints.getRouteBetweenCoordinates(
      mapAPIKey,
      PointLatLng(_origin.latitude, _origin.longitude),
      PointLatLng(_destination.latitude, _destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(
            point.latitude,
            point.longitude,
          ),
        );
      }
    } else {
      log("MAPS_POLYLINE_ERROR ${result.errorMessage}");
    }
    _addPolyline();
  }
}
