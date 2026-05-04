// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_subtitle_preferences_repository.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarSubtitleSettingsRecordCollection on Isar {
  IsarCollection<IsarSubtitleSettingsRecord> get isarSubtitleSettingsRecords =>
      this.collection();
}

const IsarSubtitleSettingsRecordSchema = CollectionSchema(
  name: r'IsarSubtitleSettingsRecord',
  id: 5310378332950173086,
  properties: {
    r'fontSize': PropertySchema(
      id: 0,
      name: r'fontSize',
      type: IsarType.double,
    ),
    r'isVisible': PropertySchema(
      id: 1,
      name: r'isVisible',
      type: IsarType.bool,
    ),
    r'syncOffsetMs': PropertySchema(
      id: 2,
      name: r'syncOffsetMs',
      type: IsarType.long,
    ),
    r'videoPath': PropertySchema(
      id: 3,
      name: r'videoPath',
      type: IsarType.string,
    )
  },
  estimateSize: _isarSubtitleSettingsRecordEstimateSize,
  serialize: _isarSubtitleSettingsRecordSerialize,
  deserialize: _isarSubtitleSettingsRecordDeserialize,
  deserializeProp: _isarSubtitleSettingsRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'videoPath': IndexSchema(
      id: 8864946403865301343,
      name: r'videoPath',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'videoPath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarSubtitleSettingsRecordGetId,
  getLinks: _isarSubtitleSettingsRecordGetLinks,
  attach: _isarSubtitleSettingsRecordAttach,
  version: '3.1.0+1',
);

int _isarSubtitleSettingsRecordEstimateSize(
  IsarSubtitleSettingsRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.videoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarSubtitleSettingsRecordSerialize(
  IsarSubtitleSettingsRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.fontSize);
  writer.writeBool(offsets[1], object.isVisible);
  writer.writeLong(offsets[2], object.syncOffsetMs);
  writer.writeString(offsets[3], object.videoPath);
}

IsarSubtitleSettingsRecord _isarSubtitleSettingsRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarSubtitleSettingsRecord();
  object.fontSize = reader.readDouble(offsets[0]);
  object.id = id;
  object.isVisible = reader.readBool(offsets[1]);
  object.syncOffsetMs = reader.readLong(offsets[2]);
  object.videoPath = reader.readStringOrNull(offsets[3]);
  return object;
}

P _isarSubtitleSettingsRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarSubtitleSettingsRecordGetId(IsarSubtitleSettingsRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarSubtitleSettingsRecordGetLinks(
    IsarSubtitleSettingsRecord object) {
  return [];
}

void _isarSubtitleSettingsRecordAttach(
    IsarCollection<dynamic> col, Id id, IsarSubtitleSettingsRecord object) {
  object.id = id;
}

extension IsarSubtitleSettingsRecordByIndex
    on IsarCollection<IsarSubtitleSettingsRecord> {
  Future<IsarSubtitleSettingsRecord?> getByVideoPath(String? videoPath) {
    return getByIndex(r'videoPath', [videoPath]);
  }

  IsarSubtitleSettingsRecord? getByVideoPathSync(String? videoPath) {
    return getByIndexSync(r'videoPath', [videoPath]);
  }

  Future<bool> deleteByVideoPath(String? videoPath) {
    return deleteByIndex(r'videoPath', [videoPath]);
  }

  bool deleteByVideoPathSync(String? videoPath) {
    return deleteByIndexSync(r'videoPath', [videoPath]);
  }

  Future<List<IsarSubtitleSettingsRecord?>> getAllByVideoPath(
      List<String?> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return getAllByIndex(r'videoPath', values);
  }

  List<IsarSubtitleSettingsRecord?> getAllByVideoPathSync(
      List<String?> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'videoPath', values);
  }

  Future<int> deleteAllByVideoPath(List<String?> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'videoPath', values);
  }

  int deleteAllByVideoPathSync(List<String?> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'videoPath', values);
  }

  Future<Id> putByVideoPath(IsarSubtitleSettingsRecord object) {
    return putByIndex(r'videoPath', object);
  }

  Id putByVideoPathSync(IsarSubtitleSettingsRecord object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'videoPath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVideoPath(List<IsarSubtitleSettingsRecord> objects) {
    return putAllByIndex(r'videoPath', objects);
  }

  List<Id> putAllByVideoPathSync(List<IsarSubtitleSettingsRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'videoPath', objects, saveLinks: saveLinks);
  }
}

extension IsarSubtitleSettingsRecordQueryWhereSort on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QWhere> {
  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarSubtitleSettingsRecordQueryWhere on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QWhereClause> {
  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> videoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'videoPath',
        value: [null],
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> videoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'videoPath',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> videoPathEqualTo(String? videoPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'videoPath',
        value: [videoPath],
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterWhereClause> videoPathNotEqualTo(String? videoPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [],
              upper: [videoPath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [videoPath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [videoPath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [],
              upper: [videoPath],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarSubtitleSettingsRecordQueryFilter on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QFilterCondition> {
  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> fontSizeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> fontSizeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> fontSizeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> fontSizeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> isVisibleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isVisible',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> syncOffsetMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncOffsetMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> syncOffsetMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncOffsetMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> syncOffsetMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncOffsetMs',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> syncOffsetMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncOffsetMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'videoPath',
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'videoPath',
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
          QAfterFilterCondition>
      videoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
          QAfterFilterCondition>
      videoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterFilterCondition> videoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoPath',
        value: '',
      ));
    });
  }
}

extension IsarSubtitleSettingsRecordQueryObject on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QFilterCondition> {}

extension IsarSubtitleSettingsRecordQueryLinks on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QFilterCondition> {}

extension IsarSubtitleSettingsRecordQuerySortBy on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QSortBy> {
  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortByIsVisible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortByIsVisibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortBySyncOffsetMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOffsetMs', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortBySyncOffsetMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOffsetMs', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortByVideoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> sortByVideoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.desc);
    });
  }
}

extension IsarSubtitleSettingsRecordQuerySortThenBy on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QSortThenBy> {
  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByIsVisible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByIsVisibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenBySyncOffsetMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOffsetMs', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenBySyncOffsetMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOffsetMs', Sort.desc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByVideoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.asc);
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QAfterSortBy> thenByVideoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.desc);
    });
  }
}

extension IsarSubtitleSettingsRecordQueryWhereDistinct on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QDistinct> {
  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QDistinct> distinctByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSize');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QDistinct> distinctByIsVisible() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isVisible');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QDistinct> distinctBySyncOffsetMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncOffsetMs');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord,
      QDistinct> distinctByVideoPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoPath', caseSensitive: caseSensitive);
    });
  }
}

extension IsarSubtitleSettingsRecordQueryProperty on QueryBuilder<
    IsarSubtitleSettingsRecord, IsarSubtitleSettingsRecord, QQueryProperty> {
  QueryBuilder<IsarSubtitleSettingsRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, double, QQueryOperations>
      fontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSize');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, bool, QQueryOperations>
      isVisibleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isVisible');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, int, QQueryOperations>
      syncOffsetMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncOffsetMs');
    });
  }

  QueryBuilder<IsarSubtitleSettingsRecord, String?, QQueryOperations>
      videoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoPath');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarExternalSubtitleRecordCollection on Isar {
  IsarCollection<IsarExternalSubtitleRecord> get isarExternalSubtitleRecords =>
      this.collection();
}

const IsarExternalSubtitleRecordSchema = CollectionSchema(
  name: r'IsarExternalSubtitleRecord',
  id: -5538061621723091005,
  properties: {
    r'subtitlePath': PropertySchema(
      id: 0,
      name: r'subtitlePath',
      type: IsarType.string,
    ),
    r'videoPath': PropertySchema(
      id: 1,
      name: r'videoPath',
      type: IsarType.string,
    )
  },
  estimateSize: _isarExternalSubtitleRecordEstimateSize,
  serialize: _isarExternalSubtitleRecordSerialize,
  deserialize: _isarExternalSubtitleRecordDeserialize,
  deserializeProp: _isarExternalSubtitleRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'videoPath': IndexSchema(
      id: 8864946403865301343,
      name: r'videoPath',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'videoPath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarExternalSubtitleRecordGetId,
  getLinks: _isarExternalSubtitleRecordGetLinks,
  attach: _isarExternalSubtitleRecordAttach,
  version: '3.1.0+1',
);

int _isarExternalSubtitleRecordEstimateSize(
  IsarExternalSubtitleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subtitlePath.length * 3;
  bytesCount += 3 + object.videoPath.length * 3;
  return bytesCount;
}

void _isarExternalSubtitleRecordSerialize(
  IsarExternalSubtitleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.subtitlePath);
  writer.writeString(offsets[1], object.videoPath);
}

IsarExternalSubtitleRecord _isarExternalSubtitleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarExternalSubtitleRecord();
  object.id = id;
  object.subtitlePath = reader.readString(offsets[0]);
  object.videoPath = reader.readString(offsets[1]);
  return object;
}

P _isarExternalSubtitleRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarExternalSubtitleRecordGetId(IsarExternalSubtitleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarExternalSubtitleRecordGetLinks(
    IsarExternalSubtitleRecord object) {
  return [];
}

void _isarExternalSubtitleRecordAttach(
    IsarCollection<dynamic> col, Id id, IsarExternalSubtitleRecord object) {
  object.id = id;
}

extension IsarExternalSubtitleRecordByIndex
    on IsarCollection<IsarExternalSubtitleRecord> {
  Future<IsarExternalSubtitleRecord?> getByVideoPath(String videoPath) {
    return getByIndex(r'videoPath', [videoPath]);
  }

  IsarExternalSubtitleRecord? getByVideoPathSync(String videoPath) {
    return getByIndexSync(r'videoPath', [videoPath]);
  }

  Future<bool> deleteByVideoPath(String videoPath) {
    return deleteByIndex(r'videoPath', [videoPath]);
  }

  bool deleteByVideoPathSync(String videoPath) {
    return deleteByIndexSync(r'videoPath', [videoPath]);
  }

  Future<List<IsarExternalSubtitleRecord?>> getAllByVideoPath(
      List<String> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return getAllByIndex(r'videoPath', values);
  }

  List<IsarExternalSubtitleRecord?> getAllByVideoPathSync(
      List<String> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'videoPath', values);
  }

  Future<int> deleteAllByVideoPath(List<String> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'videoPath', values);
  }

  int deleteAllByVideoPathSync(List<String> videoPathValues) {
    final values = videoPathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'videoPath', values);
  }

  Future<Id> putByVideoPath(IsarExternalSubtitleRecord object) {
    return putByIndex(r'videoPath', object);
  }

  Id putByVideoPathSync(IsarExternalSubtitleRecord object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'videoPath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVideoPath(List<IsarExternalSubtitleRecord> objects) {
    return putAllByIndex(r'videoPath', objects);
  }

  List<Id> putAllByVideoPathSync(List<IsarExternalSubtitleRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'videoPath', objects, saveLinks: saveLinks);
  }
}

extension IsarExternalSubtitleRecordQueryWhereSort on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QWhere> {
  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarExternalSubtitleRecordQueryWhere on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QWhereClause> {
  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> videoPathEqualTo(String videoPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'videoPath',
        value: [videoPath],
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterWhereClause> videoPathNotEqualTo(String videoPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [],
              upper: [videoPath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [videoPath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [videoPath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'videoPath',
              lower: [],
              upper: [videoPath],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarExternalSubtitleRecordQueryFilter on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QFilterCondition> {
  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitlePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtitlePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtitlePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtitlePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subtitlePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subtitlePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
          QAfterFilterCondition>
      subtitlePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subtitlePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
          QAfterFilterCondition>
      subtitlePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subtitlePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitlePath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> subtitlePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subtitlePath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
          QAfterFilterCondition>
      videoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
          QAfterFilterCondition>
      videoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterFilterCondition> videoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoPath',
        value: '',
      ));
    });
  }
}

extension IsarExternalSubtitleRecordQueryObject on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QFilterCondition> {}

extension IsarExternalSubtitleRecordQueryLinks on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QFilterCondition> {}

extension IsarExternalSubtitleRecordQuerySortBy on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QSortBy> {
  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> sortBySubtitlePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitlePath', Sort.asc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> sortBySubtitlePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitlePath', Sort.desc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> sortByVideoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.asc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> sortByVideoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.desc);
    });
  }
}

extension IsarExternalSubtitleRecordQuerySortThenBy on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QSortThenBy> {
  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> thenBySubtitlePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitlePath', Sort.asc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> thenBySubtitlePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitlePath', Sort.desc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> thenByVideoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.asc);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QAfterSortBy> thenByVideoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.desc);
    });
  }
}

extension IsarExternalSubtitleRecordQueryWhereDistinct on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QDistinct> {
  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QDistinct> distinctBySubtitlePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitlePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, IsarExternalSubtitleRecord,
      QDistinct> distinctByVideoPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoPath', caseSensitive: caseSensitive);
    });
  }
}

extension IsarExternalSubtitleRecordQueryProperty on QueryBuilder<
    IsarExternalSubtitleRecord, IsarExternalSubtitleRecord, QQueryProperty> {
  QueryBuilder<IsarExternalSubtitleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, String, QQueryOperations>
      subtitlePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitlePath');
    });
  }

  QueryBuilder<IsarExternalSubtitleRecord, String, QQueryOperations>
      videoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoPath');
    });
  }
}
