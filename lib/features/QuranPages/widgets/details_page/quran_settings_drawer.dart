import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:khatmah/GlobalHelpers/constants.dart';
import 'package:khatmah/GlobalHelpers/hive_helper.dart';

class QuranSettingsDrawer extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const QuranSettingsDrawer({super.key, required this.onSettingsChanged});

  @override
  State<QuranSettingsDrawer> createState() => _QuranSettingsDrawerState();
}

class _QuranSettingsDrawerState extends State<QuranSettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = getValue("darkMode") ?? false;
    return Drawer(
      backgroundColor: isDarkMode ? quranPagesColorDark : quranPagesColorLight,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "settings".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      "darkMode".tr(),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (val) {
                        updateValue("darkMode", val);
                        widget.onSettingsChanged();
                        setState(() {});
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "color".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: backgroundColors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          updateValue("quranPageolorsIndex", index);
                          widget.onSettingsChanged();
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColors[index],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: getValue("quranPageolorsIndex") == index 
                                  ? Colors.blue 
                                  : Colors.grey.withOpacity(0.5),
                              width: getValue("quranPageolorsIndex") == index ? 3 : 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
