// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserIsarModelCollection on Isar {
  IsarCollection<UserIsarModel> get userIsarModels => this.collection();
}

const UserIsarModelSchema = CollectionSchema(
  name: r'UserIsarModel',
  id: -1977557784589225182,
  properties: {
    r'employeeCode': PropertySchema(
      id: 0,
      name: r'employeeCode',
      type: IsarType.string,
    ),
    r'globalAdmin': PropertySchema(
      id: 1,
      name: r'globalAdmin',
      type: IsarType.bool,
    ),
    r'loginResponseJson': PropertySchema(
      id: 2,
      name: r'loginResponseJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'profile': PropertySchema(id: 4, name: r'profile', type: IsarType.string),
    r'systemToken': PropertySchema(
      id: 5,
      name: r'systemToken',
      type: IsarType.string,
    ),
    r'token': PropertySchema(id: 6, name: r'token', type: IsarType.string),
    r'userGroup': PropertySchema(
      id: 7,
      name: r'userGroup',
      type: IsarType.string,
    ),
    r'username': PropertySchema(
      id: 8,
      name: r'username',
      type: IsarType.string,
    ),
  },

  estimateSize: _userIsarModelEstimateSize,
  serialize: _userIsarModelSerialize,
  deserialize: _userIsarModelDeserialize,
  deserializeProp: _userIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'username': IndexSchema(
      id: -2899563114555695793,
      name: r'username',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'username',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _userIsarModelGetId,
  getLinks: _userIsarModelGetLinks,
  attach: _userIsarModelAttach,
  version: '3.3.2',
);

int _userIsarModelEstimateSize(
  UserIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.employeeCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.loginResponseJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.profile;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.systemToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.token;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userGroup;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.username;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userIsarModelSerialize(
  UserIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.employeeCode);
  writer.writeBool(offsets[1], object.globalAdmin);
  writer.writeString(offsets[2], object.loginResponseJson);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.profile);
  writer.writeString(offsets[5], object.systemToken);
  writer.writeString(offsets[6], object.token);
  writer.writeString(offsets[7], object.userGroup);
  writer.writeString(offsets[8], object.username);
}

UserIsarModel _userIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserIsarModel();
  object.employeeCode = reader.readStringOrNull(offsets[0]);
  object.globalAdmin = reader.readBoolOrNull(offsets[1]);
  object.id = id;
  object.loginResponseJson = reader.readStringOrNull(offsets[2]);
  object.name = reader.readStringOrNull(offsets[3]);
  object.profile = reader.readStringOrNull(offsets[4]);
  object.systemToken = reader.readStringOrNull(offsets[5]);
  object.token = reader.readStringOrNull(offsets[6]);
  object.userGroup = reader.readStringOrNull(offsets[7]);
  object.username = reader.readStringOrNull(offsets[8]);
  return object;
}

P _userIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userIsarModelGetId(UserIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userIsarModelGetLinks(UserIsarModel object) {
  return [];
}

void _userIsarModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserIsarModel object,
) {
  object.id = id;
}

extension UserIsarModelByIndex on IsarCollection<UserIsarModel> {
  Future<UserIsarModel?> getByUsername(String? username) {
    return getByIndex(r'username', [username]);
  }

  UserIsarModel? getByUsernameSync(String? username) {
    return getByIndexSync(r'username', [username]);
  }

  Future<bool> deleteByUsername(String? username) {
    return deleteByIndex(r'username', [username]);
  }

  bool deleteByUsernameSync(String? username) {
    return deleteByIndexSync(r'username', [username]);
  }

  Future<List<UserIsarModel?>> getAllByUsername(List<String?> usernameValues) {
    final values = usernameValues.map((e) => [e]).toList();
    return getAllByIndex(r'username', values);
  }

  List<UserIsarModel?> getAllByUsernameSync(List<String?> usernameValues) {
    final values = usernameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'username', values);
  }

  Future<int> deleteAllByUsername(List<String?> usernameValues) {
    final values = usernameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'username', values);
  }

  int deleteAllByUsernameSync(List<String?> usernameValues) {
    final values = usernameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'username', values);
  }

  Future<Id> putByUsername(UserIsarModel object) {
    return putByIndex(r'username', object);
  }

  Id putByUsernameSync(UserIsarModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'username', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUsername(List<UserIsarModel> objects) {
    return putAllByIndex(r'username', objects);
  }

  List<Id> putAllByUsernameSync(
    List<UserIsarModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'username', objects, saveLinks: saveLinks);
  }
}

extension UserIsarModelQueryWhereSort
    on QueryBuilder<UserIsarModel, UserIsarModel, QWhere> {
  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserIsarModelQueryWhere
    on QueryBuilder<UserIsarModel, UserIsarModel, QWhereClause> {
  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause>
  usernameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'username', value: [null]),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause>
  usernameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'username',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause> usernameEqualTo(
    String? username,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'username', value: [username]),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterWhereClause>
  usernameNotEqualTo(String? username) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'username',
                lower: [],
                upper: [username],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'username',
                lower: [username],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'username',
                lower: [username],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'username',
                lower: [],
                upper: [username],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension UserIsarModelQueryFilter
    on QueryBuilder<UserIsarModel, UserIsarModel, QFilterCondition> {
  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'employeeCode'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'employeeCode'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'employeeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'employeeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'employeeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'employeeCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'employeeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'employeeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'employeeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'employeeCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'employeeCode', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  employeeCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'employeeCode', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  globalAdminIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'globalAdmin'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  globalAdminIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'globalAdmin'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  globalAdminEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'globalAdmin', value: value),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'loginResponseJson'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'loginResponseJson'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'loginResponseJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loginResponseJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loginResponseJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loginResponseJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'loginResponseJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'loginResponseJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'loginResponseJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'loginResponseJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loginResponseJson', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  loginResponseJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'loginResponseJson', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'name'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'name'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'profile'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'profile'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'profile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'profile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'profile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'profile',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'profile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'profile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'profile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'profile',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profile', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  profileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'profile', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'systemToken'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'systemToken'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'systemToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'systemToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'systemToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'systemToken',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'systemToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'systemToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'systemToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'systemToken',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'systemToken', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  systemTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'systemToken', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'token'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'token'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'token',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'token',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'token',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'token',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'token',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'token',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'token',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'token',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'token', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'token', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userGroup'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userGroup'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userGroup',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userGroup',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userGroup',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userGroup',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userGroup',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userGroup',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userGroup',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userGroup',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userGroup', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  userGroupIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userGroup', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'username'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'username'),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'username',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'username',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'username', value: ''),
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterFilterCondition>
  usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'username', value: ''),
      );
    });
  }
}

extension UserIsarModelQueryObject
    on QueryBuilder<UserIsarModel, UserIsarModel, QFilterCondition> {}

extension UserIsarModelQueryLinks
    on QueryBuilder<UserIsarModel, UserIsarModel, QFilterCondition> {}

extension UserIsarModelQuerySortBy
    on QueryBuilder<UserIsarModel, UserIsarModel, QSortBy> {
  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByEmployeeCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeCode', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByEmployeeCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeCode', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByGlobalAdmin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalAdmin', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByGlobalAdminDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalAdmin', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByLoginResponseJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginResponseJson', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByLoginResponseJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginResponseJson', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByProfile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profile', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByProfileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profile', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortBySystemToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemToken', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortBySystemTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemToken', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByUserGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userGroup', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByUserGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userGroup', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension UserIsarModelQuerySortThenBy
    on QueryBuilder<UserIsarModel, UserIsarModel, QSortThenBy> {
  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByEmployeeCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeCode', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByEmployeeCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeCode', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByGlobalAdmin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalAdmin', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByGlobalAdminDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalAdmin', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByLoginResponseJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginResponseJson', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByLoginResponseJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginResponseJson', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByProfile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profile', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByProfileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profile', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenBySystemToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemToken', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenBySystemTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemToken', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByUserGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userGroup', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByUserGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userGroup', Sort.desc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QAfterSortBy>
  thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension UserIsarModelQueryWhereDistinct
    on QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> {
  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctByEmployeeCode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct>
  distinctByGlobalAdmin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'globalAdmin');
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct>
  distinctByLoginResponseJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'loginResponseJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctByProfile({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profile', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctBySystemToken({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'systemToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctByToken({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctByUserGroup({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userGroup', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserIsarModel, UserIsarModel, QDistinct> distinctByUsername({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }
}

extension UserIsarModelQueryProperty
    on QueryBuilder<UserIsarModel, UserIsarModel, QQueryProperty> {
  QueryBuilder<UserIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations>
  employeeCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeCode');
    });
  }

  QueryBuilder<UserIsarModel, bool?, QQueryOperations> globalAdminProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'globalAdmin');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations>
  loginResponseJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginResponseJson');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations> profileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profile');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations> systemTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'systemToken');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations> userGroupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userGroup');
    });
  }

  QueryBuilder<UserIsarModel, String?, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }
}
