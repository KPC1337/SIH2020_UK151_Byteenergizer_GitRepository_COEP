import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

void sms() {
  SmsSender sender = new SmsSender();
  String address = "+919846195666";
  
  sender.sendSms(new SmsMessage(address, 'Hello flutter!'));
  
}
