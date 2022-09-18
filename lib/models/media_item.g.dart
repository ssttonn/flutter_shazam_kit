// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      shazamId: json['shazamId'] as String? ?? '',
      appleMusicId: json['appleMusicId'] as String? ?? '',
      appleMusicUrl: json['appleMusicUrl'] as String? ?? '',
      artworkUrl: json['artworkUrl'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      matchOffset: (json['matchOffset'] as num?)?.toDouble() ?? 0,
      videoUrl: json['videoUrl'] as String? ?? '',
      webUrl: json['webUrl'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isrc: json['isrc'] as String? ?? '',
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'shazamId': instance.shazamId,
      'appleMusicId': instance.appleMusicId,
      'appleMusicUrl': instance.appleMusicUrl,
      'artworkUrl': instance.artworkUrl,
      'artist': instance.artist,
      'matchOffset': instance.matchOffset,
      'videoUrl': instance.videoUrl,
      'webUrl': instance.webUrl,
      'genres': instance.genres,
      'isrc': instance.isrc,
    };
