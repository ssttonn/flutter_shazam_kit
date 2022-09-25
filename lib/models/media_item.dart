part 'media_item.g.dart';

// @JsonSerializable()
class MediaItem {
  // @JsonKey(defaultValue: "")
  final String title;
  // @JsonKey(defaultValue: "")
  final String subtitle;
  // @JsonKey(defaultValue: "")
  final String shazamId;
  // @JsonKey(defaultValue: "")
  final String appleMusicId;
  // @JsonKey(defaultValue: "")
  final String appleMusicUrl;
  // @JsonKey(defaultValue: "")
  final String artworkUrl;
  // @JsonKey(defaultValue: "")
  final String artist;
  // @JsonKey(defaultValue: 0)
  final double matchOffset;
  // @JsonKey(defaultValue: "")
  final String videoUrl;
  // @JsonKey(defaultValue: "")
  final String webUrl;
  // @JsonKey(defaultValue: [])
  final List<String> genres;
  // @JsonKey(defaultValue: "")
  final String isrc;
  // @JsonKey(defaultValue: [], ignore: true)
  // final List<Song> songs;

  MediaItem(
      {required this.title,
      this.subtitle = "",
      required this.shazamId,
      required this.appleMusicId,
      required this.appleMusicUrl,
      this.artworkUrl = "",
      required this.artist,
      this.matchOffset = 0,
      this.videoUrl = "",
      this.webUrl = "",
      this.genres = const [],
      this.isrc = ""});

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  Map<String, dynamic> toJson() => _$MediaItemToJson(this);
}

// class Song {
//   final String id;
//   final String title;
//   final String url;
//   final String albumTitle;
//   final String artistName;
//   final String artistUrl;
//   final String attribution;
//   final String composerName;
//   final String workName;
//   final String isrc;

//   final bool isAppleDigitalMaster;
//   final bool hasLyrics;

//   final int discNumber;
//   final int movementCount;
//   final int movementName;
//   final int movementNumber;
//   final int playCount;
//   final int trackNumber;

//   final double duration;

//   final DateTime releaseDate;
//   final DateTime lastPlayedDate;
//   final DateTime libraryAddedDate;

//   final List<Album> albums;
//   final List<Artist> artists;
//   final List<Artist> composers;
//   final List<Genre> genres;
//   final List<AudioVariant> audioVariants;
//   final List<PreviewAsset> previewAssets;
//   final List<String> genreNames;
//   final ArtWork artwork;
//   final Station station;

//   Song(
//       this.id,
//       this.title,
//       this.url,
//       this.albumTitle,
//       this.artistName,
//       this.artistUrl,
//       this.isrc,
//       this.attribution,
//       this.composerName,
//       this.isAppleDigitalMaster,
//       this.discNumber,
//       this.duration,
//       this.hasLyrics,
//       this.releaseDate,
//       this.lastPlayedDate,
//       this.libraryAddedDate,
//       this.movementCount,
//       this.movementName,
//       this.movementNumber,
//       this.playCount,
//       this.trackNumber,
//       this.workName,
//       this.albums,
//       this.artists,
//       this.genres,
//       this.composers,
//       this.genreNames,
//       this.audioVariants,
//       this.previewAssets,
//       this.artwork,
//       this.station);
// }

// class Album {
//   final String id;
//   final String title;
//   final String copyright;
//   final DateTime lastPlayedDate;
//   final DateTime libraryAddedDate;
//   final DateTime releaseDate;
//   final ArtWork artWork;
//   final bool isAppleDigitalMaster;
//   final String url;
//   final String artistName;
//   final String artistUrl;
//   final String recordLabelName;
//   final String upc;
//   final int trackCount;

//   final List<String> genreNames;
//   final List<Artist> artists;
//   final List<AudioVariant> audioVariants;
//   final List<Playlist> appearOn;
//   final List<Genre> genres;
//   final List<Album> otherVersions;
//   final List<Album> relatedAlbums;
//   final List<MusicVideo> relatedVideos;
//   final List<RecordLabel> recordLabels;
//   final List<Track> tracks;

//   final bool isComplilation;
//   final bool isComplete;
//   final bool isSingle;

//   Album(
//       this.id,
//       this.title,
//       this.copyright,
//       this.lastPlayedDate,
//       this.libraryAddedDate,
//       this.releaseDate,
//       this.artWork,
//       this.isAppleDigitalMaster,
//       this.url,
//       this.artistName,
//       this.artistUrl,
//       this.recordLabelName,
//       this.upc,
//       this.trackCount,
//       this.genreNames,
//       this.artists,
//       this.audioVariants,
//       this.appearOn,
//       this.genres,
//       this.otherVersions,
//       this.relatedAlbums,
//       this.relatedVideos,
//       this.recordLabels,
//       this.tracks,
//       this.isComplilation,
//       this.isComplete,
//       this.isSingle);
// }

// class Artist {}

// class AudioVariant {}

// class MusicVideo {}

// class Genre {}

// class Station {}

// class ArtWork {}

// class PreviewAsset {}

// class Playlist {}

// class RecordLabel {}

// class Track {}
