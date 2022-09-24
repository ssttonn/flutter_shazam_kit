import 'package:flutter_shazam_kit/models/media_item.dart';

abstract class MatchResult {}

class Matched extends MatchResult {
  List<MediaItem> mediaItems;
  Matched({required this.mediaItems});
}

class NoMatch extends MatchResult {}
