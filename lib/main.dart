import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:map_test_opensteeat/lerp_lat_long.dart';
import 'package:map_test_opensteeat/map_models/reverse_search_model.dart';
import 'package:map_test_opensteeat/map_models/route_model.dart';

import 'map_models/search_list_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin{
  //
  MapController mapController = MapController();
  LatLng? currentLocation;
  LatLng? startLocation;
  LatLng? endLocation;
  LatLng? latLng;
  List<LatLng> routePoints = [];
  StreamSubscription<Position>? positionStream;

  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  String apiKey = "2c37fba9-c8b4-48d2-a06e-5e37ee015132";
  double zoomValue = 17;

  static const double pointSize = 65;
  static const double pointY = 250;
  double? heading;

  bool isStartingSearch = false;
  dynamic setOnMap = false;

  late AnimationController _animationController;
  late Tween<LatLng> _positionTween;
  Animation<LatLng>? _positionAnimation;




  // Function to get the user location
  Future<void> _getUserLocation() async {
    try {
      // Request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // If the location services are not enabled, ask the user to enable them
        print("Location services are disabled. Please enable them.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        // If permission is denied forever, we need to show the user how to enable it manually
        print("Location permissions are permanently denied.");
        return;
      }

      if (permission == LocationPermission.denied) {
        // If permission is denied, request permission
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          print("Location permissions are denied. Cannot get location.");
          return;
        }
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Update the UI with the current location
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      print("start currentLocation....${currentLocation}");
      //LatLng(latitude:37.421998, longitude:-122.084)

    //  startLocation = LatLng(latitude, longitude);
      mapController.move(LatLng(position.latitude, position.longitude), zoomValue);

      // mapController.animateTo(
      //   center: currentLocation,
      //   zoom: 15.0,
      //   duration: const Duration(milliseconds: 500), // Adjust the duration as needed
      //   curve: Curves.easeInOut, // You can change the curve for different animation effects
      // );
      //
      print("User's current location: ${position.latitude}, ${position.longitude}");
      //_startLocationTracking();
    } catch (e) {
      print("Error getting location: $e");
    }
  }


  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to be displayed
      errorMethodCount: 0, // Number of method calls if stacktrace is provided
      lineLength: 110, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      // Should each log print contain a timestamp
    ),
  );

  RouteModel? routeModel;

  // /// route with osrm
  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    String profile = "foot";// bike, car, foot
    // final url = Uri.parse(
    //   'http://router.project-osrm.org/route/v1/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?'
    //       'overview=full&geometries=geojson',
    // );

    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?'
          'overview=full&alternatives=2&overview=full&geometries=geojson&continue_straight=default',
    );

    print("url...${url}");
    final response = await http.get(url);
    //print("response....route....${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'];
      print("response....route....${coordinates}");
      routeModel = RouteModel.fromJson(data);
      print("routemode....${routeModel!.routes[0].distance}");

     // logger.d("Logger is working!..${response.body}");
    //  logLargeString(response.body.toString());
      print("");
     // logger.d("Logger is working!..${data['routes'][0]['geometry']}");
      List<LatLng> rawRoutePoints = [];

      setState(() {
        rawRoutePoints = coordinates.map<LatLng>((point) {
          return LatLng(point[1], point[0]);
        }).toList();
      });

     await recalculateRoutePoints(rawRoutePoints);

      // setState(() {
      //   routePoints = coordinates.map<LatLng>((point) {
      //     return LatLng(point[1], point[0]);
      //   }).toList();
      // });

    } else {
      print('Failed to fetch route');
    }
  }


  void logLargeString(String message) {
    const chunkSize = 800;
    int start = 0;
    if(kDebugMode)print("response_in_interceptor: ");
    while (start < message.length) {
      int end = start + chunkSize;
      if (end > message.length) end = message.length;
      logger.i(message.substring(start, end));
      start = end;
    }
  }
  
  /// Start location listener to track real-time position and update route
  void _startLocationTracking() {
    late LocationSettings locationSettings;
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      // forceLocationManager: true,
      intervalDuration: const Duration(seconds: 1),
      // foregroundNotificationConfig: const ForegroundNotificationConfig(
      //   notificationText:
      //   "Example app will continue to receive your location even when you aren't using it",
      //   notificationTitle: "Running in Background",
      //   enableWakeLock: true,
      // )
    );
    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        startLocation = currentLocation;
        print("startLocation.2...${startLocation}");

        // for(var point in routePoints){
        //   print("point...${point.latitude}.....long...${point.longitude}");
        // }

        print("routePoints...len...${routePoints.length}");
        //print("routes....${routePoints}");

        for(int index = 0; index<routePoints.length-1; index++){
          print("distance..lo..$index..${_distanceBetween(routePoints[index], routePoints[index+1])}");
        }

        if(routePoints.isNotEmpty)print("totla distan.ce......${_distanceBetween(routePoints[0], routePoints.last)}");

       // Remove points that have been passed

        if (routePoints.isNotEmpty) {
          LatLng removingPoint = currentLocation;
          bool isRemoved = false;
          routePoints.removeWhere((point){
            double value = _distanceBetween(currentLocation, point);
            removingPoint = point;
            ///print("value.....re....$value");
            isRemoved = value < 15;
            return isRemoved;
          }); // Adjust threshold as needed
          // Update startLocation to the first remaining point in routePoints if there are any
          if (routePoints.isNotEmpty && isRemoved) {
            startLocation = routePoints.first;

          //  _positionTween = Tween<LatLng>(begin: currentLocation, end: startLocation);
            _positionTween = LatLngTweenExtent(begin: removingPoint, end: startLocation!);
            _positionAnimation = _positionTween.animate(_animationController);
            _animationController.forward(from: 0.0);
           // mapController.move(startLocation!, zoomValue);
          }
          // if(routePoints.isNotEmpty){
          //   LatLng lastValue = routePoints.last;
          //   print("lastValue....$lastValue");
          //   double distance =  _distanceBetween(currentLocation, lastValue);
          //   print("distance....$distance");
          // }
        }

        setState(() {

        });

       // mapController.move(currentLocation, zoomValue);
      });

    // mapController.move(currentLocation, zoomValue); // Keep map centered on current location
    });
  }

  //23.72776.....long...90.42086 moti //23.727676, longitude:90.420826
  //.23.72288.....long...90.43148 mani //23.722824, longitude:90.431482

  // Function to calculate distance between two LatLng points
  double _distanceBetween(LatLng point1, LatLng point2) {
    double value  = Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
    //print("value..d..$value");
    return value;
  }

  List<SearchListModel> searchListModel = [];

  // Function to search and convert address to coordinates using Nominatim
  Future<void> _searchLocation(String query, bool isStartLocation) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&limit=10&countrycodes=BD&format=json');
    print("url...$url");
    final response = await http.get(url,
      headers: {
        'Accept-Language': 'en-US',
      },
    );
    dynamic data = json.decode(response.body);
    print("serach..response....${data.length}");
    searchListModel = [];
    for(var item in data){
      searchListModel.add(SearchListModel.fromJson(item));
    }
    print("s.....${searchListModel[0].displayName}");

   // logLargeString(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        double latitude = double.parse(data[0]['lat']);
        double longitude = double.parse(data[0]['lon']);
        setState(() {
          if (isStartLocation) {
            startLocation = LatLng(latitude, longitude);
          //  print("staar..location...insearch.....${startLocation}");
          } else {
            endLocation = LatLng(latitude, longitude);
           // print("endLocation..location...insearch.....${endLocation}");
          }
        });
        mapController.move(LatLng(latitude, longitude), zoomValue);
      }
    } else {
      print('Location search failed');
    }
  }

  //https://nominatim.openstreetmap.org/reverse?


  ReverseSearchModel? reverseSearchModel;

  // Function to search and convert address to coordinates using Nominatim
  Future<void> _reverseSearchLocation() async {

    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${latLng!.latitude}&lon=${latLng!.longitude}&format=json');
    print("serach..url....${url}");
    final response = await http.get(url);
    final data = json.decode(response.body);
 //   print("serach..response....${response.body}");
    reverseSearchModel = ReverseSearchModel.fromJson(data);
    await updateAddressDuringSwapping(reverseSearchModel!.displayName.toString());
    logLargeString(reverseSearchModel.toString());
    print(".....................");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        // double latitude = double.parse(data[0]['lat']);
        // double longitude = double.parse(data[0]['lon']);

       // mapController.move(LatLng(latLng!.latitude, latLng!.longitude), zoomValue);
      }
    } else {
      print('Location search failed');
    }
  }

  // Function to handle the Start button click
  Future<void> _onStartButtonClick() async {
    if ((startLocation != null || currentLocation != null) && endLocation != null) {
      startLocation = startLocation ?? currentLocation;
      setState(() {
        setOnMap = null;
      });
      await _fetchRoute(startLocation!, endLocation!);
     // await _fetchRoute();
      _startLocationTracking();
    } else {
      //await _fetchRoute();
      print('Please enter valid addresses');
    }
  }

  @override
  void initState() {
    super.initState();
    //_getUserLocation();
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        heading = event.heading;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Smooth transition duration
    );

    _animationController.addListener(() {
      setState(() {
        // Update the marker position with interpolated position
        startLocation = _positionAnimation?.value;
        if (startLocation != null) {
          mapController.move(startLocation!, zoomValue); // Move map to the new position
        }
      });
    });

  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        actions: [
          TextButton(onPressed: (){
            _getUserLocation();
          }, child: Text("my loca")),
          TextButton(onPressed: (){
            setState(() {
              setOnMap = true;
            });
          }, child: Text("set on")),
          TextButton(
              onPressed: (){
            endTrack();
          }, child: Text("end")),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startController,
                        decoration: InputDecoration(
                          labelText: 'Start Location',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          //if (value.isNotEmpty) _searchLocation(value, true);
                        },
                        onTap: (){
                          setState(() {
                            isStartingSearch = true;
                          });
                        },
                      ),
                    ),
                    TextButton(onPressed: (){
                       _searchLocation(startController.text, true);

                    }, child: Text("search")),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: endController,
                        decoration: InputDecoration(
                          labelText: 'End Location',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {

                        },
                        onTap: (){
                          setState(() {
                            isStartingSearch = false;
                          });
                        },
                      ),
                    ),
                    TextButton(onPressed: (){
                      _searchLocation(endController.text, false);
                    }, child: Text("search")),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: ()async{
                    //fetchValhallaRoute(start: startLocation);
                   // await _fetchRoute();

                    //for(int index=0; index<2000; index++){
                    //  print("index.............$index");
                      await _onStartButtonClick();
                   // }
                  },
                  child: Text('Start'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    onTap: (tapPosition, latLong){
                      final location = Geolocator.getCurrentPosition();
                      print("location....${location.hashCode}");
                    },
                    initialCenter: startLocation ?? LatLng(37.7749, -122.4194),
                    onPositionChanged: (mapCamera, flag){
                     // print("flag....$flag");
                     // print("mapCamera....${mapCamera.visibleBounds}");

                      //latLng = mapController.camera.pointToLatLng(Point(_getPointX(), pointY));
                      if(setOnMap == true){
                        updatePoint();
                      }
                    },
                    onPointerCancel: ( value, latLong){
                      print("value...${value}");
                    },
                    onMapEvent: (mapEvent)async{
                     // print("mapEvent.....${mapEvent.camera}");
                    //  print("mapEvent.....${mapEvent.hashCode}....${mapEvent.source}....${mapEvent.runtimeType}......");

                      if(MapEventSource.dragEnd == mapEvent.source && setOnMap == true){
                        //setOnMap = false;

                        await updateLocationDuringSwapping();
                        await _reverseSearchLocation();
                        setState(() {

                        });
                      }else if(MapEventSource.onDrag == mapEvent.source){
                       // setOnMap = true;
                        setState(() {

                        });
                      }

                    },
                  ),
                  children: [
                    openStreetMapTileLayer,
                    // TileLayer(
                    //   urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    //   subdomains: ['a', 'b', 'c'],
                    //
                    // ),
                    if (currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: currentLocation!,
                            rotate: true, // Enable rotation
                            child: Transform.rotate(
                              angle: (heading ?? 0) * (3.14159 / 180),
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (startLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: startLocation!,
                            rotate: true,
                            child: Icon(
                              currentLocation == startLocation ? Icons.navigation :  Icons.location_on,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    if (endLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: endLocation!,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ) ,
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
                if(setOnMap == true)Positioned(
                  top: pointY - pointSize / 2,
                  left: _getPointX() - pointSize / 2,
                  child:  IgnorePointer(
                    child: Icon(
                       Icons.location_on,
                      size: pointSize*0.5,
                      color: isStartingSearch ? Colors.blue : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    // Use the recommended flutter_map_cancellable_tile_provider package to
    // support the cancellation of loading tiles.
  );


  void updatePoint(){
    setState((){
     latLng = mapController.camera.pointToLatLng(Point(_getPointX(), pointY));

    });
  }

  double _getPointX() =>
      MediaQuery.sizeOf(context).width / 2;

  Future<void> updateLocationDuringSwapping()async{
    setState(() {
      if (isStartingSearch) {
        startLocation = LatLng(latLng!.latitude, latLng!.longitude);
        //print("staar..location...insearch.....${startLocation}");
      } else if(!isStartingSearch){
        endLocation = LatLng(latLng!.latitude, latLng!.longitude);
        // print("endLocation..location...insearch.....${endLocation}");
      }
    });
  }

  Future<void> updateAddressDuringSwapping(String address)async{
    setState(() {
      if (isStartingSearch) {
        startController.text = address;
      } else if(!isStartingSearch){
        endController.text = address;
      }
    });
  }

  Future<void> endTrack()async{
    currentLocation = null;
    startLocation = null;
    endLocation = null;
    positionStream?.cancel();
    routePoints = [];
    isStartingSearch = false;
    setOnMap = false;
    startController.clear();
    endController.clear();
    setState(() {

    });
  }


  /// Interpolate a point between two LatLng points at a specified fraction
  LatLng interpolatePoint(LatLng start, LatLng end, double fraction) {
    final lat = start.latitude + (end.latitude - start.latitude) * fraction;
    final lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
  }

  /// Calculate the distance in meters between two LatLng points
  double calculateDistance(LatLng start, LatLng end) {
    final distance = Distance();
    return distance(start, end);
  }

  Future<void> recalculateRoutePoints(List<LatLng> rawRoutePoints)async{
    List<LatLng> interpolatedRoutePoints = [];
    double targetDistance = 5.0; // Distance in meters between points

    for (int indexI = 0; indexI < rawRoutePoints.length - 1; indexI++) {
      LatLng start = rawRoutePoints[indexI];
      LatLng end = rawRoutePoints[indexI + 1];
      // Add the start point
      interpolatedRoutePoints.add(start);

      double distance = calculateDistance(start, end);

      if (distance > targetDistance) {
        int segments = (distance / targetDistance).floor();
        for (int indexJ = 1; indexJ < segments; indexJ++) {
          double fraction = indexJ * targetDistance / distance;
          interpolatedRoutePoints.add(interpolatePoint(start, end, fraction));
        }
      }
    }


    // Add the final point which was not included in loop
    interpolatedRoutePoints.add(rawRoutePoints.last);
    setState(() {
      routePoints = interpolatedRoutePoints;
    });

  }


}
