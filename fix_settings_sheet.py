from pathlib import Path

path = Path('lib/p005ui/screens/settings_sheet.dart')
content = path.read_text()

# Fix invalid_constant / unnecessary_const / const with non-const args
# 1. Remove 'const' from TextStyle(color: text) or TextStyle(color: hint) etc.
content = content.replace(
    "style: const TextStyle(color: text)",
    "style: TextStyle(color: text)"
)
content = content.replace(
    "style: const TextStyle(color: hint, fontSize: 11)",
    "style: const TextStyle(fontSize: 11)"
)
content = content.replace(
    "style: const TextStyle(color: text, fontSize: 12)",
    "style: const TextStyle(fontSize: 12)"
)
content = content.replace(
    "style: const TextStyle(color: hint, fontSize: 12)",
    "style: const TextStyle(fontSize: 12)"
)
content = content.replace(
    "style: const TextStyle(color: hint, fontSize: 11)",
    "style: const TextStyle(fontSize: 11)"
)
# 2. Remove 'const' from unnecessary const calls
content = content.replace(
    "child: const Text('Kaydet', style: const TextStyle(color: AppTheme.accentGreen))",
    "child: const Text('Kaydet', style: TextStyle(color: AppTheme.accentGreen))"
)
content = content.replace(
    "child: const Text('İndir', style: const TextStyle(color: AppTheme.accentGreen))",
    "child: const Text('İndir', style: TextStyle(color: AppTheme.accentGreen))"
)
content = content.replace(
    "child: const Text('Yükle', style: const TextStyle(color: AppTheme.accentGreen))",
    "child: const Text('Yükle', style: TextStyle(color: AppTheme.accentGreen))"
)

path.write_text(content)
print('settings_sheet.dart fixed')
