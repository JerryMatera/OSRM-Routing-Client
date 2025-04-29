import 'dart:convert';

import 'package:osrm_routing_client/src/models/request_helper.dart';
import 'package:osrm_routing_client/src/models/route.dart';
import 'package:osrm_routing_client/src/models/valhalla/valhalla_response.dart';
import 'package:osrm_routing_client/src/routes_services/routing_service.dart';
import 'package:osrm_routing_client/src/utilities/utils.dart';

class ValhallaRoutingService extends RoutingService {
  ValhallaRoutingService({String? valhallaServer, super.header})
    : super(serverURL: valhallaServer ?? osmValhallaServer);
  ValhallaRoutingService.dioClient({required super.client}) : super.dioClient();
  Future<Route> getValhallaRoad(ValhallaRequest request) async {
    final jsonHeaderRequest = request.encodeHeader();
    final response = await dio.get(
      osmValhallaServer,
      queryParameters: {'json': json.encode(jsonHeaderRequest)},
    );
    if (response.statusCode != null && response.statusCode! > 299 ||
        response.statusCode! < 200) {
      throw Exception("cannot get route");
    }
    final Map<String, dynamic> responseJson = response.data;
    final valhallaResp = ValhallaResponse.fromJson(responseJson);
    return valhallaResp.toRoute();
  }
}
