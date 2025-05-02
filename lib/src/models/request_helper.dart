import 'package:osrm_routing_client/routing_client_dart.dart';
import 'package:osrm_routing_client/src/utilities/utils.dart';

enum HeaderServiceType { osrm, openroute, valhalla }

abstract class BaseRequest<T> {
  final List<LngLat> waypoints;
  final Languages languages;
  final int alternatives;

  const BaseRequest({
    required this.waypoints,
    this.languages = Languages.en,
    this.alternatives = 2,
  });

  T encodeHeader();
}

class OSRMRequest extends BaseRequest<String> {
  final Profile profile;
  final RoutingType routingType;
  final bool steps;
  final Overview overview;
  final Geometries geometries;
  final bool roundTrip;
  final SourceGeoPointOption source;
  final DestinationGeoPointOption destination;
  final bool? hasAlternative;
  const OSRMRequest.route({
    required super.waypoints,
    super.languages,
    this.routingType = RoutingType.car,
    this.steps = true,
    this.overview = Overview.full,
    this.geometries = Geometries.polyline,
    bool? alternatives = false,
  }) : profile = Profile.route,
       roundTrip = false,
       source = SourceGeoPointOption.any,
       hasAlternative = alternatives,
       destination = DestinationGeoPointOption.any;
  const OSRMRequest.trip({
    required super.waypoints,
    super.languages,
    this.routingType = RoutingType.car,
    this.steps = true,
    this.overview = Overview.full,
    this.geometries = Geometries.polyline,
    this.roundTrip = true,
    this.source = SourceGeoPointOption.any,
    this.destination = DestinationGeoPointOption.any,
  }) : profile = Profile.trip,
       hasAlternative = null;
  @override
  String encodeHeader() {
    String baseURLOptions =
        "/routed-${routingType.name}/${profile.name}/v1/driving/${waypoints.toWaypoints()}";
    var option = "";
    option += "steps=$steps&";
    option += "overview=${overview.value}&";
    option += "geometries=${geometries.value}";
    if (hasAlternative != null) {
      option += "&alternatives=$hasAlternative";
    }

    if (profile == Profile.trip) {
      option +=
          "&source=${source.name}&destination=${destination.name}&roundtrip=$roundTrip";
    }
    return "$baseURLOptions?$option";
  }
}

// Function to convert nested List<LngLat> to nested List<List<double>>
List<dynamic> convertNestedLngLatToList(List<dynamic> nestedList) {
  if (nestedList.isEmpty) {
    return [];
  }
  return nestedList.map((element) {
    if (element is List) {
      return convertNestedLngLatToList(element);
    } else if (element is LngLat) {
      return element.toMap();
    }
    return element;
  }).toList();
}
