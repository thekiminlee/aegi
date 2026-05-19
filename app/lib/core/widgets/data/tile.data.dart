import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:flutter/material.dart';

class TileData {
  const TileData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.tab,
    this.onTap,
    this.includeTime = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final DateTime? timestamp;
  final EntryTab tab;
  final Function? onTap;
  final bool includeTime;
}