import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:nb_maps_flutter/nb_maps_flutter.dart';
import 'package:nb_navigation_flutter/navigation/nb_map_controller_wrapper.dart';
import 'package:nb_navigation_flutter/navigation/navigation_map.dart';
import 'package:nb_navigation_flutter/util/asset_manager.dart';
export 'package:nb_maps_flutter/nb_maps_flutter.dart';

part 'model/banner_instructions.dart';
part 'model/directions_route.dart';
part 'model/intersections.dart';
part 'model/maneuver.dart';
part 'model/navigation_launcher_config.dart';
part 'model/route_request_params.dart';
part 'model/route_request_params_constants.dart';
part 'model/route_step.dart';
part 'model/route_response.dart';

part 'platform_channels/nb_navigation.dart';
part 'platform_channels/nb_navigation_method_channels.dart';
part 'platform_channels/nb_navigation_platform_constant.dart';
part 'platform_channels/nb_navigation_method_channels_factory.dart';
part 'platform_channels/nb_navigation_platform.dart';

part 'navigation/nb_navigation_constants.dart';
part 'navigation/nb_navigation_map.dart';
part 'navigation/route_layer_provider.dart';
part 'navigation/route_line_properties.dart';

part 'util/line_utils.dart';
part 'util/time_format.dart';

part 'view/nb_navigation_view.dart';
part 'view/navigation_view_controller.dart';
part 'platform_channels/navigation_view_method_channel.dart';
part 'platform_channels/navigation_view_platform.dart';
part 'model/navigation_progress.dart';
part 'model/waypoint.dart';
part 'model/congestion_level.dart';
