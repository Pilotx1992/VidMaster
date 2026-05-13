import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NativeVideoCastIconStyle {
  light,
  dark,
}

class NativeVideoCastButton extends StatelessWidget {
  final double size;
  final NativeVideoCastIconStyle iconStyle;

  const NativeVideoCastButton({
    super.key,
    this.size = 40,
    this.iconStyle = NativeVideoCastIconStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    if (kDebugMode) {
      debugPrint('[NativeCast] button rendered');
    }

    return SizedBox(
      width: size,
      height: size,
      child: AndroidView(
        viewType: 'vidmaster/native_cast_button',
        creationParams: <String, Object?>{
          'iconStyle': iconStyle.name,
        },
        creationParamsCodec: StandardMessageCodec(),
        layoutDirection: TextDirection.ltr,
      ),
    );
  }
}
