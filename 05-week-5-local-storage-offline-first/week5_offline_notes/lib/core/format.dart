String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
}

String normalizeRoute(String route) {
  if (route.isEmpty) {
    return '/';
  }

  return route.startsWith('/') ? route : '/$route';
}