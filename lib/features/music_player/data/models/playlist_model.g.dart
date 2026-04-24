// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaylistModelCollection on Isar {
  IsarCollection<PlaylistModel> get playlistModels => this.collection();
}

const PlaylistModelSchema = CollectionSchema(
  name: r'PlaylistModel',
  id: -3528207141634668389,
  properties: {
    r'coverArtPath': PropertySchema(
      id: 0,
      name: r'coverArtPath',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'playlistId': PropertySchema(
      id: 3,
      name: r'playlistId',
      type: IsarType.string,
    ),
    r'trackIds': PropertySchema(
      id: 4,
      name: r'trackIds',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _playlistModelEstimateSize,
  serialize: _playlistModelSerialize,
  deserialize: _playlistModelDeserialize,
  deserializeProp: _playlistModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'playlistId': IndexSchema(
      id: 7921918076105486368,
      name: r'playlistId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'playlistId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _playlistModelGetId,
  getLinks: _playlistModelGetLinks,
  attach: _playlistModelAttach,
  version: '3.1.0+1',
);

int _playlistModelEstimateSize(
  PlaylistModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.coverArtPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.playlistId.length * 3;
  bytesCount += 3 + object.trackIds.length * 3;
  {
    for (var i = 0; i < object.trackIds.length; i++) {
      final value = object.trackIds[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _playlistModelSerialize(
  PlaylistModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.coverArtPath);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.playlistId);
  writer.writeStringList(offsets[4], object.trackIds);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

PlaylistModel _playlistModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaylistModel(
    coverArtPath: reader.readStringOrNull(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    name: reader.readString(offsets[2]),
    playlistId: reader.readString(offsets[3]),
    trackIds: reader.readStringList(offsets[4]) ?? [],
    updatedAt: reader.readDateTime(offsets[5]),
  );
  return object;
}

P _playlistModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playlistModelGetId(PlaylistModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playlistModelGetLinks(PlaylistModel object) {
  return [];
}

void _playlistModelAttach(
    IsarCollection<dynamic> col, Id id, PlaylistModel object) {}

extension PlaylistModelByIndex on IsarCollection<PlaylistModel> {
  Future<PlaylistModel?> getByPlaylistId(String playlistId) {
    return getByIndex(r'playlistId', [playlistId]);
  }

  PlaylistModel? getByPlaylistIdSync(String playlistId) {
    return getByIndexSync(r'playlistId', [playlistId]);
  }

  Future<bool> deleteByPlaylistId(String playlistId) {
    return deleteByIndex(r'playlistId', [playlistId]);
  }

  bool deleteByPlaylistIdSync(String playlistId) {
    return deleteByIndexSync(r'playlistId', [playlistId]);
  }

  Future<List<PlaylistModel?>> getAllByPlaylistId(
      List<String> playlistIdValues) {
    final values = playlistIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'playlistId', values);
  }

  List<PlaylistModel?> getAllByPlaylistIdSync(List<String> playlistIdValues) {
    final values = playlistIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'playlistId', values);
  }

  Future<int> deleteAllByPlaylistId(List<String> playlistIdValues) {
    final values = playlistIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'playlistId', values);
  }

  int deleteAllByPlaylistIdSync(List<String> playlistIdValues) {
    final values = playlistIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'playlistId', values);
  }

  Future<Id> putByPlaylistId(PlaylistModel object) {
    return putByIndex(r'playlistId', object);
  }

  Id putByPlaylistIdSync(PlaylistModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'playlistId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPlaylistId(List<PlaylistModel> objects) {
    return putAllByIndex(r'playlistId', objects);
  }

  List<Id> putAllByPlaylistIdSync(List<PlaylistModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'playlistId', objects, saveLinks: saveLinks);
  }
}

extension PlaylistModelQueryWhereSort
    on QueryBuilder<PlaylistModel, PlaylistModel, QWhere> {
  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaylistModelQueryWhere
    on QueryBuilder<PlaylistModel, PlaylistModel, QWhereClause> {
  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause>
      playlistIdEqualTo(String playlistId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'playlistId',
        value: [playlistId],
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterWhereClause>
      playlistIdNotEqualTo(String playlistId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [],
              upper: [playlistId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [playlistId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [playlistId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [],
              upper: [playlistId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlaylistModelQueryFilter
    on QueryBuilder<PlaylistModel, PlaylistModel, QFilterCondition> {
  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverArtPath',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverArtPath',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverArtPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverArtPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverArtPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverArtPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverArtPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverArtPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverArtPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverArtPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverArtPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      coverArtPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverArtPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
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

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      playlistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trackIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackIds',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackIds',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      trackIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlaylistModelQueryObject
    on QueryBuilder<PlaylistModel, PlaylistModel, QFilterCondition> {}

extension PlaylistModelQueryLinks
    on QueryBuilder<PlaylistModel, PlaylistModel, QFilterCondition> {}

extension PlaylistModelQuerySortBy
    on QueryBuilder<PlaylistModel, PlaylistModel, QSortBy> {
  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      sortByCoverArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArtPath', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      sortByCoverArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArtPath', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PlaylistModelQuerySortThenBy
    on QueryBuilder<PlaylistModel, PlaylistModel, QSortThenBy> {
  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      thenByCoverArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArtPath', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      thenByCoverArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArtPath', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PlaylistModelQueryWhereDistinct
    on QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> {
  QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> distinctByCoverArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverArtPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> distinctByPlaylistId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> distinctByTrackIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackIds');
    });
  }

  QueryBuilder<PlaylistModel, PlaylistModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PlaylistModelQueryProperty
    on QueryBuilder<PlaylistModel, PlaylistModel, QQueryProperty> {
  QueryBuilder<PlaylistModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlaylistModel, String?, QQueryOperations>
      coverArtPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverArtPath');
    });
  }

  QueryBuilder<PlaylistModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PlaylistModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<PlaylistModel, String, QQueryOperations> playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
    });
  }

  QueryBuilder<PlaylistModel, List<String>, QQueryOperations>
      trackIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackIds');
    });
  }

  QueryBuilder<PlaylistModel, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
