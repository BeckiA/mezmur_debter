import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchBarItem extends StatelessWidget {
  final String placeholder;
  final String value;
  final ValueChanged<String> onChanged;

  const SearchBarItem({
    Key? key,
    required this.placeholder,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final isDarkMode = theme.brightness == Brightness.dark;

    // Colors based on theme
    final textColor = const Color(0xFF333333);
    final textLightColor = const Color(0xFF666666);
    final cardColor = const Color(0xFFFFFFFF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 20, color: textLightColor),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              onChanged: onChanged,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Nyala',
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: textLightColor),
                border: InputBorder.none,
              ),
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () => onChanged(''),
              child: Icon(LucideIcons.x, size: 20, color: textLightColor),
            ),
        ],
      ),
    );
  }
}
