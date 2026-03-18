import 'package:flutter/material.dart';

/// Minimal fallback for the google_fonts dependency so builds can finish inside the repo.
class GoogleFonts {
  static TextTheme plusJakartaSansTextTheme(TextTheme base) {
    return base.apply(fontFamily: 'Plus Jakarta Sans');
  }
}
