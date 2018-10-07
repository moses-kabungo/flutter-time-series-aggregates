import 'package:flutter_101/models/cultivation-data-entry.dart';

class CultivationDatasetUtils {
  // sort and return
  static void sortByDateAsc(List<CultivationDataEntry> entries) {
    entries
        .sort((first, second) => first.timestamp.compareTo(second.timestamp));
  }
}
