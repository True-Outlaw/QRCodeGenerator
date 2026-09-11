import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/qr_provider.dart';
import 'widgets/content_form_widget.dart';
import 'widgets/customization_panel.dart';
import 'widgets/qr_preview_widget.dart';

void main() {
  runApp(const EnterpriseQRCodeApp());
}

class EnterpriseQRCodeApp extends StatelessWidget {
  const EnterpriseQRCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QRProvider(),
      child: Consumer<QRProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Enterprise QR Code Generator',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5E9), brightness: Brightness.light),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFF0A0F1D),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0EA5E9),
                brightness: Brightness.dark,
                surface: const Color(0xFF131B2E),
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                color: const Color(0xFF131B2E),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            themeMode: provider.themeMode,
            home: const QrGeneratorHomePage(),
          );
        },
      ),
    );
  }
}

class QrGeneratorHomePage extends StatelessWidget {
  const QrGeneratorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QRProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1D) : Colors.grey.shade100,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_2, size: 28, color: Color(0xFF0EA5E9)),
            ),
            const SizedBox(width: 12),
            const Text('Enterprise QR Code Generator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF131B2E) : Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              provider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : (provider.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.brightness_auto),
              color: const Color(0xFF0EA5E9),
            ),
            tooltip: 'Theme: ${provider.themeMode.name}',
            onPressed: () {
              if (provider.themeMode == ThemeMode.system) {
                provider.setThemeMode(ThemeMode.light);
              } else if (provider.themeMode == ThemeMode.light) {
                provider.setThemeMode(ThemeMode.dark);
              } else {
                provider.setThemeMode(ThemeMode.system);
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isWide ? _buildWideLayout() : SingleChildScrollView(child: _buildNarrowLayout()),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: const [ContentFormWidget(), SizedBox(height: 24), CustomizationPanel(), SizedBox(height: 24)],
            ),
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          flex: 2,
          child: SingleChildScrollView(child: QrPreviewWidget()), // Fixed/sticky right preview panel
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return const Column(
      children: [
        ContentFormWidget(),
        SizedBox(height: 20),
        CustomizationPanel(),
        SizedBox(height: 20),
        QrPreviewWidget(),
      ],
    );
  }
}
