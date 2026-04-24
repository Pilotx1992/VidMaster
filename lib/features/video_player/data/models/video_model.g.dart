// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVideoModelCollection on Isar {
  IsarCollection<VideoModel> get videoModels => this.collection();
}

const VideoModelSchema = CollectionSchema(
  name: r'VideoModel',
  id: -1916123326640997128,
  properties: {
    r'durationMs': PropertySchema(
      id: 0,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'fileName': PropertySchema(
      id: 1,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 2,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'fileSizeBytes': PropertySchema(
      id: 3,
      name: r'fileSizeBytes',
      type: IsarType.long,
    ),
    r'folderName': PropertySchema(
      id: 4,
      name: r'folderName',
      type: IsarType.string,
    ),
    r'isFavourite': PropertySchema(
      id: 5,
      name: r'isFavourite',
      type: IsarType.bool,
    ),
    r'isInVault': PropertySchema(
      id: 6,
      name: r'isInVault',
      type: IsarType.bool,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 7,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'lastPositionMs': PropertySchema(
      id: 8,
      name: r'lastPositionMs',
      type: IsarType.long,
    ),
    r'playCount': PropertySchema(
      id: 9,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'resolution': PropertySchema(
      id: 10,
      name: r'resolution',
      type: IsarType.string,
    ),
    r'thumbnailPath': PropertySchema(
      id: 11,
      name: r'thumbnailPath',
      type: IsarType.string,
    )
  },
  estimateSize: _videoModelEstimateSize,
  serialize: _videoModelSerialize,
  deserialize: _videoModelDeserialize,
  deserializeProp: _videoModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'filePath': IndexSchema(
      id: 2918041768256347220,
      name: r'filePath',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'filePath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _videoModelGetId,
  getLinks: _videoModelGetLinks,
  attach: _videoModelAttach,
  version: '3.1.0+1',
);

int _videoModelEstimateSize(
  VideoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.filePath.length * 3;
  bytesCount += 3 + object.folderName.length * 3;
  {
    final value = object.resolution;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnailPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _videoModelSerialize(
  VideoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.durationMs);
  writer.writeString(offsets[1], object.fileName);
  writer.writeString(offsets[2], object.filePath);
  writer.writeLong(offsets[3], object.fileSizeBytes);
  writer.writeString(offsets[4], object.folderName);
  writer.writeBool(offsets[5], object.isFavourite);
  writer.writeBool(offsets[6], object.isInVault);
  writer.writeDateTime(offsets[7], object.lastPlayedAt);
  writer.writeLong(offsets[8], object.lastPositionMs);
  writer.writeLong(offsets[9], object.playCount);
  writer.writeString(offsets[10], object.resolution);
  writer.writeString(offsets[11], object.thumbnailPath);
}

VideoModel _videoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VideoModel(
    durationMs: reader.readLongOrNull(offsets[0]),
    fileName: reader.readString(offsets[1]),
    filePath: reader.readString(offsets[2]),
    fileSizeBytes: reader.readLong(offsets[3]),
    folderName: reader.readString(offsets[4]),
    isFavourite: reader.readBoolOrNull(offsets[5]) ?? false,
    isInVault: reader.readBoolOrNull(offsets[6]) ?? false,
    lastPlayedAt: reader.readDateTimeOrNull(offsets[7]),
    lastPositionMs: reader.readLongOrNull(offsets[8]),
    playCount: reader.readLongOrNull(offsets[9]) ?? 0,
    resolution: reader.readStringOrNull(offsets[10]),
    thumbnailPath: reader.readStringOrNull(offsets[11]),
  );
  return object;
}

P _videoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _videoModelGetId(VideoModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _videoModelGetLinks(VideoModel object) {
  return [];
}

void _videoModelAttach(IsarCollection<dynamic> col, Id id, VideoModel object) {}

extension VideoModelByIndex on IsarCollection<VideoModel> {
  Future<VideoModel?> getByFilePath(String filePath) {
    return getByIndex(r'filePath', [filePath]);
  }

  VideoModel? getByFilePathSync(String filePath) {
    return getByIndexSync(r'filePath', [filePath]);
  }

  Future<bool> deleteByFilePath(String filePath) {
    return deleteByIndex(r'filePath', [filePath]);
  }

  bool deleteByFilePathSync(String filePath) {
    return deleteByIndexSync(r'filePath', [filePath]);
  }

  Future<List<VideoModel?>> getAllByFilePath(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return getAllByIndex(r'filePath', values);
  }

  List<VideoModel?> getAllByFilePathSync(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'filePath', values);
  }

  Future<int> deleteAllByFilePath(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'filePath', values);
  }

  int deleteAllByFilePathSync(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'filePath', values);
  }

  Future<Id> putByFilePath(VideoModel object) {
    return putByIndex(r'filePath', object);
  }

  Id putByFilePathSync(VideoModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'filePath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFilePath(List<VideoModel> objects) {
    return putAllByIndex(r'filePath', objects);
  }

  List<Id> putAllByFilePathSync(List<VideoModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'filePath', objects, saveLinks: saveLinks);
  }
}

extension VideoModelQueryWhereSort
    on QueryBuilder<VideoModel, VideoModel, QWhere> {
  QueryBuilder<VideoModel, VideoModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VideoModelQueryWhere
    on QueryBuilder<VideoModel, VideoModel, QWhereClause> {
  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> filePathEqualTo(
      String filePath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'filePath',
        value: [filePath],
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterWhereClause> filePathNotEqualTo(
      String filePath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [],
              upper: [filePath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [filePath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [filePath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [],
              upper: [filePath],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VideoModelQueryFilter
    on QueryBuilder<VideoModel, VideoModel, QFilterCondition> {
  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      durationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationMs',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      durationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationMs',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> durationMsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      durationMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      durationMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> durationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> fileNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> fileNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> filePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> filePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> filePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileSizeBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileSizeBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileSizeBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      fileSizeBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSizeBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> folderNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'folderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'folderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'folderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> folderNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'folderName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'folderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'folderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'folderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> folderNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'folderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'folderName',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      folderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'folderName',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      isFavouriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavourite',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> isInVaultEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInVault',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayedAt',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayedAt',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPlayedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPlayedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPlayedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPositionMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPositionMs',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPositionMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPositionMs',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPositionMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPositionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPositionMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPositionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPositionMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPositionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      lastPositionMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPositionMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> playCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      playCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> playCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'resolution',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'resolution',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> resolutionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> resolutionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resolution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition> resolutionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resolution',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolution',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      resolutionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resolution',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailPath',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailPath',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterFilterCondition>
      thumbnailPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailPath',
        value: '',
      ));
    });
  }
}

extension VideoModelQueryObject
    on QueryBuilder<VideoModel, VideoModel, QFilterCondition> {}

extension VideoModelQueryLinks
    on QueryBuilder<VideoModel, VideoModel, QFilterCondition> {}

extension VideoModelQuerySortBy
    on QueryBuilder<VideoModel, VideoModel, QSortBy> {
  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFolderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderName', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByFolderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderName', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByIsFavouriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByIsInVaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByLastPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy>
      sortByLastPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByThumbnailPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> sortByThumbnailPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.desc);
    });
  }
}

extension VideoModelQuerySortThenBy
    on QueryBuilder<VideoModel, VideoModel, QSortThenBy> {
  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFolderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderName', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByFolderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderName', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByIsFavouriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavourite', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByIsInVaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByLastPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy>
      thenByLastPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.desc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByThumbnailPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.asc);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QAfterSortBy> thenByThumbnailPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailPath', Sort.desc);
    });
  }
}

extension VideoModelQueryWhereDistinct
    on QueryBuilder<VideoModel, VideoModel, QDistinct> {
  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSizeBytes');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByFolderName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByIsFavourite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavourite');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInVault');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByLastPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPositionMs');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByResolution(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resolution', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoModel, VideoModel, QDistinct> distinctByThumbnailPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailPath',
          caseSensitive: caseSensitive);
    });
  }
}

extension VideoModelQueryProperty
    on QueryBuilder<VideoModel, VideoModel, QQueryProperty> {
  QueryBuilder<VideoModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VideoModel, int?, QQueryOperations> durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<VideoModel, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<VideoModel, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<VideoModel, int, QQueryOperations> fileSizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSizeBytes');
    });
  }

  QueryBuilder<VideoModel, String, QQueryOperations> folderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folderName');
    });
  }

  QueryBuilder<VideoModel, bool, QQueryOperations> isFavouriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavourite');
    });
  }

  QueryBuilder<VideoModel, bool, QQueryOperations> isInVaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInVault');
    });
  }

  QueryBuilder<VideoModel, DateTime?, QQueryOperations> lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<VideoModel, int?, QQueryOperations> lastPositionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPositionMs');
    });
  }

  QueryBuilder<VideoModel, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<VideoModel, String?, QQueryOperations> resolutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolution');
    });
  }

  QueryBuilder<VideoModel, String?, QQueryOperations> thumbnailPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailPath');
    });
  }
}
