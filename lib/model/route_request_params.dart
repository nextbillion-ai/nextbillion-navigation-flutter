part of '../nb_navigation_flutter.dart';

/// Represents the request parameters for a route.
/// Refer to Navigation API https://docs.nextbillion.ai/docs/navigation/api/navigation
class RouteRequestParams {
  /// The origin point of route request.
  LatLng origin;

  /// The destination point of route request.
  LatLng destination;

  int? altCount;

  /// Whether to try to return alternative routes (true) or not (false, default). An alternative
  /// route is a route that is significantly different than the fastest route, but also still
  /// reasonably fast. Such a route does not exist in all circumstances. Up to two alternatives may
  /// be returned.
  /// The default is false.
  bool? alternatives;

  /// The route classes that the calculated routes will avoid.
  /// Possible values are:
  /// [SupportedAvoid.toll]
  /// [SupportedAvoid.ferry]
  /// [SupportedAvoid.highway]
  /// [SupportedAvoid.none]
  /// Please note that when this parameter is not provided in the input, [SupportedAvoid.ferry] are set to be avoided by default.
  /// When this parameter is provided, only the mentioned objects are avoided.
  @Deprecated("This property is deprecated. Use [avoidType] instead.")
  List<SupportedAvoid>? avoid;

  /// The route classes that the calculated routes will avoid.
  /// Possible values are:
  /// [toll], [highway], [ferry], [sharp_turn], [turn], [service_road], [left_turn], [right_turn], [bbox], [geofence_id], [none]
  /// Please note that when this parameter is not provided in the input, [ferry] are set to be avoided by default.
  /// When this parameter is provided, only the mentioned objects are avoided.
  List<String>? avoidType;

  ///The same base URL which was used during the request that resulted in this root directions
  String? baseUrl;
  int? departureTime;

  /// A valid Nbmap access token used to making the request.
  String? key;

  /// The language of returned turn-by-turn text instructions. The default is en (English).
  String? language;

  /// A string specifying the primary mode of transportation for the routes.
  /// This parameter, if set, should be set to
  /// [ValidModes.car], [ValidModes.truck]
  /// [ValidModes.car] is used by default.
  ValidModes? mode;

  /// Displays the requested type of overview geometry. Can be
  /// [ValidOverview.full], [ValidOverview.simplified], [ValidOverview.none].
  /// The default is [ValidOverview.full].
  ValidOverview? overview;

  bool? simulation;

  /// This parameter defines the weight of the truck including trailers and shipped goods in kilograms (kg).
  /// Minimum: 1
  /// Maximum: 100000
  /// This parameter is effective only when the mode=[ValidModes.truck] and option = [SupportedOption.flexible]
  int? truckWeight;

  /// This defines the dimensions of a truck in centimeters (cm).
  /// This should be specified if the route involves a truck, and the size restrictions may affect the route calculation.
  /// The list contains the dimensions of the truck in the order [height, width, length].
  /// Maximum dimensions are as follows:
  /// Height = 1000 cm
  /// Width = 5000 cm
  /// Length = 5000 cm
  /// This parameter is effective only when the mode=[ValidModes.truck] and option = [SupportedOption.flexible]
  List<int>? truckSize;

  /// The unit of measurement of the route. Can be
  /// [SupportedUnits.imperial], [SupportedUnits.metric]
  /// The default is [SupportedUnits.metric].
  SupportedUnits? unit;

  /// A list of Points to visit in order.
  /// Note that these coordinates are different than the direction responses
  /// waypoints that these are the non-snapped coordinates.
  List<LatLng>? waypoints;

  /// Allowed Values:
  /// [SupportedOption.fast] gets the directions and route guidance in real time for trips starting at current time.
  /// The routes returned through this service have the traffic conditions factored in to avoid any delays under usual circumstances.
  ///
  /// [SupportedOption.flexible] offers customizable features for advanced navigation experience.
  /// It serves requests for truck specific routing, time based routing, allows choosing between fastest and shortest route types and also offers to return segment-wise speed limits of the route suggested.
  /// The traffic conditions are also factored in by the service to avoid delays under usual circumstances.
  ///
  /// The default is [SupportedOption.fast].
  SupportedOption? option;

  /// The format of the returned geometry. Allowed values are:
  /// [SupportedGeometry.polyline], [SupportedGeometry.polyline6]
  /// The default is [SupportedGeometry.polyline6].
  SupportedGeometry? geometry;

  /// Specify the type of hazardous material being carried and the service will avoid roads which are not suitable for the type of goods specified.
  /// Please note that this parameter is effective only when mode=truck.
  /// @return  a string  list representing the avoid types . Allowed Values:
  /// [SupportedHazmatType.general]
  /// [SupportedHazmatType.circumstantial]
  /// [SupportedHazmatType.explosive]
  /// [SupportedHazmatType.harmfulToWater]
  List<SupportedHazmatType>? hazmatType;

  /// Indicates from which side of the road to approach a waypoint.
  /// Accepts [SupportedApproaches.unrestricted] (default) or
  /// [SupportedApproaches.curb].
  /// If set to [SupportedApproaches.unrestricted], the route can approach waypoints
  /// from either side of the road.
  /// If set to [SupportedApproaches.curb], the route will be returned so that on
  /// arrival, the waypoint will be found on the side that corresponds with the driving_side of the
  /// region in which the returned route is located.
  /// If provided, the list of approaches must be the same length as the list of waypoints.
  ///
  /// @return a string representing approaches for each waypoint
  List<SupportedApproaches>? approaches;

  /// Specify if crossing an international border is expected for operations near border areas.
  /// When set to false, the API will prohibit routes going back & forth between countries.
  /// Consequently, routes within the same country will be preferred if they are feasible for the given set of destination or waypoints.
  /// When set to true, the routes will be allowed to go back & forth between countries as needed.
  ///
  /// This feature is available in North America region only. Please get in touch with support@nextbillion.ai to enquire/enable other areas.
  bool? crossBorder;

  /// Specify the total load per axle (including the weight of trailers and shipped goods) of the truck, in tonnes.
  /// When used, the service will return routes which are legally allowed to carry the load specified per axle.
  ///
  /// Please note this parameter is effective only when `mode=truck`.
  num? truckAxleLoad;

  /// Possible values are: [taxi], [hov]
  String? allow;

  /// The type of route to calculate. The default is [RouteType.fastest].
  /// The [RouteType.shortest] only available for [RouteRequestParams.option] set as [SupportedOption.flexible]
  RouteType? routeType;

  RouteRequestParams({
    required this.origin,
    required this.destination,
    this.altCount,
    this.alternatives,
    this.avoid,
    this.avoidType,
    this.baseUrl,
    this.departureTime,
    this.key,
    this.language,
    this.mode,
    this.overview,
    this.simulation,
    this.truckWeight,
    this.truckSize,
    this.unit,
    this.waypoints,
    this.option,
    this.geometry,
    this.hazmatType,
    this.approaches,
    this.crossBorder,
    this.truckAxleLoad,
    this.allow,
    this.routeType,
  }) : assert(
  mode != ValidModes.truck ||
      (truckWeight == null || (truckWeight >= 1 && truckWeight <= 100000)),
  'truckWeight must be between 1 and 100000 kg when mode is truck',
  ),
        assert(
        mode != ValidModes.truck ||
            (truckSize == null ||
                (truckSize.length == 3 &&
                    truckSize[0] <= 1000 &&
                    truckSize[1] <= 5000 &&
                    truckSize[2] <= 5000)),
        'truckSize must have exactly 3 values [height, width, length] and must not exceed: height=1000 cm, width=5000 cm, length=5000 cm when mode is truck',
        );

  factory RouteRequestParams.fromJson(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw ArgumentError('RouteRequestParams cannot be empty. Received: $map');
    }

    LatLng parseLatLng(dynamic value) {
      if (value is List && value.length == 2) {
        final lat = value[1];
        final lng = value[0];
        if (lat is num && lng is num) {
          return LatLng(lat.toDouble(), lng.toDouble());
        }
      }
      throw ArgumentError('LatLng is invalid. Received: $value');
    }

    List<int>? parseTruckSize(dynamic value) {
      if (value is List) {
        return value.map((item) {
          if (item is String) {
            return int.tryParse(item) ?? 0;
          } else if (item is int) {
            return item;
          }
          return 0;
        }).toList();
      }
      return null;
    }

    return RouteRequestParams(
      altCount: map['altCount'] as int?,
      alternatives: map['alternatives'] as bool?,
      avoid: (map['avoid'] as List<dynamic>?)?.map((x) => SupportedAvoid.fromValue(x as String?)).toList(),
      avoidType: (map['avoidType'] as List?)?.map((x) => x.toString()).toList() ??
          (map['avoid'] as List?)?.map((x) => x.toString()).toList() ??
          [],
      baseUrl: map['baseUrl'] as String?,
      departureTime: map['departureTime'] as int?,
      destination: parseLatLng(map['destination']),
      key: map['key'] as String?,
      language: map['language'] as String?,
      mode: ValidModes.fromValue(map['mode'] as String?),
      origin: parseLatLng(map['origin']),
      overview: ValidOverview.fromValue(map['overview'] as String?),
      simulation: map['simulation'] as bool?,
      truckWeight: map['truckWeight'] as int?,
      truckSize: parseTruckSize(map['truckSize']),
      unit: SupportedUnits.fromValue(map['unit'] as String?),
      option: SupportedOption.fromValue(map['option'] as String?),
      geometry: SupportedGeometry.fromValue(map["geometry"] as String?),
      waypoints: (map['waypoints'] as List?)
          ?.map((point) => parseLatLng(point))
          .toList() ??
          [],
      hazmatType: (map['hazmatType'] as List<String>?)
          ?.map((x) => SupportedHazmatType.fromValue(x))
          .whereType<SupportedHazmatType>()
          .toList() ??
          [],
      approaches: (map['approaches'] as List<String>?)
          ?.map((x) => SupportedApproaches.fromValue(x))
          .whereType<SupportedApproaches>()
          .toList() ??
          [],
      crossBorder: map['crossBorder'] as bool?,
      truckAxleLoad: (map['truckAxleLoad'] as num?)?.toDouble(),
      allow: map['allow'] as String?,
      routeType: RouteType.fromValue(map['routeType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'altCount': altCount,
      'alternatives': alternatives,
      'avoid': avoidType?.isNotEmpty == true ? avoidType : [],
      'approaches': approaches?.map((e) => e.description).toList(),
      'baseUrl': baseUrl,
      'departureTime': departureTime,
      'destination': destination.toGeoJsonCoordinates(),
      'key': key,
      'language': language,
      'mode': mode?.description,
      'origin': origin.toGeoJsonCoordinates(),
      'overview': overview?.description,
      'simulation': simulation,
      'truckWeight': truckWeight,
      'truckSize': truckSize,
      'unit': unit?.description,
      'option': option?.description,
      'geometry': geometry?.description,
      'waypoints': waypoints?.map((e) => e.toGeoJsonCoordinates()).toList(),
      'hazmatType': hazmatType?.map((e) => e.description).toList(),
      'crossBorder': crossBorder,
      'truckAxleLoad': truckAxleLoad,
      'allow': allow,
      'routeType': routeType?.description,
    };
  }
}
