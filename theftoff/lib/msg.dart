import 'package:sms/sms.dart';
import 'package:theftoff/splash.dart';

void sms() {
  SmsSender sender = new SmsSender();
  String address = "+919846098687";

  sender.sendSms(new SmsMessage(address, userID));
}
