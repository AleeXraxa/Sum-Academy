import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/auth/widgets/auth_backdrop.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Theme(
      data: SumAcademyTheme.light(),
      child: Scaffold(
        backgroundColor: SumAcademyTheme.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const AuthBackdrop(),
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h + bottomInset),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
