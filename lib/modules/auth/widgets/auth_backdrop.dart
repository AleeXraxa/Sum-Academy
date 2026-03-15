import 'package:flutter/material.dart';
import 'package:sum_academy/app/theme.dart';

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: SumAcademyTheme.white),
        child: const SizedBox.expand(),
      ),
    );
  }
}

