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

# Replacement for showAyahOptionsSheet
# It matches the function signature and replaces the body with the call to static show method.
# We need to capture the exact signature.
# Based on previous view: showAyahOptionsSheet(context, index, surahNumber, verseNumber) async {

# We will use regex to match the function definition up to its closing brace.
# Since it's nested (it has nested braces), regex might be tricky.
# But we annotated the line ranges roughly.
# Better strategy: define a marker for the start of the function and find the matching closing brace.

def replace_function(content, start_marker, replacement_code):
    start_index = content.find(start_marker)
    if start_index == -1:
        print(f"Start marker not found: {start_marker}")
        return content
    
    # Find the opening brace
    brace_index = content.find('{', start_index)
    if brace_index == -1:
        return content
    
    # Find matching closing brace
    balance = 1
    i = brace_index + 1
    while i < len(content) and balance > 0:
        if content[i] == '{':
            balance += 1
        elif content[i] == '}':
            balance -= 1
        i += 1
    
    if balance == 0:
        # i is now the index after the closing brace
        original_function = content[start_index:i]
        return content.replace(original_function, replacement_code)
    return content

# 1. Replace showAyahOptionsSheet
show_ayah_marker = "showAyahOptionsSheet(context, index, surahNumber, verseNumber) async"
show_ayah_replacement = """showAyahOptionsSheet(context, index, surahNumber, verseNumber) async {
    AyahOptionsSheet.show(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      index: index,
      bookmarks: bookmarks,
      jsonData: widget.jsonData,
      onAddBookmark: (s, v) async {
         // Replicating add bookmark logic
         List<String> colorOptions = ["0xFF2196F3", "0xFFF44336", "0xFFE91E63", "0xFF9C27B0", "0xFF3F51B5"];
         String selectedColor = colorOptions[0];
         bookmarks.add({
             "suraNumber": s,
             "verseNumber": v,
             "color": selectedColor.replaceAll("0x", "")
         });
         updateValue("bookmarks", json.encode(bookmarks));
         setState(() {});
         // fetchBookmarks(); // If needed
      },
      onRemoveBookmark: (s, v) {
          bookmarks.removeWhere((element) => element["suraNumber"] == s && element["verseNumber"] == v);
          updateValue("bookmarks", json.encode(bookmarks));
          setState(() {});
          // fetchBookmarks();
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

content = replace_function(content, show_ayah_marker, show_ayah_replacement)

# 2. Remove takeScreenshotFunction
# It is now used by ShareAyahDialog, so we can remove it from here.
take_screenshot_marker = "takeScreenshotFunction(index, surahNumber, verseNumber) {"
# Remove it completely (replace with empty string or comment)
content = replace_function(content, take_screenshot_marker, "")

# 3. Remove downloadAndCacheSuraAudio
download_audio_marker = "Future<void> downloadAndCacheSuraAudio"
content = replace_function(content, download_audio_marker, "")

with open(file_path, 'w') as f:
    f.write(content)
