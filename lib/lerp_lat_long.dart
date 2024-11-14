import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LatLngTweenExtent extends Tween<LatLng> {
  LatLngTweenExtent({required LatLng begin, required LatLng end}) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    double latitude = begin!.latitude + (end!.latitude - begin!.latitude) * t;
    double longitude = begin!.longitude + (end!.longitude - begin!.longitude) * t;
    return LatLng(latitude, longitude);
  }
}