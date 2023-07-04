import 'package:flutter/material.dart';
import 'package:flutter_playgorund/screen/social_signing_screen.dart';

class Button extends StatelessWidget {
  final Social? social;
  final Color? backgroundColor;
  final String title;
  final VoidCallback onClick;

   Button({
    super.key,
    this.social,
    required this.title,
    required this.onClick,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GestureDetector(
        onTap: () => onClick(),
        child: SizedBox(
          width: double.infinity,
          height: 56.0,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16.0, top: 14.0),
                child: _socialIcon(social),
              ),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(Social? social) {
    if (social == Social.google) {
      return const Image(
        image: AssetImage(
          'assets/images/ic_google.png',
        ),
        width: 28.0,
        height: 28.0,
      );
    } else if (social == Social.facebook) {
      return const Image(
        image: AssetImage(
          'assets/images/ic_facebook.png',
        ),
        width: 28.0,
        height: 28.0,
      );
    } else {
      return Container();
    }
  }
}
