import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/track.dart';

class DownloadRepository {
  final Dio _dio;

  DownloadRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> downloadTrack(Track track, String audioUrl, {Function(int, int)? onProgress}) async {
    try {
      final downloads = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      final baseDirectory = downloads?.first ?? await getApplicationDocumentsDirectory();
      final targetDirectory = Directory('${baseDirectory.path}/Vera');
      if (!targetDirectory.existsSync()) {
        targetDirectory.createSync(recursive: true);
      }

      final fileName = '${track.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.mp3';
      final targetFile = File('${targetDirectory.path}/$fileName');

      await _dio.download(
        audioUrl,
        targetFile.path,
        onReceiveProgress: (count, total) {
          if (onProgress != null) {
            onProgress(count, total);
          }
        },
      );

      return targetFile.path;
    } catch (e) {
      throw Exception('İndirme başarısız: $e');
    }
  }

  Future<List<Track>> getLocalTracks() async {
    try {
      final downloads = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      final baseDirectory = downloads?.first ?? await getApplicationDocumentsDirectory();
      final targetDirectory = Directory('${baseDirectory.path}/Vera');

      if (!targetDirectory.existsSync()) {
        return [];
      }

      final files = targetDirectory.listSync().whereType<File>().where((f) => f.path.endsWith('.mp3')).toList();

      return files
          .map((file) {
            final fileName = file.path.split('/').last.replaceAll('.mp3', '');
            return Track(
              id: file.path,
              title: fileName,
              author: 'Local',
              duration: null,
              thumbnailUrl: '',
              videoUrl: file.path,
            );
          })
          .toList();
    } catch (e) {
      throw Exception('Yerel şarkılar yüklenemedi: $e');
    }
  }
}
