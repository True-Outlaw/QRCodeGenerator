import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/qr_config.dart';
import '../providers/qr_provider.dart';

class ContentFormWidget extends StatelessWidget {
  const ContentFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QRProvider>(context);
    final config = provider.config;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF131B2E) : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'Select Content Payload',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Color(0xFF0EA5E9)),
                      SizedBox(width: 6),
                      Text(
                        'High Compatibility',
                        style: TextStyle(fontSize: 12, color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 36.0, top: 2),
              child: Text(
                'Choose data protocol encoded into the matrix',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Icon cards for types
            SizedBox(
              height: 85,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: QRType.values.map((type) {
                  final isSelected = config.type == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: InkWell(
                      onTap: () => provider.updateField((c) => c.type = type),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 95,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0EA5E9)
                              : (isDark ? const Color(0xFF1A243D) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getTypeIcon(type),
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTypeName(type),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TARGET DESTINATION URL',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildFormFields(provider, config, isDark),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(QRType type) {
    switch (type) {
      case QRType.url:
        return Icons.link;
      case QRType.text:
        return Icons.text_fields;
      case QRType.wifi:
        return Icons.wifi;
      case QRType.vcard:
        return Icons.badge;
      case QRType.email:
        return Icons.email;
      case QRType.phone:
        return Icons.phone;
      case QRType.location:
        return Icons.location_on;
    }
  }

  String _getTypeName(QRType type) {
    switch (type) {
      case QRType.url:
        return 'URL Link';
      case QRType.text:
        return 'Plain Text';
      case QRType.wifi:
        return 'Wi-Fi Access';
      case QRType.vcard:
        return 'vCard 4.0';
      case QRType.email:
        return 'Email Mailto';
      case QRType.phone:
        return 'Phone / SMS';
      case QRType.location:
        return 'Geo Location';
    }
  }

  Widget _buildFormFields(QRProvider provider, QRCodeConfig config, bool isDark) {
    switch (config.type) {
      case QRType.url:
        return TextFormField(
          initialValue: config.url,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'https://www.example.com',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.lock, size: 18, color: Color(0xFF0EA5E9)),
            suffixIcon: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Test Link', style: TextStyle(fontSize: 12)),
            ),
          ),
          onChanged: (val) => provider.updateField((c) => c.url = val),
        );
      case QRType.text:
        return TextFormField(
          initialValue: config.text,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter plain text message...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onChanged: (val) => provider.updateField((c) => c.text = val),
        );
      case QRType.wifi:
        return Column(
          children: [
            TextFormField(
              initialValue: config.wifiSsid,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Network SSID (Name)',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.wifiSsid = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.wifiPassword,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.wifiPassword = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: config.wifiEncryption,
              dropdownColor: isDark ? const Color(0xFF131B2E) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Encryption',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              items: ['WPA', 'WEP', 'nopass'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) provider.updateField((c) => c.wifiEncryption = val);
              },
            ),
          ],
        );
      case QRType.vcard:
        return Column(
          children: [
            TextFormField(
              initialValue: config.vcardName,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardName = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.vcardPhone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardPhone = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.vcardEmail,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Email Address',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardEmail = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.vcardOrg,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Company / Organization',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardOrg = val),
            ),
          ],
        );
      case QRType.email:
        return Column(
          children: [
            TextFormField(
              initialValue: config.emailTo,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Recipient Email',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.emailTo = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.emailSubject,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Subject',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.emailSubject = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.emailBody,
              maxLines: 2,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Message Body',
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => provider.updateField((c) => c.emailBody = val),
            ),
          ],
        );
      case QRType.phone:
        return TextFormField(
          initialValue: config.phoneNum,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
            filled: true,
            fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onChanged: (val) => provider.updateField((c) => c.phoneNum = val),
        );
      case QRType.location:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: config.geoLat,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  hintText: '37.7749',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) => provider.updateField((c) => c.geoLat = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: config.geoLng,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-122.4194',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) => provider.updateField((c) => c.geoLng = val),
              ),
            ),
          ],
        );
    }
  }
}
