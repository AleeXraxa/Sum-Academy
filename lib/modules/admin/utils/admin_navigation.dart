int? navIndexForLabel(String label) {
  switch (label) {
    case 'Dashboard':
      return 0;
    case 'Users':
    case 'Teachers':
    case 'Students':
    case 'Courses':
    case 'Classes':
      return 1;
    case 'Payments':
    case 'Installments':
      return 2;
    case 'Certificates':
    case 'Announcements':
    case 'Site Settings':
      return 3;
    default:
      return null;
  }
}

String activeLabelForIndex(int index) {
  switch (index) {
    case 0:
      return 'Dashboard';
    case 1:
      return 'Users';
    case 2:
      return 'Payments';
    case 3:
      return 'Site Settings';
    default:
      return 'Dashboard';
  }
}
