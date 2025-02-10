part of nb_navigation_flutter;

class NBNavMethodChannelsConstants {
  static const nbNavigationChannelName = "nb_navigation_flutter";
}

class NBRouteMethodID {
  static const nbFetchRouteMethod = "route/fetchRoute";

  static const nbRouteResultMethod = "route/routeResult";
  static const nbRouteSelectedIndexMethod = "route/findSelectedRouteIndex";

  static const routeFormattedDuration = "format/routeDuration";
  static const navigationCaptureRouteDurationSymbol =
      "capture/routeDurationSymbol";
  static const navigationCaptureRouteWaypoints = "capture/routeWayPoints";
}

class NBNavigationLauncherMethodID {
  static const nbNavigationLauncherMethod = "navigation/startNavigation";
  static const nbGetNavigationUriMethod = "navigation/getBaseUri";
  static const nbSetNavigationUriMethod = "navigation/setBaseUri";
  static const nbOnNavigationExit = "navigation/onNavigationExit";
  static const nbPreviewNavigationMethod = "navigation/previewNavigation";
}

class NBNavigationConfigMethodID {
  static const configSetUserId = "config/setUserId";

  static const configGetUserId = "config/getUserId";

  static const configGetNBId = "config/getNBId";
}
