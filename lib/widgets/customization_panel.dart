import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/qr_config.dart';
import '../providers/qr_provider.dart';

class CustomizationPanel extends StatelessWidget {
  const CustomizationPanel({super.key});

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
                          '2',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'Design, Patterns & Brand Identity',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                 TextButton.icon(
                  onPressed: () {
                    provider.updateField((c) {
                      c.foregroundColor = Colors.black;
                      c.backgroundColor = Colors.white;
                      c.dotStyle = 'square';
                      c.useGradient = false;
                      c.gradientEndColor = const Color(0xFF0EA5E9);
                      c.gradientDirection = 'diagonal';
                      c.eyeShape = 'auto';
                      c.eyeColor = null;
                      c.eyeInnerColor = null;
                      c.frameText = null;
                      c.logoBytes = null;
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF0EA5E9)),
                  label: const Text('Reset to Defaults', style: TextStyle(fontSize: 12, color: Color(0xFF0EA5E9))),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 36.0, top: 2),
              child: Text(
                'Configure geometry, color palettes, gradients, finder eyes, logo, and banner frame',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Color Scheme & Gradient Mode Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'COLOR PALETTE & FILL STYLE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.grey),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Solid', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: true, label: Text('Gradient', style: TextStyle(fontSize: 12))),
                  ],
                  selected: {config.useGradient},
                  onSelectionChanged: (val) {
                    provider.updateField((c) => c.useGradient = val.first);
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    selectedBackgroundColor: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                    selectedForegroundColor: const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Color Swatches
            if (!config.useGradient) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pattern Color', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        _buildColorPickerButton(
                          context,
                          'Pattern Color',
                          config.foregroundColor,
                          (color) => provider.updateField((c) => c.foregroundColor = color),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Background Canvas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        _buildColorPickerButton(
                          context,
                          'Background',
                          config.backgroundColor,
                          (color) => provider.updateField((c) => c.backgroundColor = color),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Gradient options
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gradient Start', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        _buildColorPickerButton(
                          context,
                          'Start Color',
                          config.foregroundColor,
                          (color) => provider.updateField((c) => c.foregroundColor = color),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gradient End', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        _buildColorPickerButton(
                          context,
                          'End Color',
                          config.gradientEndColor,
                          (color) => provider.updateField((c) => c.gradientEndColor = color),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gradient Direction', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: config.gradientDirection,
                          dropdownColor: isDark ? const Color(0xFF131B2E) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'diagonal', child: Text('Diagonal (↘ Top-Left to Bottom-Right)')),
                            DropdownMenuItem(value: 'horizontal', child: Text('Horizontal (➡ Left to Right)')),
                            DropdownMenuItem(value: 'vertical', child: Text('Vertical (⬇ Top to Bottom)')),
                            DropdownMenuItem(value: 'radial', child: Text('Radial (🔘 Center outward)')),
                          ],
                          onChanged: (val) {
                            if (val != null) provider.updateField((c) => c.gradientDirection = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Background Canvas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        _buildColorPickerButton(
                          context,
                          'Background',
                          config.backgroundColor,
                          (color) => provider.updateField((c) => c.backgroundColor = color),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Dot Style Cards
            const Text(
              'MATRIX PATTERN (DOT STYLE)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStyleCard(
                    provider,
                    config,
                    'square',
                    'Classic Square',
                    'Geometric matrix',
                    Icons.grid_view,
                    isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStyleCard(
                    provider,
                    config,
                    'rounded',
                    'Smooth Round',
                    'Connected fluid',
                    Icons.rounded_corner,
                    isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStyleCard(
                    provider,
                    config,
                    'circular',
                    'Circular Dots',
                    'Tech & playful',
                    Icons.circle,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Corner Finder Pattern (Eyes) Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FINDER PATTERN (EYE SHAPES & ACCENTS)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.grey),
                ),
                if (config.eyeColor != null || config.eyeInnerColor != null)
                  TextButton(
                    onPressed: () {
                      provider.updateField((c) {
                        c.eyeColor = null;
                        c.eyeInnerColor = null;
                      });
                    },
                    child: const Text('Reset Eye Colors', style: TextStyle(fontSize: 11, color: Color(0xFF0EA5E9))),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildEyeShapeChip(provider, config, 'auto', 'Auto (Match)', Icons.auto_awesome, isDark),
                _buildEyeShapeChip(provider, config, 'rounded', 'Squircle', Icons.crop_portrait_rounded, isDark),
                _buildEyeShapeChip(provider, config, 'circular', 'Circular', Icons.radio_button_checked, isDark),
                _buildEyeShapeChip(provider, config, 'square', 'Square', Icons.crop_square, isDark),
                _buildEyeShapeChip(provider, config, 'leaf', 'Modern Leaf', Icons.eco, isDark),
              ],
            ),
            const SizedBox(height: 14),

            // Eye Accent Color Pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Outer Eye Frame', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      _buildColorPickerButton(
                        context,
                        'Eye Frame',
                        config.eyeColor ?? config.foregroundColor,
                        (color) => provider.updateField((c) => c.eyeColor = color),
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inner Eye Center Dot', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      _buildColorPickerButton(
                        context,
                        'Eye Center',
                        config.eyeInnerColor ?? config.eyeColor ?? config.foregroundColor,
                        (color) => provider.updateField((c) => c.eyeInnerColor = color),
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Frame & Banner CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Frame & Banner Call-to-Action (CTA)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: config.frameText != null,
                  activeThumbColor: const Color(0xFF0EA5E9),
                  onChanged: (val) {
                    provider.updateField((c) => c.frameText = val ? 'SCAN ME FOR EXCLUSIVE OFFERS' : null);
                  },
                ),
              ],
            ),
            const Text(
              'Boost scan conversion rates by up to 34% with clear instruction',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (config.frameText != null) ...[
              const SizedBox(height: 14),
              TextFormField(
                initialValue: config.frameText ?? '',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Banner Text Label',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  isDense: true,
                ),
                onChanged: (val) => provider.updateField((c) => c.frameText = val.isEmpty ? null : val),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Position: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Wrap'),
                    selected: config.framePosition == 'wrap',
                    onSelected: (selected) {
                      if (selected) provider.updateField((c) => c.framePosition = 'wrap');
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Top'),
                    selected: config.framePosition == 'top',
                    onSelected: (selected) {
                      if (selected) provider.updateField((c) => c.framePosition = 'top');
                    },
                  ),
                  const SizedBox(width: 6),
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
                  Expanded(
                    child: _buildColorPickerButton(
                      context,
                      'Banner Background',
                      config.frameColor,
                      (color) => provider.updateField((c) => c.frameColor = color),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildColorPickerButton(
                      context,
                      'Banner Font Color',
                      config.frameTextColor,
                      (color) => provider.updateField((c) => c.frameTextColor = color),
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Corner Radius: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Expanded(
                    child: Slider(
                      value: config.frameRadius,
                      min: 0.0,
                      max: 32.0,
                      divisions: 8,
                      activeColor: const Color(0xFF0EA5E9),
                      label: '${config.frameRadius.round()} px',
                      onChanged: (val) => provider.updateField((c) => c.frameRadius = val),
                    ),
                  ),
                  Text('${config.frameRadius.round()} px', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Center Brand Icon & ECC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Center Brand Icon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Safe Margin Active',
                    style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3), style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            withData: true,
                          );
                          if (result != null && result.files.single.bytes != null) {
                            provider.updateField((c) {
                              c.logoBytes = result.files.single.bytes!;
                              if (c.errorCorrectionLevel < 3) c.errorCorrectionLevel = 3;
                            });
                          }
                        },
                        icon: const Icon(Icons.upload, size: 16),
                        label: const Text('Upload Brand SVG / PNG'),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Max 2MB • Transparent PNG or Vector SVG recommended',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (config.logoBytes != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.updateField((c) => c.logoBytes = null),
                    ),
                ],
              ),
            ),
            if (config.logoBytes != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Logo Size: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Expanded(
                    child: Slider(
                      value: config.logoSize,
                      min: 25.0,
                      max: 85.0,
                      divisions: 12,
                      activeColor: const Color(0xFF0EA5E9),
                      label: '${config.logoSize.round()} px',
                      onChanged: (val) => provider.updateField((c) => c.logoSize = val),
                    ),
                  ),
                  Text('${config.logoSize.round()} px', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Error Correction (ECC)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Error Correction (ECC)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Text(
                  'High (Q - 25%)',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: config.errorCorrectionLevel,
              dropdownColor: isDark ? const Color(0xFF131B2E) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Level L - 7% Recovery')),
                DropdownMenuItem(value: 1, child: Text('Level M - 15% Recovery')),
                DropdownMenuItem(value: 2, child: Text('Level Q - 25% Recovery (Recommended with Logo)')),
                DropdownMenuItem(value: 3, child: Text('Level H - 30% Maximum Recovery')),
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

  Widget _buildStyleCard(
    QRProvider provider,
    QRCodeConfig config,
    String styleKey,
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = config.dotStyle == styleKey;
    return InkWell(
      onTap: () => provider.updateField((c) => c.dotStyle = styleKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0EA5E9).withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey, size: 20),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF0EA5E9) : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeShapeChip(
    QRProvider provider,
    QRCodeConfig config,
    String shapeKey,
    String title,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = config.eyeShape == shapeKey;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
      label: Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: const Color(0xFF0EA5E9),
      labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
      backgroundColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade100,
      side: BorderSide(
        color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey.withValues(alpha: 0.2),
      ),
      onSelected: (selected) {
        if (selected) provider.updateField((c) => c.eyeShape = shapeKey);
      },
    );
  }

  Widget _buildColorPickerButton(
    BuildContext context,
    String label,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
    bool isDark,
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
          color: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              '#${currentColor.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
