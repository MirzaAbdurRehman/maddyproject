
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {

  static Future<void> openWhatsappForMessage(String phoneNumber, String message) async {

    final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    if(await canLaunchUrl(url)){
      await launchUrl(url);
    }else{
      throw 'Can Not Launch $url';
    }
  }
}