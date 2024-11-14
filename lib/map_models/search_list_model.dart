class SearchListModel {
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
	List<String>? boundingbox;

	SearchListModel({this.placeId, this.licence, this.osmType, this.osmId, this.lat, this.lon, this.classType, this.type, this.placeRank, this.importance, this.addresstype, this.name, this.displayName, this.boundingbox});

	SearchListModel.fromJson(Map<String, dynamic> json) {
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
		boundingbox = json['boundingbox'].cast<String>();
	}

}