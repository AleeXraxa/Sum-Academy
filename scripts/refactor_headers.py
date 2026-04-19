import os
import re

directory = r'e:\sum_academy\lib\modules\student\views'
files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith('.dart') and 'course_detail' not in f]
files.append(r'e:\sum_academy\lib\modules\home\views\home_view.dart')
files.append(r'e:\sum_academy\lib\modules\student\views\student_course_detail_view.dart')

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if '_HeaderRow' not in content:
        continue
        
    print(f'Modifying {filepath}')
    
    # 1. Add import if not present
    if 'student_dashboard_header.dart' not in content:
        import_stmt = "import 'package:sum_academy/modules/student/widgets/student_dashboard_header.dart';\n"
        # Find last import
        last_import = content.rfind("import '")
        if last_import != -1:
            end_of_import = content.find('\n', last_import)
            content = content[:end_of_import+1] + import_stmt + content[end_of_import+1:]

    # Extract the title from the _HeaderRow implementation to use as subtitle
    # In my_courses_view.dart: Text('My Classes', ...)
    title_match = re.search(r"class _HeaderRow.*?Expanded\(\s*child:\s*Text\(\s*'([^']+)'", content, re.DOTALL)
    subtitle = 'Student Portal'
    if title_match:
        subtitle = title_match.group(1)
        
    # course detail view has a dynamic title: _HeaderRow(textColor: textColor, title: widget.title)
    if 'student_course_detail_view.dart' in filepath:
        content = re.sub(r'_HeaderRow\(textColor:\s*textColor,\s*title:\s*widget\.title\)', "StudentDashboardHeader(subtitle: widget.title)", content)
    else:
        # Replace usages in build methods
        content = re.sub(r'_HeaderRow\(textColor:\s*textColor[^)]*\)', f"StudentDashboardHeader(subtitle: '{subtitle}')", content)
        content = re.sub(r'const _HeaderRow\(\)', "const StudentDashboardHeader()", content)
    
    # Remove _HeaderRow implementation
    idx = content.find('class _HeaderRow extends StatelessWidget')
    if idx != -1:
        # find matching bracket for the class body
        body_start = content.find('{', idx)
        if body_start != -1:
            open_braces = 1
            curr = body_start + 1
            while open_braces > 0 and curr < len(content):
                if content[curr] == '{': open_braces += 1
                elif content[curr] == '}': open_braces -= 1
                curr += 1
            
            # Remove from idx to curr
            content = content[:idx] + content[curr:]

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
print('Done!')
