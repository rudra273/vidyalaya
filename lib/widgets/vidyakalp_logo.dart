import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VidyakalpLogo extends StatelessWidget {
  const VidyakalpLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      image: true,
      label: 'Vidyakalp',
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/vmark.png', width: size, height: size),
            SizedBox(width: size * 0.3),
            SvgPicture.asset(
              'assets/icon/wordmark.svg',
              width: size * (187 / 64),
              height: size * (42 / 64),
              colorFilter: theme.brightness == Brightness.dark
                  ? ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
