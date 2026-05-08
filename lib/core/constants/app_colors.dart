import 'package:flutter/material.dart';

/// Hatsune Miku Color Palette
/// Diambil langsung dari Figma design token
class AppColors {
  AppColors._();

  // ── Primary Palette ───────────────────────────────────────
  /// #03045E — Background utama (navy gelap)
  static const Color navy = Color(0xFF03045E);

  /// #00B4D8 — Warna aksi utama (teal Miku)
  static const Color teal = Color(0xFF00B4D8);

  /// #0077B6 — Sekunder / deep cyan
  static const Color deepCyan = Color(0xFF0077B6);

  /// #90E0EF — Teks muted / border / subtitle
  static const Color sky = Color(0xFF90E0EF);

  /// #CAF0F8 — Surface terang
  static const Color ice = Color(0xFFCAF0F8);

  /// #F8F9FA — Teks putih / teks on dark
  static const Color white = Color(0xFFF8F9FA);

  // ── Surface / Card ───────────────────────────────────────
  /// #080E42 — Card background (sedikit lebih terang dari navy)
  static const Color navyCard = Color(0xFF080E42);

  /// #050535 — Surface sedang
  static const Color navySurf = Color(0xFF050535);

  // ── Semantic ─────────────────────────────────────────────
  /// #E63946 — Like / error / badge merah
  static const Color red = Color(0xFFE63946);

  /// #22C55E — Success / live dot hijau
  static const Color green = Color(0xFF22C55E);

  // ── Opacity helpers ──────────────────────────────────────
  static Color skyWithOpacity(double opacity) => sky.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => white.withOpacity(opacity);
  static Color tealWithOpacity(double opacity) => teal.withOpacity(opacity);
}