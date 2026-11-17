from pathlib import Path

# Fix 1: personality_state.dart - add library directive
path = Path('lib/data/model/personality_state.dart')
content = path.read_text()
if 'library ' not in content:
    content = 'library amadeus_personality_model;\n\n' + content
path.write_text(content)

# Fix 2: chat_screen.dart - const Paint() .. operators => non-const Paint
path = Path('lib/p005ui/screens/chat_screen.dart')
content = path.read_text()
content = content.replace(
    "final line = const Paint()..color = const Color(0xFFB66B70).withValues(alpha: 41)..strokeWidth = 1;",
    "final line = Paint()..color = const Color(0xFFB66B70).withValues(alpha: 41)..strokeWidth = 1;"
)
path.write_text(content)

# Fix 3: kurisu_avatar.dart - remove 'const' from BoxDecoration with non-const args
path = Path('lib/p005ui/widgets/kurisu_avatar.dart')
content = path.read_text()
content = content.replace(
    "decoration: const BoxDecoration(",
    "decoration: BoxDecoration("
)
path.write_text(content)

print('All fixes applied')
