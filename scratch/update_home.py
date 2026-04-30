import re

def update_home_dart():
    with open('lib/features/home.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Add import
    import_stmt1 = "import 'package:workmanager/workmanager.dart';"
    import_stmt2 = "import 'package:workmanager/workmanager.dart';\nimport 'package:khatmah/features/widgets/animated_islamic_decorations.dart';"
    if "import 'package:khatmah/features/widgets/animated_islamic_decorations.dart';" not in content:
        content = content.replace(import_stmt1, import_stmt2)

    # Find the Scaffold child
    scaffold_start = "child: Scaffold("
    scaffold_idx = content.find(scaffold_start)
    if scaffold_idx == -1:
        print("Could not find Scaffold")
        return
        
    print(f"Found Scaffold at index {scaffold_idx}")
    
    # We will replace `child: Scaffold(` with `child: Stack(children: [Scaffold(`
    replacement = "child: Stack(children: [Scaffold("
    
    # We need to find the matching closing parenthesis for Scaffold(
    # The 'Scaffold(' starts at scaffold_idx + 7
    open_parens = 0
    i = scaffold_idx + 7 # index of 'S' in Scaffold
    # advance to first '('
    while content[i] != '(':
        i += 1
    
    i += 1 # move past '('
    open_parens = 1
    
    while i < len(content):
        if content[i] == '(':
            open_parens += 1
        elif content[i] == ')':
            open_parens -= 1
            if open_parens == 0:
                break
        i += 1
        
    print(f"Found closing parenthesis at index {i}")
    
    # Now we do the string replacement
    # up to scaffold_idx -> replacement -> up to i -> append stack children -> rest
    
    part1 = content[:scaffold_idx]
    part2 = replacement
    part3 = content[scaffold_idx + len(scaffold_start):i+1]
    
    stack_end = """,
                          if (index == 1)
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: AnimatedIslamicDecorations(),
                              ),
                            ),
                        ],
                      )"""
                      
    part4 = content[i+1:]
    
    new_content = part1 + part2 + part3 + stack_end + part4
    
    with open('lib/features/home.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Done")

update_home_dart()
