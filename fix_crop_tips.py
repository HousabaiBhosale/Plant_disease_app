filepath = r"c:\Users\HP\PlantDiseaseApp\plant_disease_app\lib\pages\home_page.dart"

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Find and replace the _CropTipsCarousel class completely
# It starts after a comment line and ends at the closing brace before PROFILE TAB comment
import re

new_class = '''// \u2500\u2500 Crop Tips Carousel \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
class _CropTipsCarousel extends StatelessWidget {
  const _CropTipsCarousel();

  // Using (icon, iconColor, title, body) - NO emoji strings to avoid encoding issues
  static const List<(IconData, Color, String, String)> _tips = [
    (Icons.water_drop_rounded,   Color(0xFF2D84C8), 'Water Early',
      'Water crops before 8 AM to prevent fungal growth during the day.'),
    (Icons.wb_sunny_rounded,     Color(0xFFF5A623), 'Scan in Light',
      'Scan leaves in natural sunlight for most accurate AI results.'),
    (Icons.content_cut_rounded,  Color(0xFFE03C3C), 'Prune Infected',
      'Remove infected leaves immediately to stop disease spreading.'),
    (Icons.refresh_rounded,      Color(0xFF1E8049), 'Rotate Fungicides',
      'Alternate between fungicide types to prevent resistance.'),
    (Icons.straighten_rounded,   Color(0xFF7C3AED), 'Correct Distance',
      'Hold phone 20-30 cm from leaf for best camera focus.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (icon, color, title, body) = _tips[i];
          return Container(
            width: 185,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(
                color: AppColors.g900.withValues(alpha: 0.06),
                blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text))),
              ]),
              const SizedBox(height: 6),
              Text(body,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSoft, height: 1.4),
                maxLines: 3, overflow: TextOverflow.ellipsis),
            ]),
          );
        },
      ),
    );
  }
}
'''

# Use regex to replace the entire _CropTipsCarousel class
pattern = r'// .{0,5}Crop Tips Carousel.+?^}(?=\s*\n\s*// [\u2550\u2500])'
match = re.search(pattern, content, re.DOTALL | re.MULTILINE)
if match:
    content = content[:match.start()] + new_class + '\n' + content[match.end():]
    print(f"Replaced _CropTipsCarousel at position {match.start()}")
else:
    # Try a simpler approach: find by class name
    start = content.find('class _CropTipsCarousel extends StatelessWidget')
    if start == -1:
        print("ERROR: Could not find _CropTipsCarousel class")
    else:
        # Find the end of the class (next top-level class or comment)
        search_from = start
        brace_depth = 0
        in_class = False
        end_pos = start
        for i, ch in enumerate(content[start:], start=start):
            if ch == '{':
                brace_depth += 1
                in_class = True
            elif ch == '}':
                brace_depth -= 1
                if in_class and brace_depth == 0:
                    end_pos = i + 1
                    break
        
        # Find the comment before the class
        # Go back from start to find the // line
        line_start = content.rfind('\n', 0, start)
        comment_line_start = content.rfind('\n', 0, line_start) + 1
        
        content = content[:comment_line_start] + new_class + '\n' + content[end_pos:]
        print(f"Replaced _CropTipsCarousel from {comment_line_start} to {end_pos}")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done!")
