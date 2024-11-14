class ReverseSearchModel {
  String? placeId;
  String? licence;
  String? osmType;
  String? osmId;
  String? lat;
  String? lon;
  String? classType;
  String? type;
  String? placeRank;
  String? importance;
  String? addresstype;
  String? name;
  String? displayName;
  Address? address;
  List<String>? boundingbox;

  ReverseSearchModel({this.placeId, this.licence, this.osmType, this.osmId, this.lat, this.lon, this.classType, this.type, this.placeRank, this.importance, this.addresstype, this.name, this.displayName, this.address, this.boundingbox});

  ReverseSearchModel.fromJson(Map<String, dynamic> json) {
  placeId = json['place_id'].toString();
  licence = json['licence'].toString();
  osmType = json['osm_type'].toString();
  osmId = json['osm_id'].toString();
  lat = json['lat'].toString();
  lon = json['lon'].toString();
  classType = json['class'].toString();
  type = json['type'].toString();
  placeRank = json['place_rank'].toString();
  importance = json['importance'].toString();
  addresstype = json['addresstype'].toString();
  name = json['name'].toString();
  displayName = json['display_name'].toString();
  address = json['address'] != null ?  Address.fromJson(json['address']) : null;
  boundingbox = json['boundingbox'].cast<String>();
  }

  @override
  String toString() {
    return 'ReverseSearchModel{placeId: $placeId, licence: $licence, osmType: $osmType, osmId: $osmId, lat: $lat, lon: $lon, classType: $classType, type: $type, placeRank: $placeRank, importance: $importance, addresstype: $addresstype, name: $name, displayName: $displayName, address: $address, boundingbox: $boundingbox}';
  }
}

class Address {
  String? amenity;
  String? road;
  String? commercial;
  String? suburb;
  String? borough;
  String? city;
  String? municipality;
  String? stateDistrict;
  String? iSO31662Lvl5;
  String? state;
  String? iSO31662Lvl4;
  String? postcode;
  String? country;
  String? countryCode;

  Address({this.amenity, this.road, this.commercial, this.suburb, this.borough, this.city, this.municipality, this.stateDistrict, this.iSO31662Lvl5, this.state, this.iSO31662Lvl4, this.postcode, this.country, this.countryCode});

  Address.fromJson(Map<String, dynamic> json) {
    amenity = json['amenity'].toString();
    road = json['road'].toString();
    commercial = json['commercial'].toString();
    suburb = json['suburb'].toString();
    borough = json['borough'].toString();
    city = json['city'].toString();
    municipality = json['municipality'].toString();
    stateDistrict = json['state_district'].toString();
    iSO31662Lvl5 = json['ISO3166-2-lvl5'].toString();
    state = json['state'].toString();
    iSO31662Lvl4 = json['ISO3166-2-lvl4'].toString();
    postcode = json['postcode'].toString();
    country = json['country'].toString();
    countryCode = json['country_code'].toString();
  }

  @override
  String toString() {
    return 'Address{amenity: $amenity, road: $road, commercial: $commercial, suburb: $suburb, borough: $borough, city: $city, municipality: $municipality, stateDistrict: $stateDistrict, iSO31662Lvl5: $iSO31662Lvl5, state: $state, iSO31662Lvl4: $iSO31662Lvl4, postcode: $postcode, country: $country, countryCode: $countryCode}';
  }
}