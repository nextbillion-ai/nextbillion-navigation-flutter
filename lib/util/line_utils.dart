part of nb_navigation_flutter;

List<LatLng> decode(String encodedPath, int precision) {
  int len = encodedPath.length;

  // OSRM uses precision=6, the default Polyline spec divides by 1E5, capping at precision=5
  num factor = pow(10, precision);

  // For speed we preallocate to an upper bound on the final length, then
  // truncate the array before returning.
  List<LatLng> path = [];
  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < len) {
    int result = 1;
    int shift = 0;
    int temp;
    do {
      temp = encodedPath.codeUnitAt(index++) - 63 - 1;
      result += temp << shift;
      shift += 5;
    } while (temp >= 0x1f);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    result = 1;
    shift = 0;
    do {
      temp = encodedPath.codeUnitAt(index++) - 63 - 1;
      result += temp << shift;
      shift += 5;
    } while (temp >= 0x1f);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    path.add(LatLng(lat / factor, lng / factor));
  }

  return path;
}
