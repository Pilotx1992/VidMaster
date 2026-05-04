// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_resume_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVideoResumeIsarCollection on Isar {
  IsarCollection<VideoResumeIsar> get videoResumeIsars => this.collection();
}

const VideoResumeIsarSchema = CollectionSchema(
  name: r'VideoResumeIsar',
  id: 8295088537161084751,
  properties: {
    r'positionMs': PropertySchema(
      id: 0,
      name: r'positionMs',
      type: IsarType.long,
    ),
    r'videoPathHash': PropertySchema(
      id: 1,
      name: r'videoPathHash',
      type: IsarType.string,
    )
  },
  estimateSize: _videoResumeIsarEstimateSize,
  serialize: _videoResumeIsarSerialize,
  deserialize: _videoResumeIsarDeserialize,
  deserializeProp: _videoResumeIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'videoPathHash': IndexSchema(
      id: 6614224716109851901,
      name: r'videoPathHash',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'videoPathHash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _videoResumeIsarGetId,
  getLinks: _videoResumeIsarGetLinks,
  attach: _videoResumeIsarAttach,
  version: '3.1.0+1',
);

int _videoResumeIsarEstimateSize(
  VideoResumeIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.videoPathHash.length * 3;
  return bytesCount;
}

void _videoResumeIsarSerialize(
  VideoResumeIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.positionMs);
  writer.writeString(offsets[1], object.videoPathHash);
}

VideoResumeIsar _videoResumeIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VideoResumeIsar();
  object.id = id;
  object.positionMs = reader.readLong(offsets[0]);
  object.videoPathHash = reader.readString(offsets[1]);
  return object;
}

P _videoResumeIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _videoResumeIsarGetId(VideoResumeIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _videoResumeIsarGetLinks(VideoResumeIsar object) {
  return [];
}

void _videoResumeIsarAttach(
    IsarCollection<dynamic> col, Id id, VideoResumeIsar object) {
  object.id = id;
}

extension VideoResumeIsarByIndex on IsarCollection<VideoResumeIsar> {
  Future<VideoResumeIsar?> getByVideoPathHash(String videoPathHash) {
    return getByIndex(r'videoPathHash', [videoPathHash]);
  }

  VideoResumeIsar? getByVideoPathHashSync(String videoPathHash) {
    return getByIndexSync(r'videoPathHash', [videoPathHash]);
  }

  Future<bool> deleteByVideoPathHash(String videoPathHash) {
    return deleteByIndex(r'videoPathHash', [videoPathHash]);
  }

  bool deleteByVideoPathHashSync(String videoPathHash) {
    return deleteByIndexSync(r'videoPathHash', [videoPathHash]);
  }

  Future<List<VideoResumeIsar?>> getAllByVideoPathHash(
      List<String> videoPathHashValues) {
    final values = videoPathHashValues.map((e) => [e]).toList();
    return getAllByIndex(r'videoPathHash', values);
  }

  List<VideoResumeIsar?> getAllByVideoPathHashSync(
      List<String> videoPathHashValues) {
    final values = videoPathHashValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'videoPathHash', values);
  }

  Future<int> deleteAllByVideoPathHash(List<String> videoPathHashValues) {
    final values = videoPathHashValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'videoPathHash', values);
  }

  int deleteAllByVideoPathHashSync(List<String> videoPathHashValues) {
    final values = videoPathHashValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'videoPathHash', values);
  }

  Future<Id> putByVideoPathHash(VideoResumeIsar object) {
    return putByIndex(r'videoPathHash', object);
  }

  Id putByVideoPathHashSync(VideoResumeIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'videoPathHash', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVideoPathHash(List<VideoResumeIsar> objects) {
    return putAllByIndex(r'videoPathHash', objects);
  }

  List<Id> putAllByVideoPathHashSync(List<VideoResumeIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'videoPathHash', objects, saveLinks: saveLinks);
  }
}

extension VideoResumeIsarQueryWhereSort
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QWhere> {
  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VideoResumeIsarQueryWhere
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QWhereClause> {
  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause>
      videoPathHashEqualTo(String videoPathHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'videoPathHash',
        value: [videoPathHash],
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterWhereClause>
      videoPathHashNotEqualTo(String videoPathHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPathHash',
              lower: [],
              upper: [videoPathHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPathHash',
              lower: [videoPathHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPathHash',
              lower: [videoPathHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPathHash',
              lower: [],
              upper: [videoPathHash],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VideoResumeIsarQueryFilter
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QFilterCondition> {
  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      positionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      positionMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      positionMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      positionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'positionMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPathHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoPathHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoPathHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoPathHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoPathHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoPathHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoPathHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoPathHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPathHash',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterFilterCondition>
      videoPathHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoPathHash',
        value: '',
      ));
    });
  }
}

extension VideoResumeIsarQueryObject
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QFilterCondition> {}

extension VideoResumeIsarQueryLinks
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QFilterCondition> {}

extension VideoResumeIsarQuerySortBy
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QSortBy> {
  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      sortByVideoPathHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPathHash', Sort.asc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      sortByVideoPathHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPathHash', Sort.desc);
    });
  }
}

extension VideoResumeIsarQuerySortThenBy
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QSortThenBy> {
  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      thenByVideoPathHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPathHash', Sort.asc);
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QAfterSortBy>
      thenByVideoPathHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPathHash', Sort.desc);
    });
  }
}

extension VideoResumeIsarQueryWhereDistinct
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QDistinct> {
  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QDistinct>
      distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }

  QueryBuilder<VideoResumeIsar, VideoResumeIsar, QDistinct>
      distinctByVideoPathHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoPathHash',
          caseSensitive: caseSensitive);
    });
  }
}

extension VideoResumeIsarQueryProperty
    on QueryBuilder<VideoResumeIsar, VideoResumeIsar, QQueryProperty> {
  QueryBuilder<VideoResumeIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VideoResumeIsar, int, QQueryOperations> positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }

  QueryBuilder<VideoResumeIsar, String, QQueryOperations>
      videoPathHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoPathHash');
    });
  }
}
