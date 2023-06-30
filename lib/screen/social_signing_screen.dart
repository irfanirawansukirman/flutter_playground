import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playgorund/core/social_auth.dart';
import 'package:flutter_playgorund/widget/button.dart';

class SocialSigningScreen extends StatefulWidget {
  const SocialSigningScreen({super.key});

  @override
  State<SocialSigningScreen> createState() => _SocialSigningScreenState();
}

class _SocialSigningScreenState extends State<SocialSigningScreen> {
  UserCredential? _userCredential;
  bool _isGoogle = false;

  @override
  Widget build(BuildContext context) {
    _getProfilePicture(_userCredential, _isGoogle);
    log("SOCIAL_USER_DATA $_userCredential");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Social Signing",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(
                _userCredential == null ? 0.0 : 8.0,
              ),
              child: Visibility(
                visible: _userCredential == null ? false : true,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(56.0),
                            child: Image.network(
                              _getProfilePicture(_userCredential, _isGoogle),
                              width: 64.0,
                              height: 64.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            "Hallo, ${_userCredential?.user?.displayName ?? "-"}",
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Button(
                        title: "Logout",
                        backgroundColor: Colors.white,
                        onClick: () {
                          _isGoogle == true
                              ? SocialAuth.signOutFromGoogle(
                                  onNext: () => setState(
                                    () => _userCredential = null,
                                  ),
                                )
                              : SocialAuth.signOutFromFacebook(
                                  onNext: () => setState(
                                    () => _userCredential = null,
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Button(
              social: Social.google,
              title: "Login with Google",
              onClick: () => SocialAuth.signInWithGoogle(
                context: context,
                onSuccess: (userCredential) {
                  setState(() {
                    _userCredential = userCredential;
                    _isGoogle = true;
                  });
                },
              ),
            ),
            Button(
              social: Social.facebook,
              title: "Login with Facebook",
              onClick: () => SocialAuth.signInWithFacebook(
                context: context,
                onSuccess: (userCredential) {
                  setState(() {
                    _userCredential = userCredential;
                    _isGoogle = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProfilePicture(UserCredential? userCredential, bool isGoogle) {
    try {
      if (isGoogle) {
        return userCredential?.additionalUserInfo?.profile?["picture"] ?? "";
      } else {
        final pictureString =
            userCredential?.additionalUserInfo?.profile?["picture"] ?? "";
        final picture = pictureString
            .toString()
            .replaceAll('{', '{"')
            .replaceAll(': ', '": "')
            .replaceAll(', ', '", "')
            .replaceAll('}', '"}')
            .replaceAll('"data": "', '"data": ')
            .replaceAll('"}"', '"}');
        final facebookData = FacebookData.fromJson(jsonDecode(picture));
        return facebookData.data.url;
      }
    } catch (e) {
      return "";
    }
  }
}

class FacebookData {
  FacebookData({
    required this.data,
  });
  late final Data data;

  FacebookData.fromJson(Map<String, dynamic> json){
    data = Data.fromJson(json['data']);
  }
}

class Data {
  Data({
    required this.height,
    required this.url,
    required this.width,
    required this.isSilhouette,
  });
  late final String height;
  late final String url;
  late final String width;
  late final String isSilhouette;

  Data.fromJson(Map<String, dynamic> json){
    height = json['height'];
    url = json['url'];
    width = json['width'];
    isSilhouette = json['is_silhouette'];
  }
}

enum Social { google, facebook }
