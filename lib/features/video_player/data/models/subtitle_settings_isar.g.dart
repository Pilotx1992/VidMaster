// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_settings_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubtitleSettingsIsarCollection on Isar {
  IsarCollection<SubtitleSettingsIsar> get subtitleSettingsIsars =>
      this.collection();
}

const SubtitleSettingsIsarSchema = CollectionSchema(
  name: r'SubtitleSettingsIsar',
  id: 5422874834620323870,
  properties: {
    r'backgroundColorValue': PropertySchema(
      id: 0,
      name: r'backgroundColorValue',
      type: IsarType.long,
    ),
    r'backgroundOpacity': PropertySchema(
      id: 1,
      name: r'backgroundOpacity',
      type: IsarType.double,
    ),
    r'externalTrackPath': PropertySchema(
      id: 2,
      name: r'externalTrackPath',
      type: IsarType.string,
    ),
    r'fontSizeIndex': PropertySchema(
      id: 3,
      name: r'fontSizeIndex',
      type: IsarType.long,
    ),
    r'fontStyleIndex': PropertySchema(
      id: 4,
      name: r'fontStyleIndex',
      type: IsarType.long,
    ),
    r'textColorValue': PropertySchema(
      id: 5,
      name: r'textColorValue',
      type: IsarType.long,
    )
  },
  estimateSize: _subtitleSettingsIsarEstimateSize,
  serialize: _subtitleSettingsIsarSerialize,
  deserialize: _subtitleSettingsIsarDeserialize,
  deserializeProp: _subtitleSettingsIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _subtitleSettingsIsarGetId,
  getLinks: _subtitleSettingsIsarGetLinks,
  attach: _subtitleSettingsIsarAttach,
  version: '3.1.0+1',
);

int _subtitleSettingsIsarEstimateSize(
  SubtitleSettingsIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.externalTrackPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _subtitleSettingsIsarSerialize(
  SubtitleSettingsIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.backgroundColorValue);
  writer.writeDouble(offsets[1], object.backgroundOpacity);
  writer.writeString(offsets[2], object.externalTrackPath);
  writer.writeLong(offsets[3], object.fontSizeIndex);
  writer.writeLong(offsets[4], object.fontStyleIndex);
  writer.writeLong(offsets[5], object.textColorValue);
}

SubtitleSettingsIsar _subtitleSettingsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubtitleSettingsIsar();
  object.backgroundColorValue = reader.readLong(offsets[0]);
  object.backgroundOpacity = reader.readDouble(offsets[1]);
  object.externalTrackPath = reader.readStringOrNull(offsets[2]);
  object.fontSizeIndex = reader.readLong(offsets[3]);
  object.fontStyleIndex = reader.readLong(offsets[4]);
  object.id = id;
  object.textColorValue = reader.readLong(offsets[5]);
  return object;
}

P _subtitleSettingsIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subtitleSettingsIsarGetId(SubtitleSettingsIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subtitleSettingsIsarGetLinks(
    SubtitleSettingsIsar object) {
  return [];
}

void _subtitleSettingsIsarAttach(
    IsarCollection<dynamic> col, Id id, SubtitleSettingsIsar object) {
  object.id = id;
}

extension SubtitleSettingsIsarQueryWhereSort
    on QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QWhere> {
  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubtitleSettingsIsarQueryWhere
    on QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QWhereClause> {
  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterWhereClause>
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

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterWhereClause>
      idBetween(
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
}

extension SubtitleSettingsIsarQueryFilter on QueryBuilder<SubtitleSettingsIsar,
    SubtitleSettingsIsar, QFilterCondition> {
  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundColorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundColorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundColorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundOpacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundOpacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundOpacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> backgroundOpacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundOpacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'externalTrackPath',
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'externalTrackPath',
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalTrackPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'externalTrackPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'externalTrackPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'externalTrackPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'externalTrackPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'externalTrackPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
          QAfterFilterCondition>
      externalTrackPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'externalTrackPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
          QAfterFilterCondition>
      externalTrackPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'externalTrackPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalTrackPath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> externalTrackPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'externalTrackPath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontSizeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSizeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontSizeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSizeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontSizeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSizeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontSizeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSizeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontStyleIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontStyleIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontStyleIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontStyleIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontStyleIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontStyleIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> fontStyleIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontStyleIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
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

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
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

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
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

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> textColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> textColorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> textColorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar,
      QAfterFilterCondition> textColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textColorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubtitleSettingsIsarQueryObject on QueryBuilder<SubtitleSettingsIsar,
    SubtitleSettingsIsar, QFilterCondition> {}

extension SubtitleSettingsIsarQueryLinks on QueryBuilder<SubtitleSettingsIsar,
    SubtitleSettingsIsar, QFilterCondition> {}

extension SubtitleSettingsIsarQuerySortBy
    on QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QSortBy> {
  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByBackgroundColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByBackgroundOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundOpacity', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByBackgroundOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundOpacity', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByExternalTrackPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalTrackPath', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByExternalTrackPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalTrackPath', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByFontSizeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeIndex', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByFontSizeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeIndex', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByFontStyleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyleIndex', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByFontStyleIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyleIndex', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByTextColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      sortByTextColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.desc);
    });
  }
}

extension SubtitleSettingsIsarQuerySortThenBy
    on QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QSortThenBy> {
  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByBackgroundColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByBackgroundOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundOpacity', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByBackgroundOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundOpacity', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByExternalTrackPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalTrackPath', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByExternalTrackPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalTrackPath', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByFontSizeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeIndex', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByFontSizeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeIndex', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByFontStyleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyleIndex', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByFontStyleIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyleIndex', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByTextColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.asc);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QAfterSortBy>
      thenByTextColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.desc);
    });
  }
}

extension SubtitleSettingsIsarQueryWhereDistinct
    on QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct> {
  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct>
      distinctByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundColorValue');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct>
      distinctByBackgroundOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundOpacity');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct>
      distinctByExternalTrackPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalTrackPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct>
      distinctByFontSizeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSizeIndex');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct>
      distinctByFontStyleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontStyleIndex');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, SubtitleSettingsIsar, QDistinct>
      distinctByTextColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textColorValue');
    });
  }
}

extension SubtitleSettingsIsarQueryProperty on QueryBuilder<
    SubtitleSettingsIsar, SubtitleSettingsIsar, QQueryProperty> {
  QueryBuilder<SubtitleSettingsIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, int, QQueryOperations>
      backgroundColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundColorValue');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, double, QQueryOperations>
      backgroundOpacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundOpacity');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, String?, QQueryOperations>
      externalTrackPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalTrackPath');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, int, QQueryOperations>
      fontSizeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSizeIndex');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, int, QQueryOperations>
      fontStyleIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontStyleIndex');
    });
  }

  QueryBuilder<SubtitleSettingsIsar, int, QQueryOperations>
      textColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textColorValue');
    });
  }
}
