/// Labels for [VideosRecord.videoNiche] stored in Firestore.
/// Empty or missing field is treated like [kVideoNicheGeneral] for the home feed.
const String kVideoNicheGeneral = 'general';

const List<MapEntry<String, String>> kVideoCreatorNiches = [
  MapEntry(kVideoNicheGeneral, 'General'),
  MapEntry('beauty', 'Beauty'),
  MapEntry('art', 'Art'),
  MapEntry('entertainment', 'Entertainment'),
  MapEntry('fitness', 'Fitness'),
  MapEntry('music', 'Music'),
  MapEntry('gaming', 'Gaming'),
  MapEntry('lifestyle', 'Lifestyle'),
  MapEntry('education', 'Education'),
];

/// For home browse chips: first entry is "All" (no filter).
const List<MapEntry<String, String>> kHomeNicheChips = [
  MapEntry('', 'All'),
  MapEntry('__promoted__', 'Promoted'),
  ...kVideoCreatorNiches,
];

bool videoMatchesHomeNicheFilter(String videoNiche, String filterKey) {
  if (filterKey.isEmpty) return true;
  if (filterKey == kVideoNicheGeneral) {
    return videoNiche.isEmpty || videoNiche == kVideoNicheGeneral;
  }
  return videoNiche == filterKey;
}
