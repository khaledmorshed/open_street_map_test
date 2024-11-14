import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
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

class _MapScreenState extends State<MapScreen> {
  //
  MapController mapController = MapController();
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
        startLocation = LatLng(position.latitude, position.longitude);
      });
      print("start location....${startLocation}");
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
      _startLocationTracking();
    } catch (e) {
      print("Error getting location: $e");
    }
  }



  // //valhalla
  // Future<void> _fetchRoute(LatLng start, LatLng end) async {
  //   // Choose vehicle type: foot, car, bike
  //   String vehicle = "pedestrian";
  //   int maxDistance = 10; // Adjust this distance for more/less detailed route points
  //
  //   //  //https://valhalla.openstreetmap.de/directions?profile=bicycle
  //
  //   //https://valhalla.openstreetmap.de/directions?profile=pedestrian&wps=90.4211957%2C23.7272598%2C90.3871113%2C23.7590394
  //
  //   final url = Uri.parse(
  //     'https://valhalla.openstreetmap.de/directions?profile=$vehicle',
  //   );
  //
  //   print("Route URL: $url");
  //
  //   final response = await http.get(url);
  //   print("Route response: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final points = data['paths'][0]['points']['coordinates']; // Access unencoded coordinates
  //
  //     // Convert coordinates to a list of LatLng points
  //     setState(() {
  //       routePoints = points.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
  //     });
  //   } else {
  //     print('Failed to fetch route');
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchLocationSuggestions(String query) async {
    final url = Uri.parse(
      'https://graphhopper.com/api/1/geocode?q=$query&limit=5&locale=en&key=$apiKey',
    );

    final response = await http.get(url);
  //  print("reponse...${response.body}");
    final data = json.decode(response.body);
    print("reponse...${data["hits"]}");
    
    for(var item in data["hits"]){
      print("reponse...${item}");
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> results = [];

      // Parse the response and get matching locations
      for (var item in data['hits']) {
        results.add({
          'name': item['name'],
          'lat': item['point']['lat'],
          'lon': item['point']['lng'],
          'address': item['street'] ?? '' // Use other fields as needed
        });
      }
      return results;
    } else {
      throw Exception('Failed to fetch location suggestions');
    }
  }


  Future<void> fetchValhallaRoute({ LatLng? start}) async {
    print("ts.....");
   // final url = Uri.parse('http://localhost:8002/route?json={"locations":[{"lat":${start.latitude},"lon":${start.longitude}}],"costing":"auto","directions_options":{"units":"kilometers"}}');
    final url = Uri.parse('http://192.168.0.106:8002/route?json={"locations":[{"lat":51.50799,"lon":-0.08008},{"lat":51.505517,"lon":-0.075367}],"costing":"auto","directions_options":{"units":"kilometers"}}');
   // final url = Uri.parse('http://192.168.0.1:8002/route?json={"locations":[{"lat":23.777176,"lon":90.399452}],"costing":"auto","directions_options":{"units":"kilometers"}}');
 //   print("url...$url");

    final response = await http.get(url);
    print("response...${response.body}");


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> shape = data['trip']['legs'][0]['shape'];

      return ;
    } else {
      throw Exception('Failed to fetch route');
    }
  }





  Future<void> addAddressToOSM() async {
    // Your authentication token here (OAuth required)
    final String oauthToken = 'YOUR_OAUTH_TOKEN';

    // Example address data (you may need more fields based on what you want to add)
    final Map<String, String> addressData = {
      'lat': '52.5200', // latitude of the address
      'lon': '13.4050', // longitude of the address
      'address': 'Your address name here', // Example address
      // other relevant OSM node data
    };

    final Uri url = Uri.parse('https://api.openstreetmap.org/api/0.6/node/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $oauthToken', // Authorization header with OAuth token
      },
      body: json.encode(addressData),
    );

    if (response.statusCode == 200) {
      print('Address added successfully');
    } else {
      print('Failed to add address: ${response.statusCode}');
    }
  }


  // Future<void> _fetchRoute(LatLng start, LatLng end) async {
  //   // Construct the URL with start and end coordinates, and vehicle type
  //   String vehicle = "pedestrian";
  //   // final url = Uri.parse(
  //   //     'https://valhalla.openstreetmap.de/directions?'
  //   //         'profile=$vehicle&'
  //   //         'point=${startLocation!.longitude},${startLocation!.latitude},${endLocation!.longitude},${endLocation!.latitude}'
  //   // );
  //
  //   final url = Uri.parse(
  //       'https://valhalla.openstreetmap.de/valhalla/directions?profile=$vehicle&wps=${start.longitude},${start.latitude},${end.longitude},${end.latitude}'
  //   );
  //
  //
  //   print("Route URL: $url");
  //
  //   final response = await http.get(url);
  //   print("Route response: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final coordinates = data['trip']['legs'][0]['shape'];
  //
  //     PolylinePoints polylinePoints = PolylinePoints();
  //     List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(coordinates);
  //
  //     setState(() {
  //       routePoints = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
  //     });
  //     // Do something with routePoints, like updating the UI
  //     print('Route Points: $routePoints');
  //   } else {
  //     print('Failed to fetch route: ${response.statusCode}');
  //   }
  // }

  // Future<void> _fetchRoute(/*LatLng start, LatLng end*/) async {
  //   // Construct the URL with start and end coordinates, and vehicle type
  //   String vehicle = "pedestrian";
  //   // final url = Uri.parse(
  //   //     'https://valhalla.openstreetmap.de/directions?'
  //   //         'profile=$vehicle&'
  //   //         'point=${startLocation!.longitude},${startLocation!.latitude},${endLocation!.longitude},${endLocation!.latitude}'
  //   // );
  //
  //   final url = Uri.parse(
  //       'https://valhalla1.openstreetmap.de/route?json={"locations":[{"options":{"allowUTurn":false},"latLng":{"lat":23.734990618115763,"lng":90.4174661631987},"_initHooksCalled":true,"lat":23.734990618115763,"lon":90.4174661631987}],"costing":"$vehicle","directions_options":{"language":"en-US"}}&access_token='
  //   );
  //
  //
  //   //https://valhalla1.openstreetmap.de/route?json={"locations":[{"options":{"allowUTurn":false},"latLng":{"lat":40.814328907637126,"lng":-74.22168732038699},"_initHooksCalled":true,"lat":40.814328907637126,"lon":-74.22168732038699},{"options":{"allowUTurn":false},"latLng":{"lat":40.761300880922235,"lng":-74.08229828230105},"_initHooksCalled":true,"lat":40.761300880922235,"lon":-74.08229828230105}],"costing":"auto","directions_options":{"language":"en-US"}}&access_token=
  //
  //   print("Route URL: $url");
  //
  //   final response = await http.get(url);
  //   //print("Route response: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final coordinates = data['trip']['legs'][0]['shape'];
  //     print("coordinates...${coordinates}");
  //
  //     PolylinePoints polylinePoints = PolylinePoints();
  //     List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(coordinates);
  //
  //     setState(() {
  //       routePoints = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
  //     });
  //
  //     mapController.move(routePoints.first, 12);
  //     // Do something with routePoints, like updating the UI
  //     // print('Route Points: $routePoints');
  //   } else {
  //     print('Failed to fetch route: ${response.statusCode}');
  //   }
  // }




  // /// Fetch route with Graphhopper API
  // Future<void> _fetchRoute(LatLng start, LatLng end) async {
  //   final url = Uri.parse(
  //     'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=car&locale=en&key=$apiKey',
  //   );
  //   print("url....${url}");
  //
  //   final response = await http.get(url);
  //   print("response.roure...${response.body}");
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final encodedPoints = data['paths'][0]['points'];
  //     PolylinePoints polylinePoints = PolylinePoints();
  //     List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPoints);
  //
  //     setState(() {
  //       routePoints = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
  //     });
  //   } else {
  //     print('Failed to fetch route');
  //   }
  // }

  /// route with graphhoper
  // Future<void> _fetchRoute(LatLng start, LatLng end) async {
  //   // foot, car, bike
  //   String vehicle = "foot";
  //   final url = Uri.parse(
  //     'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=$vehicle&locale=en&key=$apiKey',
  //   );
  //
  //   print("Route URL: $url");
  //
  //   final response = await http.get(url);
  //   print("Route response: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final encodedPoints = data['paths'][0]['points']; // Get the encoded polyline points
  //     print("encodedPoints....${encodedPoints}");
  //
  //     // Decode the encoded polyline
  //     PolylinePoints polylinePoints = PolylinePoints();
  //     List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPoints);
  //
  //     setState(() {
  //       routePoints = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
  //     });
  //   } else {
  //     print('Failed to fetch route');
  //   }
  // }



  // Future<void> _fetchRoute(LatLng start, LatLng end) async {
  //   // Choose vehicle type: foot, car, bike
  //   String vehicle = "foot";
  //   int maxDistance = 10; // Adjust this distance for more/less detailed route points
  //
  //   final url = Uri.parse(
  //     'https://graphhopper.com/api/1/route?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=$vehicle&locale=en&points_encoded=false&elevation=false&way_point_max_distance=$maxDistance&key=$apiKey',
  //   );
  //
  //   print("Route URL: $url");
  //
  //   final response = await http.get(url);
  //   print("Route response: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final points = data['paths'][0]['points']['coordinates']; // Access unencoded coordinates
  //
  //     // Convert coordinates to a list of LatLng points
  //     setState(() {
  //       routePoints = points.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
  //     });
  //   } else {
  //     print('Failed to fetch route');
  //   }
  // }






  // //
  // Future<void> _fetchRoute(LatLng start, LatLng end) async {
  //   // Choose vehicle type: foot, car, bike
  //   String vehicle = "foot";
  //   int maxDistance = 10; // Adjust this distance for more/less detailed route points
  //
  //   var value = 'point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&'
  //       'profile=$vehicle&locale=de&calc_points=true&'
  //       'instructions=true&points_encoded=false&'
  //       'elevation=false&debug=false&'
  //       'optimize=false&algorithm=alternative_route&'
  //       'alternative_route.max_paths=3'
  //       '&alternative_route.max_weight_factor=1.4&'
  //       'alternative_route.max_share_factor=0.6';
  //
  //   final url = Uri.parse(
  //       'https://graphhopper.com/api/1/route?$value&key=$apiKey'
  //   );
  //   print("Route URL: $url");
  //
  //   final response = await http.get(url);
  //   print("Route response: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //
  //     final data = json.decode(response.body);
  //     final points = data['paths'][0]['points']['coordinates'];
  //
  //     // Convert coordinates to a list of LatLng points
  //     setState(() {
  //       routePoints = points.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
  //     });
  //
  //   } else {
  //     print('Failed to fetch route');
  //   }
  // }


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
      routePoints = [];

      setState(() {
        routePoints = coordinates.map<LatLng>((point) {
          return LatLng(point[1], point[0]);
        }).toList();
      });
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
      distanceFilter: 10,
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

        for(int index = 0; index<routePoints.length-1; index++){
          print("distance..lo..$index..${_distanceBetween(routePoints[index], routePoints[index+1])}");
        }

        if(routePoints.isNotEmpty)print("totla distan.ce......${_distanceBetween(routePoints[0], routePoints.last)}");

       // Remove points that have been passed

        if (routePoints.isNotEmpty) {
          routePoints.removeWhere((point){
            double value = _distanceBetween(currentLocation, point);
            ///print("value.....re....$value");
            return value < 50;
          }); // Adjust threshold as needed
          // Update startLocation to the first remaining point in routePoints if there are any
          if (routePoints.isNotEmpty) {
            startLocation = routePoints.first;
            mapController.move(startLocation!, zoomValue);
            return;
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

  bool isStartingSearch = false;
  bool setOnMap = false;
  ReverseSearchModel? reverseSearchModel;

  // Function to search and convert address to coordinates using Nominatim
  Future<void> _reverseSearchLocation() async {
    setState(() {
      if (isStartingSearch) {
        startLocation = LatLng(latLng!.latitude, latLng!.longitude);
        //print("staar..location...insearch.....${startLocation}");
      } else {
        endLocation = LatLng(latLng!.latitude, latLng!.longitude);
       // print("endLocation..location...insearch.....${endLocation}");
      }
    });
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${latLng!.latitude}&lon=${latLng!.longitude}&format=json');
    print("serach..url....${url}");
    final response = await http.get(url);
    final data = json.decode(response.body);
 //   print("serach..response....${response.body}");
    reverseSearchModel = ReverseSearchModel.fromJson(data);
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
    if (startLocation != null && endLocation != null) {
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
  }

  @override
  void dispose() {
    positionStream?.cancel(); // Stop tracking when the widget is disposed
    super.dispose();
  }

  // // Get user's initial location
  // Future<void> _getUserLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     startLocation = LatLng(position.latitude, position.longitude);
  //   });
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map with Routing & Live Tracking"),
        actions: [
          TextButton(onPressed: (){
            _getUserLocation();
          }, child: Text("mylocation"))
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
                     // updatePoint();

                    },
                    onPointerCancel: ( value, latLong){
                      print("value...${value}");
                    },
                    onMapEvent: (mapEvent){
                     // print("mapEvent.....${mapEvent.camera}");
                    //  print("mapEvent.....${mapEvent.hashCode}....${mapEvent.source}....${mapEvent.runtimeType}......");

                      if(MapEventSource.dragEnd == mapEvent.source){
                        setOnMap = false;
                     //   _reverseSearchLocation();
                        setState(() {

                        });
                      }else if(MapEventSource.onDrag == mapEvent.source){
                        setOnMap = true;
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
                    if (startLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: startLocation!,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 40,
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
                              size: 40,
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
                if(setOnMap)Positioned(
                  top: pointY - pointSize / 2,
                  left: _getPointX() - pointSize / 2,
                  child: const IgnorePointer(
                    child: Icon(
                      Icons.location_pin,
                      size: pointSize*0.5,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Positioned(
                //   top: pointY + pointSize / 2 + 6,
                //   left: 0,
                //   right: 0,
                //   child: IgnorePointer(
                //     child: Text(
                //       '(${latLng?.latitude.toStringAsFixed(3)},${latLng?.longitude.toStringAsFixed(3)})',
                //       textAlign: TextAlign.center,
                //       style: const TextStyle(
                //         color: Colors.black,
                //         fontWeight: FontWeight.bold,
                //         fontSize: 14,
                //       ),
                //     ),
                //   ),
                // ),
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

}
