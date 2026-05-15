import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> callMedicalProvider(
  BuildContext context,
  String? medicalProviderPhone,
) async {
  final rawPhone = medicalProviderPhone?.trim() ?? '';
  if (rawPhone.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No medical provider phone number set.')),
    );
    return;
  }

  final telUri = 'tel:${rawPhone.replaceAll(RegExp(r'[^0-9+]'), '')}';
  try {
    final launched = await launchUrlString(telUri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start call.')),
      );
    }
  } on PlatformException {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling is unavailable in this build.')),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to start call.')),
    );
  }
}
