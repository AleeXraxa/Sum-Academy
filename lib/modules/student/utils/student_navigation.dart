const List<String> studentNavItems = [
  'Dashboard',
  'Live Session',
  'My Classes',
  'Explore Classes',
  'My Certificates',
  'Quizzes',
  'Tests',
  'Payments',
  'Announcements',
  'Help and Support',
  'Settings',
];

int? studentNavIndexForLabel(String label) {
  final index = studentNavItems.indexOf(label);
  if (index < 0) {
    return null;
  }
  return index;
}

String studentActiveLabelForIndex(int index) {
  if (index < 0 || index >= studentNavItems.length) {
    return studentNavItems.first;
  }
  return studentNavItems[index];
}
