import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchBarItem extends StatelessWidget {
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
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              onChanged: onChanged,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Nyala-Bold',
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Nyala-Bold',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () => onChanged(''),
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
