import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _moodEmojis = ['😊', '😐', '😢', '💡', '⚠️'];
const _moodLabels = ['うれしい', '普通', '辛い', 'ひらめき', '要注意'];
const _moodColors = [
  AppColors.moodHappy,
  AppColors.moodNormal,
  AppColors.moodSad,
  AppColors.moodIdea,
  AppColors.moodAlert,
];

class MoodSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const MoodSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_moodEmojis.length, (i) {
        final isSelected = i == selectedIndex;
        final color = _moodColors[i];
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _moodEmojis[i],
                  style: TextStyle(fontSize: isSelected ? 22 : 18),
                ),
                const SizedBox(height: 2),
                Text(
                  _moodLabels[i],
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? color : AppColors.textMuted,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
