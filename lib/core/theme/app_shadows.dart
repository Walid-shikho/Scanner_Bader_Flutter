import 'package:flutter/material.dart';

abstract final class AppShadows {
  // Ultra-soft micro shadow for elevated chips & small controls
  static const subtle = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // Natural multi-layer card shadow
  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 18,
      offset: Offset(0, 5),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  // Floating controls & CTA shadow
  static const floating = <BoxShadow>[
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Bader primary tinted glow for primary buttons
  static const primaryGlow = <BoxShadow>[
    BoxShadow(
      color: Color(0x380093AD),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  // Floating Bottom Navigation shadow
  static const nav = <BoxShadow>[
    BoxShadow(
      color: Color(0x2E000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // Legacy soft alias
  static const soft = card;
}
