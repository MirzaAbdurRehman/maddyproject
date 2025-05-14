
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsEvents{
  
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logScreenView({required String screenName, required String ScreenIndex})
   async{
    await _analytics.logEvent(
      name: 'Page_Tracking',
      parameters: {
          'page_name': screenName,
        'page_index': ScreenIndex,
      }
      );
  }
}