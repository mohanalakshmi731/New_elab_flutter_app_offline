import 'package:flutter/material.dart';

/// Design tokens from `src/style.css` (`:root` and `.dark`).
///
/// Light values are the `:root` variables, `dark*` the `.dark` overrides.
/// Note the web quirks kept here: `--muted-foreground` is the same as the
/// foreground in light mode, and `.dark` never redefines `--background`.
class AppColors {
  AppColors._();

  // ── Light (:root) ──
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF1F2430);
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF1F2430);
  static const popover = Color(0xFFFFFFFF);
  static const popoverForeground = Color(0xFF1F2430);

  /// `--primary: #4f46e5` (`bg-primary`, table headers, default buttons).
  static const primary = Color(0xFF4F46E5);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF4271B5);
  static const secondaryForeground = Color(0xFFFFFFFF);
  static const muted = Color(0xFFE1E3E9);

  /// `--muted-foreground` (light) — identical to the foreground on the web.
  static const mutedForeground = Color(0xFF1F2430);

  /// `--accent: #f49148` — the hover/highlight colour of shadcn menus,
  /// outline/ghost buttons and pagination (both modes).
  static const accent = Color(0xFFF49148);
  static const accentForeground = Color(0xFF1F2430);
  static const destructive = Color(0xFFE03131);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const border = Color(0xFFE1E3E9);
  static const input = Color(0xFFE1E3E9);
  static const ring = Color(0xFF4F46E5);
  static const chart1 = Color(0xFF7180E4);
  static const chart2 = Color(0xFF4271B5);
  static const chart3 = Color(0xFF29AD6D);
  static const chart4 = Color(0xFFF49148);
  static const chart5 = Color(0xFF9DB1D4);

  // ── Dark (.dark) ──
  static const darkForeground = Color(0xFFE1E3E9);
  static const darkCard = Color(0xFF2A2F3C);
  static const darkPopover = Color(0xFF2A2F3C);
  static const darkPrimary = Color(0xFF9DB1D4);
  static const darkPrimaryForeground = Color(0xFF1F2430);
  static const darkMuted = Color(0xFF303540);
  static const darkMutedForeground = Color(0xFF9DB1D4);
  static const darkDestructive = Color(0xFFE85959);
  static const darkDestructiveForeground = Color(0xFF1F2430);
  static const darkBorder = Color(0xFF303540);
  static const darkInput = Color(0xFF303540);
  static const darkRing = Color(0xFF9DB1D4);
  static const darkChart5 = Color(0xFFFFFFFF);
  static const navbarBg = Color(0xFF0A0F1F);
  static const navbarShadow = Color(0xFF1F2A44);
  static const pageFrom = Color(0xFF0F172A);
  static const pageVia = Color(0xFF111827);
  static const pageTo = Color(0xFF1E293B);
  static const sidebarBg = Color(0xFF161E36);
  static const sidebarText = Color(0xFF95A3FF);
  static const cardBorderDark = Color(0xFF2E3B5E);

  /// `--main-bg` / `--activity-title` (dark).
  static const mainBgDark = Color(0xFFB85A1E);

  /// Dashboard dark background used by layouts (`bg-[#0d0d2b]`).
  static const dashboardDark = Color(0xFF0D0D2B);

  /// Dashboard light background (`bg-[#f8fafc]`).
  static const dashboardLight = Color(0xFFF8FAFC);

  /// Card dark background (`dark:bg-[#161e36]`).
  static const cardDark = Color(0xFF161E36);

  /// `text-orange-500` (Tailwind v4).
  static const brandOrange = Color(0xFFFF6900);

  /// Global `input::placeholder` / `[data-placeholder]` colour (#9ca3af,
  /// unlayered in style.css, so it beats `placeholder:text-muted-foreground`).
  static const placeholder = Color(0xFF9CA3AF);

  /// `::-webkit-scrollbar-thumb` (#d1d5db) and its hover (#9ca3af).
  static const scrollbarThumb = Color(0xFFD1D5DB);
  static const scrollbarThumbHover = Color(0xFF9CA3AF);
}

/// The Tailwind CSS v4 palette (the web uses tailwindcss 4.1), so ported
/// screens can map `text-slate-400` → `Tw.slate400` 1:1.
///
/// v4 defines colours in `oklch()`; these are the sRGB values browsers render
/// them as (out-of-gamut channels clipped). They differ from the v3 hex
/// values (e.g. `indigo-600` is #4f39f6, not #4f46e5) — arbitrary web colours
/// such as `bg-[#4f46e5]` or `var(--primary)` stay exact hex instead.
class Tw {
  Tw._();
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFFE2E2);
  static const red200 = Color(0xFFFFC9C9);
  static const red300 = Color(0xFFFFA2A2);
  static const red400 = Color(0xFFFF6467);
  static const red500 = Color(0xFFFB2C36);
  static const red600 = Color(0xFFE7000B);
  static const red700 = Color(0xFFC10007);
  static const red800 = Color(0xFF9F0712);
  static const red900 = Color(0xFF82181A);
  static const red950 = Color(0xFF460809);

  static const orange50 = Color(0xFFFFF7ED);
  static const orange100 = Color(0xFFFFEDD4);
  static const orange200 = Color(0xFFFFD6A7);
  static const orange300 = Color(0xFFFFB86A);
  static const orange400 = Color(0xFFFF8904);
  static const orange500 = Color(0xFFFF6900);
  static const orange600 = Color(0xFFF54900);
  static const orange700 = Color(0xFFCA3500);
  static const orange800 = Color(0xFF9F2D00);
  static const orange900 = Color(0xFF7E2A0C);
  static const orange950 = Color(0xFF441306);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C6);
  static const amber200 = Color(0xFFFEE685);
  static const amber300 = Color(0xFFFFD230);
  static const amber400 = Color(0xFFFFB900);
  static const amber500 = Color(0xFFFE9A00);
  static const amber600 = Color(0xFFE17100);
  static const amber700 = Color(0xFFBB4D00);
  static const amber800 = Color(0xFF973C00);
  static const amber900 = Color(0xFF7B3306);
  static const amber950 = Color(0xFF461901);

  static const yellow50 = Color(0xFFFEFCE8);
  static const yellow100 = Color(0xFFFEF9C2);
  static const yellow200 = Color(0xFFFFF085);
  static const yellow300 = Color(0xFFFFDF20);
  static const yellow400 = Color(0xFFFDC700);
  static const yellow500 = Color(0xFFF0B100);
  static const yellow600 = Color(0xFFD08700);
  static const yellow700 = Color(0xFFA65F00);
  static const yellow800 = Color(0xFF894B00);
  static const yellow900 = Color(0xFF733E0A);
  static const yellow950 = Color(0xFF432004);

  static const lime50 = Color(0xFFF7FEE7);
  static const lime100 = Color(0xFFECFCCA);
  static const lime200 = Color(0xFFD8F999);
  static const lime300 = Color(0xFFBBF451);
  static const lime400 = Color(0xFF9AE600);
  static const lime500 = Color(0xFF7CCF00);
  static const lime600 = Color(0xFF5EA500);
  static const lime700 = Color(0xFF497D00);
  static const lime800 = Color(0xFF3C6300);
  static const lime900 = Color(0xFF35530E);
  static const lime950 = Color(0xFF192E03);

  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green200 = Color(0xFFB9F8CF);
  static const green300 = Color(0xFF7BF1A8);
  static const green400 = Color(0xFF05DF72);
  static const green500 = Color(0xFF00C950);
  static const green600 = Color(0xFF00A63E);
  static const green700 = Color(0xFF008236);
  static const green800 = Color(0xFF016630);
  static const green900 = Color(0xFF0D542B);
  static const green950 = Color(0xFF032E15);

  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD0FAE5);
  static const emerald200 = Color(0xFFA4F4CF);
  static const emerald300 = Color(0xFF5EE9B5);
  static const emerald400 = Color(0xFF00D492);
  static const emerald500 = Color(0xFF00BC7D);
  static const emerald600 = Color(0xFF009966);
  static const emerald700 = Color(0xFF007A55);
  static const emerald800 = Color(0xFF006045);
  static const emerald900 = Color(0xFF004F3B);
  static const emerald950 = Color(0xFF002C22);

  static const teal50 = Color(0xFFF0FDFA);
  static const teal100 = Color(0xFFCBFBF1);
  static const teal200 = Color(0xFF96F7E4);
  static const teal300 = Color(0xFF46ECD5);
  static const teal400 = Color(0xFF00D5BE);
  static const teal500 = Color(0xFF00BBA7);
  static const teal600 = Color(0xFF009689);
  static const teal700 = Color(0xFF00786F);
  static const teal800 = Color(0xFF005F5A);
  static const teal900 = Color(0xFF0B4F4A);
  static const teal950 = Color(0xFF022F2E);

  static const cyan50 = Color(0xFFECFEFF);
  static const cyan100 = Color(0xFFCEFAFE);
  static const cyan200 = Color(0xFFA2F4FD);
  static const cyan300 = Color(0xFF53EAFD);
  static const cyan400 = Color(0xFF00D3F2);
  static const cyan500 = Color(0xFF00B8DB);
  static const cyan600 = Color(0xFF0092B8);
  static const cyan700 = Color(0xFF007595);
  static const cyan800 = Color(0xFF005F78);
  static const cyan900 = Color(0xFF104E64);
  static const cyan950 = Color(0xFF053345);

  static const sky50 = Color(0xFFF0F9FF);
  static const sky100 = Color(0xFFDFF2FE);
  static const sky200 = Color(0xFFB8E6FE);
  static const sky300 = Color(0xFF74D4FF);
  static const sky400 = Color(0xFF00BCFF);
  static const sky500 = Color(0xFF00A6F4);
  static const sky600 = Color(0xFF0084D1);
  static const sky700 = Color(0xFF0069A8);
  static const sky800 = Color(0xFF00598A);
  static const sky900 = Color(0xFF024A70);
  static const sky950 = Color(0xFF052F4A);

  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBEDBFF);
  static const blue300 = Color(0xFF8EC5FF);
  static const blue400 = Color(0xFF51A2FF);
  static const blue500 = Color(0xFF2B7FFF);
  static const blue600 = Color(0xFF155DFC);
  static const blue700 = Color(0xFF1447E6);
  static const blue800 = Color(0xFF193CB8);
  static const blue900 = Color(0xFF1C398E);
  static const blue950 = Color(0xFF162456);

  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo200 = Color(0xFFC6D2FF);
  static const indigo300 = Color(0xFFA3B3FF);
  static const indigo400 = Color(0xFF7C86FF);
  static const indigo500 = Color(0xFF615FFF);
  static const indigo600 = Color(0xFF4F39F6);
  static const indigo700 = Color(0xFF432DD7);
  static const indigo800 = Color(0xFF372AAC);
  static const indigo900 = Color(0xFF312C85);
  static const indigo950 = Color(0xFF1E1A4D);

  static const violet50 = Color(0xFFF5F3FF);
  static const violet100 = Color(0xFFEDE9FE);
  static const violet200 = Color(0xFFDDD6FF);
  static const violet300 = Color(0xFFC4B4FF);
  static const violet400 = Color(0xFFA684FF);
  static const violet500 = Color(0xFF8E51FF);
  static const violet600 = Color(0xFF7F22FE);
  static const violet700 = Color(0xFF7008E7);
  static const violet800 = Color(0xFF5D0EC0);
  static const violet900 = Color(0xFF4D179A);
  static const violet950 = Color(0xFF2F0D68);

  static const purple50 = Color(0xFFFAF5FF);
  static const purple100 = Color(0xFFF3E8FF);
  static const purple200 = Color(0xFFE9D4FF);
  static const purple300 = Color(0xFFDAB2FF);
  static const purple400 = Color(0xFFC27AFF);
  static const purple500 = Color(0xFFAD46FF);
  static const purple600 = Color(0xFF9810FA);
  static const purple700 = Color(0xFF8200DB);
  static const purple800 = Color(0xFF6E11B0);
  static const purple900 = Color(0xFF59168B);
  static const purple950 = Color(0xFF3C0366);

  static const fuchsia50 = Color(0xFFFDF4FF);
  static const fuchsia100 = Color(0xFFFAE8FF);
  static const fuchsia200 = Color(0xFFF6CFFF);
  static const fuchsia300 = Color(0xFFF4A8FF);
  static const fuchsia400 = Color(0xFFED6AFF);
  static const fuchsia500 = Color(0xFFE12AFB);
  static const fuchsia600 = Color(0xFFC800DE);
  static const fuchsia700 = Color(0xFFA800B7);
  static const fuchsia800 = Color(0xFF8A0194);
  static const fuchsia900 = Color(0xFF721378);
  static const fuchsia950 = Color(0xFF4B004F);

  static const pink50 = Color(0xFFFDF2F8);
  static const pink100 = Color(0xFFFCE7F3);
  static const pink200 = Color(0xFFFCCEE8);
  static const pink300 = Color(0xFFFDA5D5);
  static const pink400 = Color(0xFFFB64B6);
  static const pink500 = Color(0xFFF6339A);
  static const pink600 = Color(0xFFE60076);
  static const pink700 = Color(0xFFC6005C);
  static const pink800 = Color(0xFFA3004C);
  static const pink900 = Color(0xFF861043);
  static const pink950 = Color(0xFF510424);

  static const rose50 = Color(0xFFFFF1F2);
  static const rose100 = Color(0xFFFFE4E6);
  static const rose200 = Color(0xFFFFCCD3);
  static const rose300 = Color(0xFFFFA1AD);
  static const rose400 = Color(0xFFFF637E);
  static const rose500 = Color(0xFFFF2056);
  static const rose600 = Color(0xFFEC003F);
  static const rose700 = Color(0xFFC70036);
  static const rose800 = Color(0xFFA50036);
  static const rose900 = Color(0xFF8B0836);
  static const rose950 = Color(0xFF4D0218);

  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCAD5E2);
  static const slate400 = Color(0xFF90A1B9);
  static const slate500 = Color(0xFF62748E);
  static const slate600 = Color(0xFF45556C);
  static const slate700 = Color(0xFF314158);
  static const slate800 = Color(0xFF1D293D);
  static const slate900 = Color(0xFF0F172B);
  static const slate950 = Color(0xFF020618);

  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DC);
  static const gray400 = Color(0xFF99A1AF);
  static const gray500 = Color(0xFF6A7282);
  static const gray600 = Color(0xFF4A5565);
  static const gray700 = Color(0xFF364153);
  static const gray800 = Color(0xFF1E2939);
  static const gray900 = Color(0xFF101828);
  static const gray950 = Color(0xFF030712);

  static const zinc50 = Color(0xFFFAFAFA);
  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc400 = Color(0xFF9F9FA9);
  static const zinc500 = Color(0xFF71717B);
  static const zinc600 = Color(0xFF52525C);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = Color(0xFF27272A);
  static const zinc900 = Color(0xFF18181B);
  static const zinc950 = Color(0xFF09090B);

  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral400 = Color(0xFFA1A1A1);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);
  static const neutral950 = Color(0xFF0A0A0A);

  static const stone50 = Color(0xFFFAFAF9);
  static const stone100 = Color(0xFFF5F5F4);
  static const stone200 = Color(0xFFE7E5E4);
  static const stone300 = Color(0xFFD6D3D1);
  static const stone400 = Color(0xFFA6A09B);
  static const stone500 = Color(0xFF79716B);
  static const stone600 = Color(0xFF57534D);
  static const stone700 = Color(0xFF44403B);
  static const stone800 = Color(0xFF292524);
  static const stone900 = Color(0xFF1C1917);
  static const stone950 = Color(0xFF0C0A09);
}
