import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SearchBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: widget.value.length,
      );
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
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Nyala-Bold',
              ),
              // Enhanced text input properties for Amharic
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Nyala-Bold',
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
