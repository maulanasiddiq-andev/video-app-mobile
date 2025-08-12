import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

MediaType convertPathToMediaType(String path) {
  final mimeType = lookupMimeType(path);
  final mediaType = mimeType?.split('/');

  return MediaType(mediaType![0], mediaType[1]);
}