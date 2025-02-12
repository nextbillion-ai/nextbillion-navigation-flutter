part of '../nb_navigation_flutter.dart';

class NBNavigationMethodChannelsFactory {
  static const MethodChannel _nbNavigationChannel =
      MethodChannel(NBNavMethodChannelsConstants.nbNavigationChannelName);

  static MethodChannel get nbNavigationChannel => _nbNavigationChannel;
}
