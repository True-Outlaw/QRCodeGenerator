import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/qr_provider.dart';

class CustomizationPanel extends StatelessWidget {
  const CustomizationPanel({super.key});

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
            const Text('2. Customize Design & Branding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Colors
            Row(
              children: [
                Expanded(
                  child: _buildColorPickerButton(
                    context,
                    'QR Color',
                    config.foregroundColor,
                    (color) => provider.updateField((c) => c.foregroundColor = color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildColorPickerButton(
                    context,
                    'Background',
                    config.backgroundColor,
                    (color) => provider.updateField((c) => c.backgroundColor = color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dot Style
            const Text('Dot Style', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [config.dotStyle == 'square', config.dotStyle == 'rounded', config.dotStyle == 'circular'],
              onPressed: (index) {
                final style = index == 0 ? 'square' : (index == 1 ? 'rounded' : 'circular');
                provider.updateField((c) => c.dotStyle = style);
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Square')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Rounded')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Circular')),
              ],
            ),
            const SizedBox(height: 16),

            // Frame & CTA Banner Advanced Options
            const Text('Frame / Banner CTA', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: config.frameText ?? '',
              decoration: const InputDecoration(
                labelText: 'Banner Text (e.g. SCAN ME)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => provider.updateField((c) => c.frameText = val.isEmpty ? null : val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildColorPickerButton(
                    context,
                    'Banner BG',
                    config.frameColor,
                    (color) => provider.updateField((c) => c.frameColor = color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildColorPickerButton(
                    context,
                    'Text Color',
                    config.frameTextColor,
                    (color) => provider.updateField((c) => c.frameTextColor = color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Style: '),
                ChoiceChip(
                  label: const Text('Wrap'),
                  selected: config.framePosition == 'wrap',
                  onSelected: (selected) {
                    if (selected) provider.updateField((c) => c.framePosition = 'wrap');
                  },
                ),
                ChoiceChip(
                  label: const Text('Top'),
                  selected: config.framePosition == 'top',
                  onSelected: (selected) {
                    if (selected) provider.updateField((c) => c.framePosition = 'top');
                  },
                ),
                ChoiceChip(
                  label: const Text('Bottom'),
                  selected: config.framePosition == 'bottom',
                  onSelected: (selected) {
                    if (selected) provider.updateField((c) => c.framePosition = 'bottom');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Icon: '),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: config.frameIcon,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('None')),
                      DropdownMenuItem(value: 'scan', child: Text('Scan')),
                      DropdownMenuItem(value: 'wifi', child: Text('Wi-Fi')),
                      DropdownMenuItem(value: 'link', child: Text('Link')),
                      DropdownMenuItem(value: 'phone', child: Text('Phone')),
                    ],
                    onChanged: (val) => provider.updateField((c) => c.frameIcon = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Radius: '),
                Expanded(
                  child: Slider(
                    value: config.frameRadius,
                    min: 0.0,
                    max: 32.0,
                    divisions: 8,
                    label: '${config.frameRadius.round()} px',
                    onChanged: (val) => provider.updateField((c) => c.frameRadius = val),
                  ),
                ),
                Text('${config.frameRadius.round()} px'),
              ],
            ),
            const SizedBox(height: 16),

            // Logo Upload
            const Text('Center Logo / Icon', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      final bytes = result.files.single.bytes!;
                      provider.updateField((c) {
                        c.logoBytes = bytes;
                        if (c.errorCorrectionLevel < 3) {
                          c.errorCorrectionLevel = 3;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Logo'),
                ),
                if (config.logoBytes != null) ...[
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => provider.updateField((c) => c.logoBytes = null),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Remove Logo', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),
            if (config.logoBytes != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Logo Size: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Slider(
                      value: config.logoSize,
                      min: 25.0,
                      max: 85.0,
                      divisions: 12,
                      label: '${config.logoSize.round()} px',
                      onChanged: (val) => provider.updateField((c) => c.logoSize = val),
                    ),
                  ),
                  Text('${config.logoSize.round()} px', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Error Correction Level
            const Text('Error Correction Level', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: config.errorCorrectionLevel,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Low (L - 7%)')),
                DropdownMenuItem(value: 1, child: Text('Medium (M - 15%)')),
                DropdownMenuItem(value: 2, child: Text('Quartile (Q - 25%)')),
                DropdownMenuItem(value: 3, child: Text('High (H - 30%) - Recommended with Logo')),
              ],
              onChanged: (val) {
                if (val != null) provider.updateField((c) => c.errorCorrectionLevel = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerButton(
    BuildContext context,
    String label,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    return InkWell(
      onTap: () async {
        Color color = currentColor;
        final bool ok = await ColorPicker(
          color: color,
          onColorChanged: (Color c) => color = c,
          heading: Text('Select $label'),
          subheading: Text('Select color shade'),
          pickersEnabled: const {ColorPickerType.wheel: true},
        ).showPickerDialog(context);
        if (ok) {
          onColorChanged(color);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
