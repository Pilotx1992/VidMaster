import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VidMasterBuildChannel {
  stable,
  experimental,
}

class BuildChannelConfig {
  final VidMasterBuildChannel channel;

  const BuildChannelConfig._(this.channel);

  static const _rawChannel = String.fromEnvironment(
    'VIDMASTER_CHANNEL',
    defaultValue: 'stable',
  );

  factory BuildChannelConfig.fromEnvironment() {
    return const BuildChannelConfig._(
      _rawChannel == 'experimental'
          ? VidMasterBuildChannel.experimental
          : VidMasterBuildChannel.stable,
    );
  }

  bool get isStable => channel == VidMasterBuildChannel.stable;
  bool get isExperimental => channel == VidMasterBuildChannel.experimental;

  String get label => channel.name;
}

final buildChannelConfigProvider = Provider<BuildChannelConfig>(
  (ref) => BuildChannelConfig.fromEnvironment(),
);
