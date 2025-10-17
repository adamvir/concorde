import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../state/theme_state.dart';
import '../theme/app_colors.dart';

// Product Page Customize - Drag & drop to reorder widgets
class ProductPageCustomize extends StatefulWidget {
  final List<ProductWidget> widgets;

  const ProductPageCustomize({
    super.key,
    required this.widgets,
  });

  @override
  _ProductPageCustomizeState createState() => _ProductPageCustomizeState();
}

class _ProductPageCustomizeState extends State<ProductPageCustomize> {
  late List<ProductWidget> _widgets;
  final ThemeState _themeState = ThemeState();

  @override
  void initState() {
    super.initState();
    _widgets = List.from(widget.widgets);
    _themeState.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final widget = _widgets.removeAt(oldIndex);
      _widgets.insert(newIndex, widget);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(colors),

            // Reorderable list
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _widgets.length,
                onReorder: _onReorder,
                onReorderStart: (index) {
                  // Haptic feedback when drag starts
                  HapticFeedback.mediumImpact();
                },
                proxyDecorator: (child, index, animation) {
                  // iOS-style lift effect during drag
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final double elevation = Curves.easeInOut.transform(animation.value) * 8;
                      final double scale = 1.0 + (Curves.easeInOut.transform(animation.value) * 0.05);

                      return Transform.scale(
                        scale: scale,
                        child: Material(
                          elevation: elevation,
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.border,
                                width: 1,
                              ),
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final widget = _widgets[index];
                  return _buildWidgetRow(
                    key: ValueKey(widget.id),
                    widget: widget,
                    isLast: index == _widgets.length - 1,
                    colors: colors,
                  );
                },
              ),
            ),

            // "Kész" button at bottom
            _buildDoneButton(colors),
          ],
        ),
      ),
    );
  }

  // Build header
  Widget _buildHeader(AppColors colors) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(TablerIcons.arrow_left, size: 24, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Oldal testreszabása',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.27,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build widget row with drag handle
  Widget _buildWidgetRow({
    required Key key,
    required ProductWidget widget,
    required bool isLast,
    required AppColors colors,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon on left
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 24,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: colors.textPrimary,
                  height: 1.33,
                ),
              ),
            ),
          ),
          // Drag handle icon (right) - grip_vertical (6 dots)
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              TablerIcons.grip_vertical,
              size: 24,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Build "Kész" button
  Widget _buildDoneButton(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Save the new order and go back
                Navigator.pop(context, _widgets);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(TablerIcons.check, color: colors.background, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kész',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: colors.background,
                      height: 1.50,
                      letterSpacing: 0.10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom safe area spacer
          Container(
            width: double.infinity,
            height: 24,
            color: colors.background,
          ),
        ],
      ),
    );
  }
}

// Product Widget model
class ProductWidget {
  final String id;
  final IconData icon;
  final String title;
  final String? badge;

  ProductWidget({
    required this.id,
    required this.icon,
    required this.title,
    this.badge,
  });
}
