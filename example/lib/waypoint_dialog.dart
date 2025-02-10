import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class WaypointDialog extends StatelessWidget {
  final String title;
  final Waypoint waypoint;

  const WaypointDialog({Key? key,required this.title, required this.waypoint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text('Arrived Waypoint Location'),
          subtitle: Text(waypoint.arrivedWaypointLocation?.toString() ?? 'N/A'),
        ),
        ListTile(
          title: const Text('Arrived Waypoint Index'),
          subtitle: Text(waypoint.arrivedWaypointIndex?.toString() ?? 'N/A'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Dismiss'),
          ),
        ),
      ],
    );
  }
}