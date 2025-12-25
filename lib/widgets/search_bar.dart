import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:provider/provider.dart';

class SearchBarItem extends StatefulWidget {
  final String placeholder;
  final String value;
  final ValueChanged<String> onChanged;

  const SearchBarItem({
    super.key,
    required this.placeholder,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SearchBarItem> createState() => _SearchBarItemState();
}

class _SearchBarItemState extends State<SearchBarItem> {
  late TextEditingController _controller;
  bool _isUpdatingFromWidget = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SearchBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the value changed AND it's different from controller's current text
    // This prevents resetting during IME composition (like Amharic input)
    if (oldWidget.value != widget.value && 
        _controller.text != widget.value &&
        !_isUpdatingFromWidget) {
      _isUpdatingFromWidget = true;
      final currentSelection = _controller.selection;
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: currentSelection.isValid
            ? currentSelection
            : TextSelection.collapsed(offset: widget.value.length),
      );
      _isUpdatingFromWidget = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 20, color: theme.iconTheme.color),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                // Prevent circular updates
                if (!_isUpdatingFromWidget) {
                  widget.onChanged(value);
                }
              },
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: fontFamilyProvider.fontFamily,
                fontWeight: FontWeight.bold,
              ),
              // Enhanced text input properties for Amharic
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (widget.value.isNotEmpty)
            GestureDetector(
              onTap: () => widget.onChanged(''),
              child: Icon(
                LucideIcons.x,
                size: 20,
                color: theme.iconTheme.color,
              ),
            ),
        ],
      ),
    );
  }
}
