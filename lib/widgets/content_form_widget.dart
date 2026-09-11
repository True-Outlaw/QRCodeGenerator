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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Select Content Type & Enter Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: QRType.values.map((type) {
                  final isSelected = config.type == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_getTypeName(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.updateField((c) => c.type = type);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildFormFields(provider, config),
          ],
        ),
      ),
    );
  }

  String _getTypeName(QRType type) {
    switch (type) {
      case QRType.url:
        return 'URL';
      case QRType.text:
        return 'Text';
      case QRType.wifi:
        return 'Wi-Fi';
      case QRType.vcard:
        return 'vCard';
      case QRType.email:
        return 'Email';
      case QRType.phone:
        return 'Phone';
      case QRType.location:
        return 'Location';
    }
  }

  Widget _buildFormFields(QRProvider provider, QRCodeConfig config) {
    switch (config.type) {
      case QRType.url:
        return TextFormField(
          initialValue: config.url,
          decoration: const InputDecoration(
            labelText: 'Website URL',
            hintText: 'https://www.company.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          onChanged: (val) => provider.updateField((c) => c.url = val),
        );
      case QRType.text:
        return TextFormField(
          initialValue: config.text,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Plain Text / Message',
            hintText: 'Enter company announcement or notes...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.text_fields),
          ),
          onChanged: (val) => provider.updateField((c) => c.text = val),
        );
      case QRType.wifi:
        return Column(
          children: [
            TextFormField(
              initialValue: config.wifiSsid,
              decoration: const InputDecoration(
                labelText: 'Network SSID (Name)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              onChanged: (val) => provider.updateField((c) => c.wifiSsid = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.wifiPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              onChanged: (val) => provider.updateField((c) => c.wifiPassword = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: config.wifiEncryption,
              decoration: const InputDecoration(labelText: 'Encryption', border: OutlineInputBorder()),
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
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardName = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.vcardPhone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardPhone = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.vcardEmail,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              onChanged: (val) => provider.updateField((c) => c.vcardEmail = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.vcardOrg,
              decoration: const InputDecoration(
                labelText: 'Company / Organization',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
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
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.mail),
              ),
              onChanged: (val) => provider.updateField((c) => c.emailTo = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.emailSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              onChanged: (val) => provider.updateField((c) => c.emailSubject = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: config.emailBody,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              onChanged: (val) => provider.updateField((c) => c.emailBody = val),
            ),
          ],
        );
      case QRType.phone:
        return TextFormField(
          initialValue: config.phoneNum,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          onChanged: (val) => provider.updateField((c) => c.phoneNum = val),
        );
      case QRType.location:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: config.geoLat,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: '37.7749',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => provider.updateField((c) => c.geoLat = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: config.geoLng,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-122.4194',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => provider.updateField((c) => c.geoLng = val),
              ),
            ),
          ],
        );
    }
  }
}
