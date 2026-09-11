import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum QRType { url, text, wifi, vcard, email, phone, location }

class QRCodeConfig {
  QRType type;

  // Content fields
  String url;
  String text;

  // Wi-Fi
  String wifiSsid;
  String wifiPassword;
  String wifiEncryption; // WPA, WEP, nopass

  // vCard
  String vcardName;
  String vcardPhone;
  String vcardEmail;
  String vcardOrg;

  // Email
  String emailTo;
  String emailSubject;
  String emailBody;

  // Phone
  String phoneNum;

  // Location
  String geoLat;
  String geoLng;

  // Customization
  Color foregroundColor;
  Color backgroundColor;
  String dotStyle; // 'square', 'rounded', 'circular'
  String? frameText; // e.g. "SCAN ME"
  Color frameColor;
  Color frameTextColor;
  String framePosition; // 'top' or 'bottom'
  double frameRadius;
  String? frameIcon; // 'none', 'scan', 'wifi', 'link', 'phone'

  Uint8List? logoBytes;
  double logoSize;
  int errorCorrectionLevel; // 0: L, 1: M, 2: Q, 3: H

  QRCodeConfig({
    this.type = QRType.url,
    this.url = 'https://www.example.com',
    this.text = '',
    this.wifiSsid = '',
    this.wifiPassword = '',
    this.wifiEncryption = 'WPA',
    this.vcardName = '',
    this.vcardPhone = '',
    this.vcardEmail = '',
    this.vcardOrg = '',
    this.emailTo = '',
    this.emailSubject = '',
    this.emailBody = '',
    this.phoneNum = '',
    this.geoLat = '',
    this.geoLng = '',
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.dotStyle = 'square',
    this.frameText,
    Color? frameColor,
    Color? frameTextColor,
    this.framePosition = 'top',
    this.frameRadius = 16.0,
    this.frameIcon,
    this.logoBytes,
    this.logoSize = 45.0,
    this.errorCorrectionLevel = 1, // M
  }) : frameColor = frameColor ?? Colors.blue,
       frameTextColor = frameTextColor ?? Colors.white;

  String get generatedData {
    switch (type) {
      case QRType.url:
        return url.startsWith('http') ? url : 'https://$url';
      case QRType.text:
        return text;
      case QRType.wifi:
        return 'WIFI:S:$wifiSsid;T:$wifiEncryption;P:$wifiPassword;;';
      case QRType.vcard:
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$vcardName\nTEL:$vcardPhone\nEMAIL:$vcardEmail\nORG:$vcardOrg\nEND:VCARD';
      case QRType.email:
        return 'mailto:$emailTo?subject=${Uri.encodeComponent(emailSubject)}&body=${Uri.encodeComponent(emailBody)}';
      case QRType.phone:
        return 'tel:$phoneNum';
      case QRType.location:
        return 'geo:$geoLat,$geoLng';
    }
  }

  QRCodeConfig copyWith({
    QRType? type,
    String? url,
    String? text,
    String? wifiSsid,
    String? wifiPassword,
    String? wifiEncryption,
    String? vcardName,
    String? vcardPhone,
    String? vcardEmail,
    String? vcardOrg,
    String? emailTo,
    String? emailSubject,
    String? emailBody,
    String? phoneNum,
    String? geoLat,
    String? geoLng,
    Color? foregroundColor,
    Color? backgroundColor,
    String? dotStyle,
    String? frameText,
    Color? frameColor,
    Color? frameTextColor,
    String? framePosition,
    double? frameRadius,
    String? frameIcon,
    Uint8List? logoBytes,
    double? logoSize,
    int? errorCorrectionLevel,
  }) {
    return QRCodeConfig(
      type: type ?? this.type,
      url: url ?? this.url,
      text: text ?? this.text,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      wifiEncryption: wifiEncryption ?? this.wifiEncryption,
      vcardName: vcardName ?? this.vcardName,
      vcardPhone: vcardPhone ?? this.vcardPhone,
      vcardEmail: vcardEmail ?? this.vcardEmail,
      vcardOrg: vcardOrg ?? this.vcardOrg,
      emailTo: emailTo ?? this.emailTo,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
      phoneNum: phoneNum ?? this.phoneNum,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dotStyle: dotStyle ?? this.dotStyle,
      frameText: frameText ?? this.frameText,
      frameColor: frameColor ?? this.frameColor,
      frameTextColor: frameTextColor ?? this.frameTextColor,
      framePosition: framePosition ?? this.framePosition,
      frameRadius: frameRadius ?? this.frameRadius,
      frameIcon: frameIcon ?? this.frameIcon,
      logoBytes: logoBytes ?? this.logoBytes,
      logoSize: logoSize ?? this.logoSize,
      errorCorrectionLevel: errorCorrectionLevel ?? this.errorCorrectionLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'url': url,
    'text': text,
    'wifiSsid': wifiSsid,
    'wifiPassword': wifiPassword,
    'wifiEncryption': wifiEncryption,
    'vcardName': vcardName,
    'vcardPhone': vcardPhone,
    'vcardEmail': vcardEmail,
    'vcardOrg': vcardOrg,
    'emailTo': emailTo,
    'emailSubject': emailSubject,
    'emailBody': emailBody,
    'phoneNum': phoneNum,
    'geoLat': geoLat,
    'geoLng': geoLng,
    'foregroundColor': foregroundColor.toARGB32(),
    'backgroundColor': backgroundColor.toARGB32(),
    'dotStyle': dotStyle,
    'frameText': frameText,
    'frameColor': frameColor.toARGB32(),
    'frameTextColor': frameTextColor.toARGB32(),
    'framePosition': framePosition,
    'frameRadius': frameRadius,
    'frameIcon': frameIcon,
    'logoSize': logoSize,
    'errorCorrectionLevel': errorCorrectionLevel,
  };

  factory QRCodeConfig.fromJson(Map<String, dynamic> json) => QRCodeConfig(
    type: QRType.values[json['type'] ?? 0],
    url: json['url'] ?? '',
    text: json['text'] ?? '',
    wifiSsid: json['wifiSsid'] ?? '',
    wifiPassword: json['wifiPassword'] ?? '',
    wifiEncryption: json['wifiEncryption'] ?? 'WPA',
    vcardName: json['vcardName'] ?? '',
    vcardPhone: json['vcardPhone'] ?? '',
    vcardEmail: json['vcardEmail'] ?? '',
    vcardOrg: json['vcardOrg'] ?? '',
    emailTo: json['emailTo'] ?? '',
    emailSubject: json['emailSubject'] ?? '',
    emailBody: json['emailBody'] ?? '',
    phoneNum: json['phoneNum'] ?? '',
    geoLat: json['geoLat'] ?? '',
    geoLng: json['geoLng'] ?? '',
    foregroundColor: Color(json['foregroundColor'] ?? Colors.black.toARGB32()),
    backgroundColor: Color(json['backgroundColor'] ?? Colors.white.toARGB32()),
    dotStyle: json['dotStyle'] ?? 'square',
    frameText: json['frameText'],
    frameColor: Color(json['frameColor'] ?? Colors.blue.toARGB32()),
    frameTextColor: Color(json['frameTextColor'] ?? Colors.white.toARGB32()),
    framePosition: json['framePosition'] ?? 'top',
    frameRadius: (json['frameRadius'] as num?)?.toDouble() ?? 16.0,
    frameIcon: json['frameIcon'],
    logoSize: (json['logoSize'] as num?)?.toDouble() ?? 45.0,
    errorCorrectionLevel: json['errorCorrectionLevel'] ?? 1,
  );
}

class CompanyTemplate {
  String id;
  String name;
  QRCodeConfig config;

  CompanyTemplate({required this.id, required this.name, required this.config});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'config': config.toJson()};

  factory CompanyTemplate.fromJson(Map<String, dynamic> json) => CompanyTemplate(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Template',
    config: QRCodeConfig.fromJson(json['config'] ?? {}),
  );
}
