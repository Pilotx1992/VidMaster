// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDownloadTaskModelCollection on Isar {
  IsarCollection<DownloadTaskModel> get downloadTaskModels => this.collection();
}

const DownloadTaskModelSchema = CollectionSchema(
  name: r'DownloadTaskModel',
  id: 1668844351718852422,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'downloadedBytes': PropertySchema(
      id: 2,
      name: r'downloadedBytes',
      type: IsarType.long,
    ),
    r'errorMessage': PropertySchema(
      id: 3,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 4,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'progressPercent': PropertySchema(
      id: 5,
      name: r'progressPercent',
      type: IsarType.long,
    ),
    r'saveDirectory': PropertySchema(
      id: 6,
      name: r'saveDirectory',
      type: IsarType.string,
    ),
    r'speedBytesPerSec': PropertySchema(
      id: 7,
      name: r'speedBytesPerSec',
      type: IsarType.long,
    ),
    r'statusIndex': PropertySchema(
      id: 8,
      name: r'statusIndex',
      type: IsarType.long,
    ),
    r'taskId': PropertySchema(
      id: 9,
      name: r'taskId',
      type: IsarType.string,
    ),
    r'totalBytes': PropertySchema(
      id: 10,
      name: r'totalBytes',
      type: IsarType.long,
    ),
    r'url': PropertySchema(
      id: 11,
      name: r'url',
      type: IsarType.string,
    ),
    r'wifiOnly': PropertySchema(
      id: 12,
      name: r'wifiOnly',
      type: IsarType.bool,
    )
  },
  estimateSize: _downloadTaskModelEstimateSize,
  serialize: _downloadTaskModelSerialize,
  deserialize: _downloadTaskModelDeserialize,
  deserializeProp: _downloadTaskModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'taskId': IndexSchema(
      id: -6391211041487498726,
      name: r'taskId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'taskId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _downloadTaskModelGetId,
  getLinks: _downloadTaskModelGetLinks,
  attach: _downloadTaskModelAttach,
  version: '3.1.0+1',
);

int _downloadTaskModelEstimateSize(
  DownloadTaskModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.saveDirectory.length * 3;
  bytesCount += 3 + object.taskId.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _downloadTaskModelSerialize(
  DownloadTaskModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.downloadedBytes);
  writer.writeString(offsets[3], object.errorMessage);
  writer.writeString(offsets[4], object.fileName);
  writer.writeLong(offsets[5], object.progressPercent);
  writer.writeString(offsets[6], object.saveDirectory);
  writer.writeLong(offsets[7], object.speedBytesPerSec);
  writer.writeLong(offsets[8], object.statusIndex);
  writer.writeString(offsets[9], object.taskId);
  writer.writeLong(offsets[10], object.totalBytes);
  writer.writeString(offsets[11], object.url);
  writer.writeBool(offsets[12], object.wifiOnly);
}

DownloadTaskModel _downloadTaskModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DownloadTaskModel(
    completedAt: reader.readDateTimeOrNull(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    downloadedBytes: reader.readLongOrNull(offsets[2]) ?? 0,
    errorMessage: reader.readStringOrNull(offsets[3]),
    fileName: reader.readString(offsets[4]),
    progressPercent: reader.readLongOrNull(offsets[5]) ?? 0,
    saveDirectory: reader.readString(offsets[6]),
    speedBytesPerSec: reader.readLongOrNull(offsets[7]),
    statusIndex: reader.readLong(offsets[8]),
    taskId: reader.readString(offsets[9]),
    totalBytes: reader.readLongOrNull(offsets[10]),
    url: reader.readString(offsets[11]),
    wifiOnly: reader.readBoolOrNull(offsets[12]) ?? false,
  );
  return object;
}

P _downloadTaskModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _downloadTaskModelGetId(DownloadTaskModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _downloadTaskModelGetLinks(
    DownloadTaskModel object) {
  return [];
}

void _downloadTaskModelAttach(
    IsarCollection<dynamic> col, Id id, DownloadTaskModel object) {}

extension DownloadTaskModelByIndex on IsarCollection<DownloadTaskModel> {
  Future<DownloadTaskModel?> getByTaskId(String taskId) {
    return getByIndex(r'taskId', [taskId]);
  }

  DownloadTaskModel? getByTaskIdSync(String taskId) {
    return getByIndexSync(r'taskId', [taskId]);
  }

  Future<bool> deleteByTaskId(String taskId) {
    return deleteByIndex(r'taskId', [taskId]);
  }

  bool deleteByTaskIdSync(String taskId) {
    return deleteByIndexSync(r'taskId', [taskId]);
  }

  Future<List<DownloadTaskModel?>> getAllByTaskId(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'taskId', values);
  }

  List<DownloadTaskModel?> getAllByTaskIdSync(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'taskId', values);
  }

  Future<int> deleteAllByTaskId(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'taskId', values);
  }

  int deleteAllByTaskIdSync(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'taskId', values);
  }

  Future<Id> putByTaskId(DownloadTaskModel object) {
    return putByIndex(r'taskId', object);
  }

  Id putByTaskIdSync(DownloadTaskModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'taskId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTaskId(List<DownloadTaskModel> objects) {
    return putAllByIndex(r'taskId', objects);
  }

  List<Id> putAllByTaskIdSync(List<DownloadTaskModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'taskId', objects, saveLinks: saveLinks);
  }
}

extension DownloadTaskModelQueryWhereSort
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QWhere> {
  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DownloadTaskModelQueryWhere
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QWhereClause> {
  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
      taskIdEqualTo(String taskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskId',
        value: [taskId],
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterWhereClause>
      taskIdNotEqualTo(String taskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DownloadTaskModelQueryFilter
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QFilterCondition> {
  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      downloadedBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadedBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      downloadedBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadedBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      downloadedBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadedBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      downloadedBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadedBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameEqualTo(
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameLessThan(
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameBetween(
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameEndsWith(
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
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

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      progressPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      progressPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      progressPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      progressPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveDirectory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saveDirectory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saveDirectory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saveDirectory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'saveDirectory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'saveDirectory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saveDirectory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saveDirectory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveDirectory',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      saveDirectoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saveDirectory',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      speedBytesPerSecIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'speedBytesPerSec',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      speedBytesPerSecIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'speedBytesPerSec',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      speedBytesPerSecEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedBytesPerSec',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      speedBytesPerSecGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedBytesPerSec',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      speedBytesPerSecLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedBytesPerSec',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      speedBytesPerSecBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedBytesPerSec',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      statusIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      statusIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      statusIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      statusIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      totalBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalBytes',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      totalBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalBytes',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      totalBytesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      totalBytesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      totalBytesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      totalBytesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterFilterCondition>
      wifiOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wifiOnly',
        value: value,
      ));
    });
  }
}

extension DownloadTaskModelQueryObject
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QFilterCondition> {}

extension DownloadTaskModelQueryLinks
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QFilterCondition> {}

extension DownloadTaskModelQuerySortBy
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QSortBy> {
  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByDownloadedBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedBytes', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByDownloadedBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedBytes', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByProgressPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByProgressPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortBySaveDirectory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDirectory', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortBySaveDirectoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDirectory', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortBySpeedBytesPerSec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedBytesPerSec', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortBySpeedBytesPerSecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedBytesPerSec', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByStatusIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByStatusIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByTotalBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByWifiOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wifiOnly', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      sortByWifiOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wifiOnly', Sort.desc);
    });
  }
}

extension DownloadTaskModelQuerySortThenBy
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QSortThenBy> {
  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByDownloadedBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedBytes', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByDownloadedBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedBytes', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByProgressPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByProgressPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenBySaveDirectory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDirectory', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenBySaveDirectoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDirectory', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenBySpeedBytesPerSec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedBytesPerSec', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenBySpeedBytesPerSecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedBytesPerSec', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByStatusIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByStatusIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByTotalBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByWifiOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wifiOnly', Sort.asc);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QAfterSortBy>
      thenByWifiOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wifiOnly', Sort.desc);
    });
  }
}

extension DownloadTaskModelQueryWhereDistinct
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct> {
  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByDownloadedBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadedBytes');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByProgressPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressPercent');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctBySaveDirectory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveDirectory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctBySpeedBytesPerSec() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedBytesPerSec');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByStatusIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusIndex');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByTaskId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBytes');
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadTaskModel, DownloadTaskModel, QDistinct>
      distinctByWifiOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wifiOnly');
    });
  }
}

extension DownloadTaskModelQueryProperty
    on QueryBuilder<DownloadTaskModel, DownloadTaskModel, QQueryProperty> {
  QueryBuilder<DownloadTaskModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DownloadTaskModel, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<DownloadTaskModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DownloadTaskModel, int, QQueryOperations>
      downloadedBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadedBytes');
    });
  }

  QueryBuilder<DownloadTaskModel, String?, QQueryOperations>
      errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<DownloadTaskModel, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<DownloadTaskModel, int, QQueryOperations>
      progressPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressPercent');
    });
  }

  QueryBuilder<DownloadTaskModel, String, QQueryOperations>
      saveDirectoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveDirectory');
    });
  }

  QueryBuilder<DownloadTaskModel, int?, QQueryOperations>
      speedBytesPerSecProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedBytesPerSec');
    });
  }

  QueryBuilder<DownloadTaskModel, int, QQueryOperations> statusIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusIndex');
    });
  }

  QueryBuilder<DownloadTaskModel, String, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }

  QueryBuilder<DownloadTaskModel, int?, QQueryOperations> totalBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBytes');
    });
  }

  QueryBuilder<DownloadTaskModel, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<DownloadTaskModel, bool, QQueryOperations> wifiOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wifiOnly');
    });
  }
}
