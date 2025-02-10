

import 'event_simulator.dart';

class NavAutomator {
  static Future<void> grantLocationPermissions() async {
    await EventSimulator.grantPermission('android.permission.ACCESS_FINE_LOCATION');
    // await EventSimulator.grantPermission('android.permission.CAMERA');
    // await EventSimulator.grantPermission('android.permission.WRITE_EXTERNAL_STORAGE');
    // await EventSimulator.grantPermission('android.permission.READ_PHONE_STATE');
  }


}