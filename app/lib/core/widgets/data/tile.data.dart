import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:flutter/material.dart';

class TileData {
  const TileData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trailing,
    required this.subtitle,
    required this.tab,
    this.onTap,
    this.includeTime = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final EntryTab tab;
  final bool includeTime;
  final String? trailing;
  final String? subtitle;
  final Function? onTap;
}