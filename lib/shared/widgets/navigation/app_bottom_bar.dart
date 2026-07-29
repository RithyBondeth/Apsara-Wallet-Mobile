import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_gradients.dart';
import 'package:apsara_wallet_mobile/shared/widgets/motion/press_scale.dart';

/// Floating emerald dock whose selected tab expands into a labelled pill.
///
/// A stadium-shaped dock floats over the content on the brand emerald gradient.
/// Every tab is a **circular chip**; only the selected one carries a label, and
/// it earns the room for it by **expanding into a pill** — the chip fills with
/// gold foil, a lighter capsule grows out behind it, and the label slides open
/// beside it while the tab it left collapses back to a bare circle.
///
/// There is no separate travelling indicator: the reflow *is* the animation.
/// Widths spring (so the arriving pill overshoots a touch and settles), the
/// chip swells as it fills, the label fades in late so the two labels never
/// cross-fade muddily, and the change fires a selection haptic.
///
/// The centre scan button is supplied separately as
/// [Scaffold.floatingActionButton] (see [AppBottomBarCenterButton]) — a gold
/// foil coin. Pair it with [AppBottomBarCenterLocation], which seats it in the
/// middle of the dock; [FloatingActionButtonLocation.centerDocked] would hang
/// it off the dock's top edge instead. Tabs 0–1 share the room left of that
/// coin and tabs 2–3 the room right of it.
///
/// Because each destination is its own route (a fresh bar is built already
/// showing the target index), the previous selection is remembered in
/// [_selectedIndex] so a newly mounted dock animates *from* the tab the user
/// last saw expanded instead of snapping into place.
class AppBottomBar extends StatefulWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Vertical space the bar occupies above the safe area: the dock plus the
  /// gap beneath it. Screens set [Scaffold.extendBody] and add this to their
  /// scroll padding so content clears the dock.
  static const double clearance = _dockHeight + _dockMarginBottom;

  /// Tab that was expanded last, shared across routes so the reflow survives
  /// the push to a new screen.
  static int _selectedIndex = 0;

  /// Forgets the expanded tab, so a test starts from a known state.
  @visibleForTesting
  static void resetSelectionMemory() => _selectedIndex = 0;

  /// Key for tab [index]. Only the selected tab shows its label, so tests
  /// target the tab itself rather than text that may be invisible.
  @visibleForTesting
  static Key tabKey(int index) => ValueKey('appBottomBarTab$index');

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

// ==================================================
// DOCK METRICS
// ==================================================
const double _dockHeight = 64;
const double _dockMarginH = 12;
const double _dockMarginBottom = 12;

/// Fully rounded — the dock is a stadium, like the pills inside it.
const double _dockRadius = _dockHeight / 2;

/// Inset for the tab row. Has to clear the dock's own curve: at the height of
/// a pill's corner the stadium edge has already turned ~9pt inwards.
const double _dockPadH = 10;

/// Gap reserved mid-row for the centre button — the coin plus clearance, so an
/// expanded pill never butts up against it.
const double _centreGap = 62;
const double _centreButtonSize = 46;

// ==================================================
// TAB METRICS
// ==================================================
/// The circular icon chip — the whole tab when it is not selected.
const double _chipSize = 34;
const double _iconSize = 18;

/// The capsule that grows behind chip + label on the selected tab.
const double _pillHeight = 44;
const double _pillPadL = 5;
const double _chipLabelGap = 6;
const double _pillPadR = 10;

/// Room an expanding pill must leave beside its neighbour. Not the drawn gap —
/// that is computed per half in [_AppBottomBarState._layout] — just the reserve
/// the pill is capped against, so the widest label cannot squeeze its
/// neighbouring chip flat.
const double _tabGap = 8;

// ==================================================
// DOCK PALETTE — gold on emerald
// ==================================================
const Color _chipIdle = Color(0x14FFFFFF);
const Color _pillFill = Color(0x1AFFFFFF);
const Color _iconIdle = Color(0xB3FFFFFF);
const Color _dockHairline = Color(0x1FFFFFFF);

/// One tab's horizontal geometry: where its pill sits, and where its taps land.
/// [hitLeft]/[hitWidth] tile the row edge to edge so there is no dead space
/// between tabs, while [left]/[width] track the pill itself.
class _Slot {
  const _Slot(this.left, this.width, this.hitLeft, this.hitWidth);

  final double left;
  final double width;
  final double hitLeft;
  final double hitWidth;

  static _Slot lerp(_Slot a, _Slot b, double t) => _Slot(
    lerpDouble(a.left, b.left, t)!,
    lerpDouble(a.width, b.width, t)!,
    lerpDouble(a.hitLeft, b.hitLeft, t)!,
    lerpDouble(a.hitWidth, b.hitWidth, t)!,
  );
}

class _AppBottomBarState extends State<AppBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );

  /// Tab the pill is collapsing from, and the one it is expanding into.
  late int _from;
  late int _to;

  @override
  void initState() {
    super.initState();
    _to = widget.currentIndex;
    _from = AppBottomBar._selectedIndex;
    AppBottomBar._selectedIndex = _to;
    if (_from == _to) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant AppBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _to) {
      _from = _to;
      _to = widget.currentIndex;
      AppBottomBar._selectedIndex = _to;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index != _to) HapticFeedback.selectionClick();
    widget.onSelect(index);
  }

  /// Width tab [i] takes when it is the expanded one: chip + label + padding,
  /// capped so its neighbour keeps a full circle and a visible gap.
  double _pillWidth(double labelWidth, double regionWidth) {
    final wanted =
        _pillPadL + _chipSize + _chipLabelGap + labelWidth + _pillPadR;
    return wanted.clamp(_chipSize, regionWidth - _chipSize - _tabGap);
  }

  /// Lays the four tabs out for a given selection, spreading each half's
  /// leftover room as **three equal gaps** — before, between and after its
  /// pair.
  ///
  /// The slack has to go somewhere: the coin is pinned to the dock's centre, so
  /// each half is a fixed width while its contents are not (one half may hold
  /// an expanded pill, and a short label — Khmer's are much shorter than
  /// English's — leaves plenty over). Pinning the pair to the half's edges
  /// leaves a hole in the middle; packing and centring it leaves a hole at each
  /// end. Spreading evenly is the only distribution with no gap bigger than the
  /// others, so a half of two bare chips reads as a rhythm rather than as
  /// emptiness.
  List<_Slot> _layout(int selected, List<double> pillWidths, double rowWidth) {
    final gapStart = (rowWidth - _centreGap) / 2;
    final slots = <_Slot>[];
    for (var side = 0; side < 2; side++) {
      final first = side * 2;
      final regionLeft = side == 0 ? 0.0 : gapStart + _centreGap;
      final regionRight = side == 0 ? gapStart : rowWidth;

      final widthA = first == selected ? pillWidths[first] : _chipSize;
      final widthB = first + 1 == selected ? pillWidths[first + 1] : _chipSize;
      final gap = math.max(
        0.0,
        (regionRight - regionLeft - widthA - widthB) / 3,
      );
      final leftA = regionLeft + gap;
      final leftB = leftA + widthA + gap;
      // Taps split midway between the pair and stretch to the row's edge and
      // the centre gap, so no pixel of the row is dead.
      final split = leftA + widthA + gap / 2;

      slots.add(_Slot(leftA, widthA, regionLeft, split - regionLeft));
      slots.add(_Slot(leftB, widthB, split, regionRight - split));
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const icons = [
      LucideIcons.house,
      LucideIcons.chartColumn,
      LucideIcons.wallet,
      LucideIcons.user,
    ];
    final labels = [
      l10n.navHome,
      l10n.navAnalytics,
      l10n.navWallets,
      l10n.navProfile,
    ];
    final labelStyle = AppFont.labelSmall.copyWith(
      fontSize: 10,
      height: 1.1,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w700,
      color: AppColors.surface,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final labelWidths = [
      for (final label in labels) _measureLabel(label, labelStyle, scaler),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: _dockMarginH,
          right: _dockMarginH,
          bottom: _dockMarginBottom,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.emerald,
            borderRadius: BorderRadius.circular(_dockRadius),
            border: Border.all(color: _dockHairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33063D28),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: _dockHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _dockPadH),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rowWidth = constraints.maxWidth;
                  final regionWidth = (rowWidth - _centreGap) / 2;
                  final pillWidths = [
                    for (final width in labelWidths)
                      _pillWidth(width, regionWidth),
                  ];
                  // Room the label actually gets once expanded. Fixed per tab,
                  // so the text renders at one size and the pill merely reveals
                  // it — and on a narrow phone it scales down rather than
                  // losing its last letters.
                  final labelBoxes = [
                    for (final pill in pillWidths)
                      math.max(
                        0.0,
                        pill -
                            _pillPadL -
                            _chipSize -
                            _chipLabelGap -
                            _pillPadR,
                      ),
                  ];
                  final fromSlots = _layout(_from, pillWidths, rowWidth);
                  final toSlots = _layout(_to, pillWidths, rowWidth);

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // Widths spring (easeOutBack overshoots, then settles);
                      // colours ease so nothing lands on a wrong shade.
                      final tSpring = AppCurves.emphasized.transform(
                        _controller.value,
                      );
                      final tEase = AppCurves.entrance.transform(
                        _controller.value,
                      );
                      return Stack(
                        children: [
                          for (var i = 0; i < 4; i++)
                            _Tab(
                              key: AppBottomBar.tabKey(i),
                              slot: _Slot.lerp(
                                fromSlots[i],
                                toSlots[i],
                                tSpring,
                              ),
                              icon: icons[i],
                              label: labels[i],
                              labelStyle: labelStyle,
                              labelBoxWidth: labelBoxes[i],
                              // How selected this tab is right now: the
                              // arriving tab fills up, the leaving one drains,
                              // the rest sit at zero.
                              amount: i == _to
                                  ? tEase
                                  : i == _from
                                  ? 1 - tEase
                                  : 0.0,
                              onTap: () => _select(i),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tab, drawn from its interpolated [slot]: a gold-filling chip, the pill
/// growing behind it, and the label revealing beside it.
class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.slot,
    required this.icon,
    required this.label,
    required this.labelStyle,
    required this.labelBoxWidth,
    required this.amount,
    required this.onTap,
  });

  final _Slot slot;
  final IconData icon;
  final String label;
  final TextStyle labelStyle;
  final double labelBoxWidth;
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = amount.clamp(0.0, 1.0);

    // The chip hugs the pill's left padding once there is room for padding at
    // all; on a bare circle it is the whole tab.
    final chipLeft = math.min(_pillPadL, (slot.width - _chipSize) / 2);
    // How far open the label is, straight off the geometry.
    final labelSpace = math.max(
      0.0,
      slot.width - chipLeft - _chipSize - _chipLabelGap - _pillPadR,
    );
    final openness = labelBoxWidth == 0
        ? 0.0
        : (labelSpace / labelBoxWidth).clamp(0.0, 1.0);
    // Closed, the label parks over the chip so its (invisible) hit box stays
    // inside this tab — the inner tabs would otherwise put it under the coin.
    final labelLeft = lerpDouble(
      chipLeft + _chipSize / 2 - labelBoxWidth / 2,
      chipLeft + _chipSize + _chipLabelGap,
      openness,
    )!;

    return Positioned(
      left: slot.hitLeft,
      width: slot.hitWidth,
      top: 0,
      height: _dockHeight,
      child: Semantics(
        button: true,
        selected: t > 0.5,
        child: PressScale(
          onTap: onTap,
          pressedScale: 0.92,
          child: Stack(
            children: [
              // The pill capsule, fading in as it grows.
              Positioned(
                left: slot.left - slot.hitLeft,
                width: slot.width,
                top: (_dockHeight - _pillHeight) / 2,
                height: _pillHeight,
                child: Opacity(
                  opacity: t,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _pillFill,
                      borderRadius: BorderRadius.circular(_pillHeight / 2),
                    ),
                  ),
                ),
              ),
              // The icon chip: idle circle → gold foil disc.
              Positioned(
                left: slot.left - slot.hitLeft + chipLeft,
                width: _chipSize,
                top: (_dockHeight - _chipSize) / 2,
                height: _chipSize,
                child: Transform.scale(
                  // A small swell on the way in, gone by the time it lands.
                  scale: 1 + 0.06 * math.sin(math.pi * t),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t == 0 ? _chipIdle : null,
                      gradient: t == 0
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.lerp(
                                  _chipIdle,
                                  AppGradients.goldLight,
                                  t,
                                )!,
                                Color.lerp(
                                  _chipIdle,
                                  AppGradients.goldDeep,
                                  t,
                                )!,
                              ],
                            ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: _iconSize,
                        color: Color.lerp(
                          _iconIdle,
                          AppGradients.emeraldDeep,
                          t,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // The label. Always in the tree — invisible and clipped to
              // nothing when closed — so it stays findable and its taps land
              // on this tab.
              Positioned(
                left: slot.left - slot.hitLeft + labelLeft,
                width: labelSpace,
                top: 0,
                height: _dockHeight,
                child: ClipRect(
                  child: OverflowBox(
                    // minWidth 0 matters: the pill's width springs past its
                    // settled size, so the tight width coming in can exceed
                    // labelBoxWidth and the constraints would not normalise.
                    minWidth: 0,
                    maxWidth: labelBoxWidth,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: labelBoxWidth,
                      child: Opacity(
                        // Squared: the arriving label commits only once its
                        // pill is nearly open.
                        opacity: openness * openness,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            style: labelStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Natural single-line width of a nav label, so the pill geometry can be sized
/// before layout. Cached per (text, resolved size) — the dock would otherwise
/// re-measure on every animation frame.
final Map<String, double> _labelWidthCache = {};

double _measureLabel(String text, TextStyle style, TextScaler scaler) {
  final key = '$text|${scaler.scale(style.fontSize ?? 10)}|${style.fontWeight}';
  final cached = _labelWidthCache[key];
  if (cached != null) return cached;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    textScaler: scaler,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return _labelWidthCache[key] = width;
}

/// Seats [Scaffold.floatingActionButton] in the middle of the dock — centred
/// both horizontally and on the dock's own centre line, inside the gap the tab
/// row leaves for it.
///
/// [FloatingActionButtonLocation.centerDocked] cannot express this: it pins the
/// button's centre to the *top edge* of the bottom bar, so half of it hangs
/// above the dock. Here [ScaffoldPrelayoutGeometry.contentBottom] gives that
/// same top edge — which is where the dock starts, the bar's own bottom margin
/// and safe area sitting below it — so the offset is measured down from there.
class AppBottomBarCenterLocation extends FloatingActionButtonLocation {
  const AppBottomBarCenterLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final button = geometry.floatingActionButtonSize;
    return Offset(
      (geometry.scaffoldSize.width - button.width) / 2,
      geometry.contentBottom + (_dockHeight - button.height) / 2,
    );
  }

  @override
  String toString() => 'AppBottomBarCenterLocation';
}

/// The centre scan action — a gold foil coin seated in the middle of the dock,
/// the one warm accent against the emerald. Shrinks under the finger like every
/// other tappable surface. Position it with [AppBottomBarCenterLocation].
class AppBottomBarCenterButton extends StatelessWidget {
  const AppBottomBarCenterButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        width: _centreButtonSize,
        height: _centreButtonSize,
        decoration: BoxDecoration(
          gradient: AppGradients.goldFoil,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.surface.withValues(alpha: 0.22),
            width: 1.5,
          ),
          // Resting on the dock rather than floating over content, so the lift
          // is a soft gold bloom instead of a cast shadow.
          boxShadow: const [
            BoxShadow(color: Color(0x38D4AF37), blurRadius: 12),
            BoxShadow(
              color: Color(0x26042318),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          LucideIcons.plus,
          color: AppGradients.emeraldDeep,
          size: 24,
        ),
      ),
    );
  }
}
