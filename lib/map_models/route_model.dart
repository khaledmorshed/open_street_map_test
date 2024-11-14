class RouteModel {
  RouteModel({
    required this.code,
    required this.routes,
    required this.waypoints,
  });

  final String? code;
  final List<Route> routes;
  final List<Waypoint> waypoints;

  factory RouteModel.fromJson(Map<String, dynamic> json){
    return RouteModel(
      code: json["code"],
      routes: json["routes"] == null ? [] : List<Route>.from(json["routes"]!.map((x) => Route.fromJson(x))),
      waypoints: json["waypoints"] == null ? [] : List<Waypoint>.from(json["waypoints"]!.map((x) => Waypoint.fromJson(x))),
    );
  }

  @override
  String toString(){
    return "$code, $routes, $waypoints, ";
  }
}

class Route {
  Route({
    required this.geometry,
    required this.legs,
    required this.weightName,
    required this.weight,
    required this.duration,
    required this.distance,
  });

  final Geometry? geometry;
  final List<Leg> legs;
  final String? weightName;
  final String? weight;
  final String? duration;
  final String? distance;

  factory Route.fromJson(Map<String, dynamic> json){
    return Route(
      geometry: json["geometry"] == null ? null : Geometry.fromJson(json["geometry"]),
      legs: json["legs"] == null ? [] : List<Leg>.from(json["legs"]!.map((x) => Leg.fromJson(x))),
      weightName: json["weight_name"].toString(),
      weight: json["weight"].toString(),
      duration: json["duration"].toString(),
      distance: json["distance"].toString(),
    );
  }

  @override
  String toString(){
    return "$geometry, $legs, $weightName, $weight, $duration, $distance, ";
  }
}

class Geometry {
  Geometry({
    required this.coordinates,
    required this.type,
  });

  final List<List<String>> coordinates;
  final String? type;

  factory Geometry.fromJson(Map<String, dynamic> json){
    return Geometry(
      coordinates: json["coordinates"] == null ? [] : List<List<String>>.from(json["coordinates"]!.map((x) => x.toString() == null.toString() ? [] : List<String>.from(x!.map((x) => x.toString())))),
      type: json["type"],
    );
  }

  @override
  String toString(){
    return "$coordinates, $type, ";
  }
}

class Leg {
  Leg({
    required this.steps,
    required this.summary,
    required this.weight,
    required this.duration,
    required this.distance,
  });

  final List<dynamic> steps;
  final String? summary;
  final String? weight;
  final String? duration;
  final String? distance;

  factory Leg.fromJson(Map<String, dynamic> json){
    return Leg(
      steps: json["steps"] == null ? [] : List<dynamic>.from(json["steps"]!.map((x) => x)),
      summary: json["summary"].toString(),
      weight: json["weight"].toString(),
      duration: json["duration"].toString(),
      distance: json["distance"].toString(),
    );
  }

  @override
  String toString(){
    return "$steps, $summary, $weight, $duration, $distance, ";
  }
}

class Waypoint {
  Waypoint({
    required this.hint,
    required this.distance,
    required this.name,
    required this.location,
  });

  final String? hint;
  final String? distance;
  final String? name;
  final List<String> location;

  factory Waypoint.fromJson(Map<String, dynamic> json){
    return Waypoint(
      hint: json["hint"].toString(),
      distance: json["distance"].toString(),
      name: json["name"].toString(),
      location: json["location"] == null ? [] : List<String>.from(json["location"]!.map((x) => x.toString())),
    );
  }

  @override
  String toString(){
    return "$hint, $distance, $name, $location, ";
  }
}
