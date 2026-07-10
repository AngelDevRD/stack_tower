import 'package:flutter/material.dart';

/// A selectable block color palette. Cycles through [colors] by tower height.
class BlockPalette {
  final String name;
  final List<Color> colors;
  const BlockPalette(this.name, this.colors);

  Color colorForHeight(int height) => colors[height % colors.length];
}

/// Exactly 4 persisted palettes, unlocked by score milestones in [kThemeUnlockScores].
const List<BlockPalette> kBlockPalettes = [
  BlockPalette('Clasico', [
    Color(0xFF4C6EF5),
    Color(0xFF3B5BDB),
    Color(0xFF364FC7),
  ]),
  BlockPalette('Atardecer', [
    Color(0xFFFF922B),
    Color(0xFFF76707),
    Color(0xFFE8590C),
  ]),
  BlockPalette('Neon', [
    Color(0xFF12B886),
    Color(0xFF0CA678),
    Color(0xFF099268),
  ]),
  BlockPalette('Candy', [
    Color(0xFFE64980),
    Color(0xFFD6336C),
    Color(0xFFAE3EC9),
  ]),
];
