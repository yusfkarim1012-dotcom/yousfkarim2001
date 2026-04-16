import re

file_path = '/Users/mahomudatef/Skoon-Flutter-Islamic-App/lib/core/QuranPages/views/quranDetailsPage.dart'

with open(file_path, 'r') as f:
    content = f.read()

# Imports to add
new_imports = """
import 'package:nabd/core/QuranPages/widgets/details_page/ayah_options_sheet.dart';
import 'package:nabd/core/QuranPages/helpers/quran_audio_helper.dart';
"""

if "import 'package:nabd/core/QuranPages/widgets/details_page/ayah_options_sheet.dart';" not in content:
    content = content.replace("import 'package:quran/quran.dart' as quran;", "import 'package:quran/quran.dart' as quran;\n" + new_imports)

# Replace showAyahOptionsSheet logic
# Signature found:
#   showAyahOptionsSheet(
#     index,
#     surahNumber,
#     verseNumber,
#   ) {

# We will search for this pattern flexible with whitespace
pattern = r"showAyahOptionsSheet\s*\(\s*index,\s*surahNumber,\s*verseNumber,\s*\)\s*{"

match = re.search(pattern, content)
if match:
    start_index = match.start()
    # Find closing brace
    brace_index = content.find('{', start_index)
    balance = 1
    i = brace_index + 1
    while i < len(content) and balance > 0:
        if content[i] == '{':
            balance += 1
        elif content[i] == '}':
            balance -= 1
        i += 1
    
    if balance == 0:
        # Construct replacement
        replacement = """showAyahOptionsSheet(index, surahNumber, verseNumber) {
    AyahOptionsSheet.show(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      index: index,
      bookmarks: bookmarks,
      jsonData: widget.jsonData,
      onAddBookmark: (s, v) async {
         List<String> colorOptions = ["0xFF2196F3", "0xFFF44336", "0xFFE91E63", "0xFF9C27B0", "0xFF3F51B5"];
         String selectedColor = colorOptions[0];
         bookmarks.add({
             "suraNumber": s,
             "verseNumber": v,
             "color": selectedColor.replaceAll("0x", "")
         });
         updateValue("bookmarks", json.encode(bookmarks));
         setState(() {});
      },
      onRemoveBookmark: (s, v) {
          bookmarks.removeWhere((element) => element["suraNumber"] == s && element["verseNumber"] == v);
          updateValue("bookmarks", json.encode(bookmarks));
          setState(() {});
      },
      isVerseStarred: isVerseStarred,
      onToggleStar: (s, v) {
         if (isVerseStarred(s, v)) {
            removeStarredVerse(s, v);
         } else {
            addStarredVerse(s, v);
         }
         setState(() {});
      },
    );
  }"""
        content = content[:start_index] + replacement + content[i:]
    else:
        print("Could not balance braces")
else:
    print("Function signature not found with regex")

with open(file_path, 'w') as f:
    f.write(content)
