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
            theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800), useMaterial3: true),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade400, brightness: Brightness.dark),
              useMaterial3: true,
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
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.qr_code_2, size: 28), SizedBox(width: 12), Text('Enterprise QR Code Generator')],
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              provider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : (provider.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.brightness_auto),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      ),
    );
  }

  Widget _buildWideLayout() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(children: [ContentFormWidget(), SizedBox(height: 20), CustomizationPanel()]),
            ),
          ),
          SizedBox(width: 24),
          Expanded(flex: 2, child: SingleChildScrollView(child: QrPreviewWidget())),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          ContentFormWidget(),
          SizedBox(height: 16),
          CustomizationPanel(),
          SizedBox(height: 16),
          QrPreviewWidget(),
        ],
      ),
    );
  }
}
