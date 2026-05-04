import 'package:isar/isar.dart';

part 'extraction_cache_model.g.dart';

@collection
class ExtractionCacheModel {
  Id get id => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String url;

  String payload;
  DateTime cachedAt;

  ExtractionCacheModel({
    required this.url,
    required this.payload,
    required this.cachedAt,
  });
}
