import 'package:get/get.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:flutter_starter/ui/auth/auth.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => HomeUI()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/reset-password', page: () => ResetPasswordUI()),
    GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
    GetPage(name: '/play-a-song', page: () => SongUI()),
    GetPage(name: '/choose-a-playlist', page: () => PlaylistUI()),
    GetPage(name: '/game-recap', page: () => GameRecapUI()),
    GetPage(name: '/add-song', page: () => AddSongUI()),
    GetPage(name: '/dance-mode', page: () => DanceUI()),
    GetPage(name: 'image-sources', page: () => ImageSourcesUI())
  ];
}
