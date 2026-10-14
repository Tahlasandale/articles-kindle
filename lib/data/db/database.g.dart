// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArticlesTable extends Articles
    with TableInfo<$ArticlesTable, ArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteUrlMeta = const VerificationMeta(
    'siteUrl',
  );
  @override
  late final GeneratedColumn<String> siteUrl = GeneratedColumn<String>(
    'site_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHtmlMeta = const VerificationMeta(
    'contentHtml',
  );
  @override
  late final GeneratedColumn<String> contentHtml = GeneratedColumn<String>(
    'content_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentSourceMeta = const VerificationMeta(
    'contentSource',
  );
  @override
  late final GeneratedColumn<String> contentSource = GeneratedColumn<String>(
    'content_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedMeta = const VerificationMeta(
    'selected',
  );
  @override
  late final GeneratedColumn<bool> selected = GeneratedColumn<bool>(
    'selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("selected" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    author,
    siteName,
    siteUrl,
    publishedAt,
    origin,
    status,
    error,
    contentHtml,
    contentSource,
    createdAt,
    sentAt,
    selected,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    }
    if (data.containsKey('site_url')) {
      context.handle(
        _siteUrlMeta,
        siteUrl.isAcceptableOrUnknown(data['site_url']!, _siteUrlMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('content_html')) {
      context.handle(
        _contentHtmlMeta,
        contentHtml.isAcceptableOrUnknown(
          data['content_html']!,
          _contentHtmlMeta,
        ),
      );
    }
    if (data.containsKey('content_source')) {
      context.handle(
        _contentSourceMeta,
        contentSource.isAcceptableOrUnknown(
          data['content_source']!,
          _contentSourceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('selected')) {
      context.handle(
        _selectedMeta,
        selected.isAcceptableOrUnknown(data['selected']!, _selectedMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      ),
      siteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_url'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      contentHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_html'],
      ),
      contentSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_source'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
      selected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}selected'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class ArticleRow extends DataClass implements Insertable<ArticleRow> {
  final int id;
  final String url;
  final String? title;
  final String? author;
  final String? siteName;
  final String? siteUrl;
  final DateTime? publishedAt;
  final String origin;
  final String status;
  final String? error;

  /// XHTML nettoyé, prêt à entrer dans un chapitre.
  final String? contentHtml;
  final String? contentSource;
  final DateTime createdAt;
  final DateTime? sentAt;

  /// Coché pour le prochain envoi.
  final bool selected;

  /// Ordre choisi à la main dans l'écran d'envoi.
  final int sortIndex;
  const ArticleRow({
    required this.id,
    required this.url,
    this.title,
    this.author,
    this.siteName,
    this.siteUrl,
    this.publishedAt,
    required this.origin,
    required this.status,
    this.error,
    this.contentHtml,
    this.contentSource,
    required this.createdAt,
    this.sentAt,
    required this.selected,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || siteName != null) {
      map['site_name'] = Variable<String>(siteName);
    }
    if (!nullToAbsent || siteUrl != null) {
      map['site_url'] = Variable<String>(siteUrl);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['origin'] = Variable<String>(origin);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || contentHtml != null) {
      map['content_html'] = Variable<String>(contentHtml);
    }
    if (!nullToAbsent || contentSource != null) {
      map['content_source'] = Variable<String>(contentSource);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    map['selected'] = Variable<bool>(selected);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      url: Value(url),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      siteName: siteName == null && nullToAbsent
          ? const Value.absent()
          : Value(siteName),
      siteUrl: siteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(siteUrl),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      origin: Value(origin),
      status: Value(status),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      contentHtml: contentHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHtml),
      contentSource: contentSource == null && nullToAbsent
          ? const Value.absent()
          : Value(contentSource),
      createdAt: Value(createdAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      selected: Value(selected),
      sortIndex: Value(sortIndex),
    );
  }

  factory ArticleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleRow(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      siteName: serializer.fromJson<String?>(json['siteName']),
      siteUrl: serializer.fromJson<String?>(json['siteUrl']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      origin: serializer.fromJson<String>(json['origin']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      contentHtml: serializer.fromJson<String?>(json['contentHtml']),
      contentSource: serializer.fromJson<String?>(json['contentSource']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      selected: serializer.fromJson<bool>(json['selected']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String?>(title),
      'author': serializer.toJson<String?>(author),
      'siteName': serializer.toJson<String?>(siteName),
      'siteUrl': serializer.toJson<String?>(siteUrl),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'origin': serializer.toJson<String>(origin),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'contentHtml': serializer.toJson<String?>(contentHtml),
      'contentSource': serializer.toJson<String?>(contentSource),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'selected': serializer.toJson<bool>(selected),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  ArticleRow copyWith({
    int? id,
    String? url,
    Value<String?> title = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> siteName = const Value.absent(),
    Value<String?> siteUrl = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
    String? origin,
    String? status,
    Value<String?> error = const Value.absent(),
    Value<String?> contentHtml = const Value.absent(),
    Value<String?> contentSource = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> sentAt = const Value.absent(),
    bool? selected,
    int? sortIndex,
  }) => ArticleRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    author: author.present ? author.value : this.author,
    siteName: siteName.present ? siteName.value : this.siteName,
    siteUrl: siteUrl.present ? siteUrl.value : this.siteUrl,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    origin: origin ?? this.origin,
    status: status ?? this.status,
    error: error.present ? error.value : this.error,
    contentHtml: contentHtml.present ? contentHtml.value : this.contentHtml,
    contentSource: contentSource.present
        ? contentSource.value
        : this.contentSource,
    createdAt: createdAt ?? this.createdAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    selected: selected ?? this.selected,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  ArticleRow copyWithCompanion(ArticlesCompanion data) {
    return ArticleRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      siteUrl: data.siteUrl.present ? data.siteUrl.value : this.siteUrl,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      contentHtml: data.contentHtml.present
          ? data.contentHtml.value
          : this.contentHtml,
      contentSource: data.contentSource.present
          ? data.contentSource.value
          : this.contentSource,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      selected: data.selected.present ? data.selected.value : this.selected,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('siteName: $siteName, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('origin: $origin, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('contentSource: $contentSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('selected: $selected, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    author,
    siteName,
    siteUrl,
    publishedAt,
    origin,
    status,
    error,
    contentHtml,
    contentSource,
    createdAt,
    sentAt,
    selected,
    sortIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.author == this.author &&
          other.siteName == this.siteName &&
          other.siteUrl == this.siteUrl &&
          other.publishedAt == this.publishedAt &&
          other.origin == this.origin &&
          other.status == this.status &&
          other.error == this.error &&
          other.contentHtml == this.contentHtml &&
          other.contentSource == this.contentSource &&
          other.createdAt == this.createdAt &&
          other.sentAt == this.sentAt &&
          other.selected == this.selected &&
          other.sortIndex == this.sortIndex);
}

class ArticlesCompanion extends UpdateCompanion<ArticleRow> {
  final Value<int> id;
  final Value<String> url;
  final Value<String?> title;
  final Value<String?> author;
  final Value<String?> siteName;
  final Value<String?> siteUrl;
  final Value<DateTime?> publishedAt;
  final Value<String> origin;
  final Value<String> status;
  final Value<String?> error;
  final Value<String?> contentHtml;
  final Value<String?> contentSource;
  final Value<DateTime> createdAt;
  final Value<DateTime?> sentAt;
  final Value<bool> selected;
  final Value<int> sortIndex;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.siteName = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.contentSource = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.selected = const Value.absent(),
    this.sortIndex = const Value.absent(),
  });
  ArticlesCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.siteName = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.contentSource = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.selected = const Value.absent(),
    this.sortIndex = const Value.absent(),
  }) : url = Value(url);
  static Insertable<ArticleRow> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? siteName,
    Expression<String>? siteUrl,
    Expression<DateTime>? publishedAt,
    Expression<String>? origin,
    Expression<String>? status,
    Expression<String>? error,
    Expression<String>? contentHtml,
    Expression<String>? contentSource,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? sentAt,
    Expression<bool>? selected,
    Expression<int>? sortIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (siteName != null) 'site_name': siteName,
      if (siteUrl != null) 'site_url': siteUrl,
      if (publishedAt != null) 'published_at': publishedAt,
      if (origin != null) 'origin': origin,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (contentHtml != null) 'content_html': contentHtml,
      if (contentSource != null) 'content_source': contentSource,
      if (createdAt != null) 'created_at': createdAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (selected != null) 'selected': selected,
      if (sortIndex != null) 'sort_index': sortIndex,
    });
  }

  ArticlesCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String?>? title,
    Value<String?>? author,
    Value<String?>? siteName,
    Value<String?>? siteUrl,
    Value<DateTime?>? publishedAt,
    Value<String>? origin,
    Value<String>? status,
    Value<String?>? error,
    Value<String?>? contentHtml,
    Value<String?>? contentSource,
    Value<DateTime>? createdAt,
    Value<DateTime?>? sentAt,
    Value<bool>? selected,
    Value<int>? sortIndex,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      author: author ?? this.author,
      siteName: siteName ?? this.siteName,
      siteUrl: siteUrl ?? this.siteUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      origin: origin ?? this.origin,
      status: status ?? this.status,
      error: error ?? this.error,
      contentHtml: contentHtml ?? this.contentHtml,
      contentSource: contentSource ?? this.contentSource,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      selected: selected ?? this.selected,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (siteUrl.present) {
      map['site_url'] = Variable<String>(siteUrl.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (contentHtml.present) {
      map['content_html'] = Variable<String>(contentHtml.value);
    }
    if (contentSource.present) {
      map['content_source'] = Variable<String>(contentSource.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (selected.present) {
      map['selected'] = Variable<bool>(selected.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('siteName: $siteName, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('origin: $origin, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('contentSource: $contentSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('selected: $selected, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final int id;
  final String name;
  const TagRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TagRow copyWith({int? id, String? name}) =>
      TagRow(id: id ?? this.id, name: name ?? this.name);
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<TagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ArticleTagsTable extends ArticleTags
    with TableInfo<$ArticleTagsTable, ArticleTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticleTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<int> articleId = GeneratedColumn<int>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [articleId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {articleId, tagId};
  @override
  ArticleTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleTagRow(
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}article_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ArticleTagsTable createAlias(String alias) {
    return $ArticleTagsTable(attachedDatabase, alias);
  }
}

class ArticleTagRow extends DataClass implements Insertable<ArticleTagRow> {
  final int articleId;
  final int tagId;
  const ArticleTagRow({required this.articleId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['article_id'] = Variable<int>(articleId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  ArticleTagsCompanion toCompanion(bool nullToAbsent) {
    return ArticleTagsCompanion(
      articleId: Value(articleId),
      tagId: Value(tagId),
    );
  }

  factory ArticleTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleTagRow(
      articleId: serializer.fromJson<int>(json['articleId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'articleId': serializer.toJson<int>(articleId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  ArticleTagRow copyWith({int? articleId, int? tagId}) => ArticleTagRow(
    articleId: articleId ?? this.articleId,
    tagId: tagId ?? this.tagId,
  );
  ArticleTagRow copyWithCompanion(ArticleTagsCompanion data) {
    return ArticleTagRow(
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleTagRow(')
          ..write('articleId: $articleId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(articleId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleTagRow &&
          other.articleId == this.articleId &&
          other.tagId == this.tagId);
}

class ArticleTagsCompanion extends UpdateCompanion<ArticleTagRow> {
  final Value<int> articleId;
  final Value<int> tagId;
  final Value<int> rowid;
  const ArticleTagsCompanion({
    this.articleId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticleTagsCompanion.insert({
    required int articleId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : articleId = Value(articleId),
       tagId = Value(tagId);
  static Insertable<ArticleTagRow> custom({
    Expression<int>? articleId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (articleId != null) 'article_id': articleId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticleTagsCompanion copyWith({
    Value<int>? articleId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return ArticleTagsCompanion(
      articleId: articleId ?? this.articleId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (articleId.present) {
      map['article_id'] = Variable<int>(articleId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleTagsCompanion(')
          ..write('articleId: $articleId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticleImagesTable extends ArticleImages
    with TableInfo<$ArticleImagesTable, ArticleImageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticleImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<int> articleId = GeneratedColumn<int>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    articleId,
    sourceUrl,
    localPath,
    mimeType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleImageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleImageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleImageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}article_id'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
    );
  }

  @override
  $ArticleImagesTable createAlias(String alias) {
    return $ArticleImagesTable(attachedDatabase, alias);
  }
}

class ArticleImageRow extends DataClass implements Insertable<ArticleImageRow> {
  final int id;
  final int articleId;
  final String sourceUrl;
  final String localPath;
  final String? mimeType;
  const ArticleImageRow({
    required this.id,
    required this.articleId,
    required this.sourceUrl,
    required this.localPath,
    this.mimeType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['article_id'] = Variable<int>(articleId);
    map['source_url'] = Variable<String>(sourceUrl);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    return map;
  }

  ArticleImagesCompanion toCompanion(bool nullToAbsent) {
    return ArticleImagesCompanion(
      id: Value(id),
      articleId: Value(articleId),
      sourceUrl: Value(sourceUrl),
      localPath: Value(localPath),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
    );
  }

  factory ArticleImageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleImageRow(
      id: serializer.fromJson<int>(json['id']),
      articleId: serializer.fromJson<int>(json['articleId']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'articleId': serializer.toJson<int>(articleId),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'localPath': serializer.toJson<String>(localPath),
      'mimeType': serializer.toJson<String?>(mimeType),
    };
  }

  ArticleImageRow copyWith({
    int? id,
    int? articleId,
    String? sourceUrl,
    String? localPath,
    Value<String?> mimeType = const Value.absent(),
  }) => ArticleImageRow(
    id: id ?? this.id,
    articleId: articleId ?? this.articleId,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    localPath: localPath ?? this.localPath,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
  );
  ArticleImageRow copyWithCompanion(ArticleImagesCompanion data) {
    return ArticleImageRow(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleImageRow(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, articleId, sourceUrl, localPath, mimeType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleImageRow &&
          other.id == this.id &&
          other.articleId == this.articleId &&
          other.sourceUrl == this.sourceUrl &&
          other.localPath == this.localPath &&
          other.mimeType == this.mimeType);
}

class ArticleImagesCompanion extends UpdateCompanion<ArticleImageRow> {
  final Value<int> id;
  final Value<int> articleId;
  final Value<String> sourceUrl;
  final Value<String> localPath;
  final Value<String?> mimeType;
  const ArticleImagesCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
  });
  ArticleImagesCompanion.insert({
    this.id = const Value.absent(),
    required int articleId,
    required String sourceUrl,
    required String localPath,
    this.mimeType = const Value.absent(),
  }) : articleId = Value(articleId),
       sourceUrl = Value(sourceUrl),
       localPath = Value(localPath);
  static Insertable<ArticleImageRow> custom({
    Expression<int>? id,
    Expression<int>? articleId,
    Expression<String>? sourceUrl,
    Expression<String>? localPath,
    Expression<String>? mimeType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (localPath != null) 'local_path': localPath,
      if (mimeType != null) 'mime_type': mimeType,
    });
  }

  ArticleImagesCompanion copyWith({
    Value<int>? id,
    Value<int>? articleId,
    Value<String>? sourceUrl,
    Value<String>? localPath,
    Value<String?>? mimeType,
  }) {
    return ArticleImagesCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<int>(articleId.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleImagesCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTable extends Deliveries
    with TableInfo<$DeliveriesTable, DeliveryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _articleCountMeta = const VerificationMeta(
    'articleCount',
  );
  @override
  late final GeneratedColumn<int> articleCount = GeneratedColumn<int>(
    'article_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sentAt,
    articleCount,
    fileSize,
    success,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('article_count')) {
      context.handle(
        _articleCountMeta,
        articleCount.isAcceptableOrUnknown(
          data['article_count']!,
          _articleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_articleCountMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
      articleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}article_count'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $DeliveriesTable createAlias(String alias) {
    return $DeliveriesTable(attachedDatabase, alias);
  }
}

class DeliveryRow extends DataClass implements Insertable<DeliveryRow> {
  final int id;
  final DateTime sentAt;
  final int articleCount;
  final int fileSize;
  final bool success;
  final String? error;
  const DeliveryRow({
    required this.id,
    required this.sentAt,
    required this.articleCount,
    required this.fileSize,
    required this.success,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sent_at'] = Variable<DateTime>(sentAt);
    map['article_count'] = Variable<int>(articleCount);
    map['file_size'] = Variable<int>(fileSize);
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  DeliveriesCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesCompanion(
      id: Value(id),
      sentAt: Value(sentAt),
      articleCount: Value(articleCount),
      fileSize: Value(fileSize),
      success: Value(success),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory DeliveryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryRow(
      id: serializer.fromJson<int>(json['id']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      articleCount: serializer.fromJson<int>(json['articleCount']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      success: serializer.fromJson<bool>(json['success']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'articleCount': serializer.toJson<int>(articleCount),
      'fileSize': serializer.toJson<int>(fileSize),
      'success': serializer.toJson<bool>(success),
      'error': serializer.toJson<String?>(error),
    };
  }

  DeliveryRow copyWith({
    int? id,
    DateTime? sentAt,
    int? articleCount,
    int? fileSize,
    bool? success,
    Value<String?> error = const Value.absent(),
  }) => DeliveryRow(
    id: id ?? this.id,
    sentAt: sentAt ?? this.sentAt,
    articleCount: articleCount ?? this.articleCount,
    fileSize: fileSize ?? this.fileSize,
    success: success ?? this.success,
    error: error.present ? error.value : this.error,
  );
  DeliveryRow copyWithCompanion(DeliveriesCompanion data) {
    return DeliveryRow(
      id: data.id.present ? data.id.value : this.id,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      articleCount: data.articleCount.present
          ? data.articleCount.value
          : this.articleCount,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      success: data.success.present ? data.success.value : this.success,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryRow(')
          ..write('id: $id, ')
          ..write('sentAt: $sentAt, ')
          ..write('articleCount: $articleCount, ')
          ..write('fileSize: $fileSize, ')
          ..write('success: $success, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sentAt, articleCount, fileSize, success, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryRow &&
          other.id == this.id &&
          other.sentAt == this.sentAt &&
          other.articleCount == this.articleCount &&
          other.fileSize == this.fileSize &&
          other.success == this.success &&
          other.error == this.error);
}

class DeliveriesCompanion extends UpdateCompanion<DeliveryRow> {
  final Value<int> id;
  final Value<DateTime> sentAt;
  final Value<int> articleCount;
  final Value<int> fileSize;
  final Value<bool> success;
  final Value<String?> error;
  const DeliveriesCompanion({
    this.id = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.articleCount = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.success = const Value.absent(),
    this.error = const Value.absent(),
  });
  DeliveriesCompanion.insert({
    this.id = const Value.absent(),
    this.sentAt = const Value.absent(),
    required int articleCount,
    required int fileSize,
    this.success = const Value.absent(),
    this.error = const Value.absent(),
  }) : articleCount = Value(articleCount),
       fileSize = Value(fileSize);
  static Insertable<DeliveryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? sentAt,
    Expression<int>? articleCount,
    Expression<int>? fileSize,
    Expression<bool>? success,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sentAt != null) 'sent_at': sentAt,
      if (articleCount != null) 'article_count': articleCount,
      if (fileSize != null) 'file_size': fileSize,
      if (success != null) 'success': success,
      if (error != null) 'error': error,
    });
  }

  DeliveriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? sentAt,
    Value<int>? articleCount,
    Value<int>? fileSize,
    Value<bool>? success,
    Value<String?>? error,
  }) {
    return DeliveriesCompanion(
      id: id ?? this.id,
      sentAt: sentAt ?? this.sentAt,
      articleCount: articleCount ?? this.articleCount,
      fileSize: fileSize ?? this.fileSize,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (articleCount.present) {
      map['article_count'] = Variable<int>(articleCount.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesCompanion(')
          ..write('id: $id, ')
          ..write('sentAt: $sentAt, ')
          ..write('articleCount: $articleCount, ')
          ..write('fileSize: $fileSize, ')
          ..write('success: $success, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ArticleTagsTable articleTags = $ArticleTagsTable(this);
  late final $ArticleImagesTable articleImages = $ArticleImagesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $DeliveriesTable deliveries = $DeliveriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    articles,
    tags,
    articleTags,
    articleImages,
    settings,
    deliveries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('article_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('article_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('article_images', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ArticlesTableCreateCompanionBuilder = ArticlesCompanion Function({
  Value<int> id,
  required String url,
  Value<String?> title,
  Value<String?> author,
  Value<String?> siteName,
  Value<String?> siteUrl,
  Value<DateTime?> publishedAt,
  Value<String> origin,
  Value<String> status,
  Value<String?> error,
  Value<String?> contentHtml,
  Value<String?> contentSource,
  Value<DateTime> createdAt,
  Value<DateTime?> sentAt,
  Value<bool> selected,
  Value<int> sortIndex,
});
typedef $$ArticlesTableUpdateCompanionBuilder = ArticlesCompanion Function({
  Value<int> id,
  Value<String> url,
  Value<String?> title,
  Value<String?> author,
  Value<String?> siteName,
  Value<String?> siteUrl,
  Value<DateTime?> publishedAt,
  Value<String> origin,
  Value<String> status,
  Value<String?> error,
  Value<String?> contentHtml,
  Value<String?> contentSource,
  Value<DateTime> createdAt,
  Value<DateTime?> sentAt,
  Value<bool> selected,
  Value<int> sortIndex,
});

final class $$ArticlesTableReferences
    extends BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow> {
  $$ArticlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArticleTagsTable, List<ArticleTagRow>>
  _articleTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articleTags,
    aliasName: 'articles__id__article_tags__article_id',
  );

  $$ArticleTagsTableProcessedTableManager get articleTagsRefs {
    final manager = $$ArticleTagsTableTableManager(
      $_db,
      $_db.articleTags,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articleTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ArticleImagesTable, List<ArticleImageRow>>
  _articleImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articleImages,
    aliasName: 'articles__id__article_images__article_id',
  );

  $$ArticleImagesTableProcessedTableManager get articleImagesRefs {
    final manager = $$ArticleImagesTableTableManager(
      $_db,
      $_db.articleImages,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articleImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentSource => $composableBuilder(
    column: $table.contentSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> articleTagsRefs(
    Expression<bool> Function($$ArticleTagsTableFilterComposer f) f,
  ) {
    final $$ArticleTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleTags,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleTagsTableFilterComposer(
            $db: $db,
            $table: $db.articleTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> articleImagesRefs(
    Expression<bool> Function($$ArticleImagesTableFilterComposer f) f,
  ) {
    final $$ArticleImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleImages,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleImagesTableFilterComposer(
            $db: $db,
            $table: $db.articleImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentSource => $composableBuilder(
    column: $table.contentSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumn<String> get siteUrl =>
      $composableBuilder(column: $table.siteUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentSource => $composableBuilder(
    column: $table.contentSource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<bool> get selected =>
      $composableBuilder(column: $table.selected, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  Expression<T> articleTagsRefs<T extends Object>(
    Expression<T> Function($$ArticleTagsTableAnnotationComposer a) f,
  ) {
    final $$ArticleTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleTags,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.articleTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> articleImagesRefs<T extends Object>(
    Expression<T> Function($$ArticleImagesTableAnnotationComposer a) f,
  ) {
    final $$ArticleImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleImages,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.articleImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          ArticleRow,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (ArticleRow, $$ArticlesTableReferences),
          ArticleRow,
          PrefetchHooks Function({bool articleTagsRefs, bool articleImagesRefs})
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<String?> siteUrl = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> contentHtml = const Value.absent(),
                Value<String?> contentSource = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<bool> selected = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                url: url,
                title: title,
                author: author,
                siteName: siteName,
                siteUrl: siteUrl,
                publishedAt: publishedAt,
                origin: origin,
                status: status,
                error: error,
                contentHtml: contentHtml,
                contentSource: contentSource,
                createdAt: createdAt,
                sentAt: sentAt,
                selected: selected,
                sortIndex: sortIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                Value<String?> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<String?> siteUrl = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> contentHtml = const Value.absent(),
                Value<String?> contentSource = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<bool> selected = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                url: url,
                title: title,
                author: author,
                siteName: siteName,
                siteUrl: siteUrl,
                publishedAt: publishedAt,
                origin: origin,
                status: status,
                error: error,
                contentHtml: contentHtml,
                contentSource: contentSource,
                createdAt: createdAt,
                sentAt: sentAt,
                selected: selected,
                sortIndex: sortIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticlesTable, ArticleRow>(table),
                  $$ArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({articleTagsRefs = false, articleImagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (articleTagsRefs) db.articleTags,
                    if (articleImagesRefs) db.articleImages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (articleTagsRefs)
                        await $_getPrefetchedData<
                          ArticleRow,
                          $ArticlesTable,
                          ArticleTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._articleTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).articleTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (articleImagesRefs)
                        await $_getPrefetchedData<
                          ArticleRow,
                          $ArticlesTable,
                          ArticleImageRow
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._articleImagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).articleImagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      ArticleRow,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (ArticleRow, $$ArticlesTableReferences),
      ArticleRow,
      PrefetchHooks Function({bool articleTagsRefs, bool articleImagesRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArticleTagsTable, List<ArticleTagRow>>
  _articleTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articleTags,
    aliasName: 'tags__id__article_tags__tag_id',
  );

  $$ArticleTagsTableProcessedTableManager get articleTagsRefs {
    final manager = $$ArticleTagsTableTableManager(
      $_db,
      $_db.articleTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articleTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> articleTagsRefs(
    Expression<bool> Function($$ArticleTagsTableFilterComposer f) f,
  ) {
    final $$ArticleTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleTagsTableFilterComposer(
            $db: $db,
            $table: $db.articleTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> articleTagsRefs<T extends Object>(
    Expression<T> Function($$ArticleTagsTableAnnotationComposer a) f,
  ) {
    final $$ArticleTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.articleTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool articleTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => TagsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => TagsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (articleTagsRefs) db.articleTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (articleTagsRefs)
                    await $_getPrefetchedData<
                      TagRow,
                      $TagsTable,
                      ArticleTagRow
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._articleTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).articleTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool articleTagsRefs})
    >;
typedef $$ArticleTagsTableCreateCompanionBuilder =
    ArticleTagsCompanion Function({
      required int articleId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$ArticleTagsTableUpdateCompanionBuilder =
    ArticleTagsCompanion Function({
      Value<int> articleId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$ArticleTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ArticleTagsTable, ArticleTagRow> {
  $$ArticleTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias('article_tags__article_id__articles__id');

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<int>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('article_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticleTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ArticleTagsTable> {
  $$ArticleTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticleTagsTable> {
  $$ArticleTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticleTagsTable> {
  $$ArticleTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticleTagsTable,
          ArticleTagRow,
          $$ArticleTagsTableFilterComposer,
          $$ArticleTagsTableOrderingComposer,
          $$ArticleTagsTableAnnotationComposer,
          $$ArticleTagsTableCreateCompanionBuilder,
          $$ArticleTagsTableUpdateCompanionBuilder,
          (ArticleTagRow, $$ArticleTagsTableReferences),
          ArticleTagRow,
          PrefetchHooks Function({bool articleId, bool tagId})
        > {
  $$ArticleTagsTableTableManager(_$AppDatabase db, $ArticleTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticleTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticleTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticleTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> articleId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleTagsCompanion(
                articleId: articleId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int articleId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => ArticleTagsCompanion.insert(
                articleId: articleId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticleTagsTable, ArticleTagRow>(table),
                  $$ArticleTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.articleId,
                        referencedTable: $$ArticleTagsTableReferences
                            ._articleIdTable(db),
                        referencedColumn: $$ArticleTagsTableReferences
                            ._articleIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$ArticleTagsTableReferences
                            ._tagIdTable(db),
                        referencedColumn: $$ArticleTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArticleTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticleTagsTable,
      ArticleTagRow,
      $$ArticleTagsTableFilterComposer,
      $$ArticleTagsTableOrderingComposer,
      $$ArticleTagsTableAnnotationComposer,
      $$ArticleTagsTableCreateCompanionBuilder,
      $$ArticleTagsTableUpdateCompanionBuilder,
      (ArticleTagRow, $$ArticleTagsTableReferences),
      ArticleTagRow,
      PrefetchHooks Function({bool articleId, bool tagId})
    >;
typedef $$ArticleImagesTableCreateCompanionBuilder =
    ArticleImagesCompanion Function({
      Value<int> id,
      required int articleId,
      required String sourceUrl,
      required String localPath,
      Value<String?> mimeType,
    });
typedef $$ArticleImagesTableUpdateCompanionBuilder =
    ArticleImagesCompanion Function({
      Value<int> id,
      Value<int> articleId,
      Value<String> sourceUrl,
      Value<String> localPath,
      Value<String?> mimeType,
    });

final class $$ArticleImagesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ArticleImagesTable, ArticleImageRow> {
  $$ArticleImagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias('article_images__article_id__articles__id');

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<int>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticleImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticleImagesTable> {
  $$ArticleImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticleImagesTable> {
  $$ArticleImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticleImagesTable> {
  $$ArticleImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticleImagesTable,
          ArticleImageRow,
          $$ArticleImagesTableFilterComposer,
          $$ArticleImagesTableOrderingComposer,
          $$ArticleImagesTableAnnotationComposer,
          $$ArticleImagesTableCreateCompanionBuilder,
          $$ArticleImagesTableUpdateCompanionBuilder,
          (ArticleImageRow, $$ArticleImagesTableReferences),
          ArticleImageRow,
          PrefetchHooks Function({bool articleId})
        > {
  $$ArticleImagesTableTableManager(_$AppDatabase db, $ArticleImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticleImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticleImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticleImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> articleId = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
              }) => ArticleImagesCompanion(
                id: id,
                articleId: articleId,
                sourceUrl: sourceUrl,
                localPath: localPath,
                mimeType: mimeType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int articleId,
                required String sourceUrl,
                required String localPath,
                Value<String?> mimeType = const Value.absent(),
              }) => ArticleImagesCompanion.insert(
                id: id,
                articleId: articleId,
                sourceUrl: sourceUrl,
                localPath: localPath,
                mimeType: mimeType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticleImagesTable, ArticleImageRow>(table),
                  $$ArticleImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.articleId,
                        referencedTable: $$ArticleImagesTableReferences
                            ._articleIdTable(db),
                        referencedColumn: $$ArticleImagesTableReferences
                            ._articleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArticleImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticleImagesTable,
      ArticleImageRow,
      $$ArticleImagesTableFilterComposer,
      $$ArticleImagesTableOrderingComposer,
      $$ArticleImagesTableAnnotationComposer,
      $$ArticleImagesTableCreateCompanionBuilder,
      $$ArticleImagesTableUpdateCompanionBuilder,
      (ArticleImageRow, $$ArticleImagesTableReferences),
      ArticleImageRow,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$DeliveriesTableCreateCompanionBuilder = DeliveriesCompanion Function({
  Value<int> id,
  Value<DateTime> sentAt,
  required int articleCount,
  required int fileSize,
  Value<bool> success,
  Value<String?> error,
});
typedef $$DeliveriesTableUpdateCompanionBuilder = DeliveriesCompanion Function({
  Value<int> id,
  Value<DateTime> sentAt,
  Value<int> articleCount,
  Value<int> fileSize,
  Value<bool> success,
  Value<String?> error,
});

class $$DeliveriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get articleCount => $composableBuilder(
    column: $table.articleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeliveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get articleCount => $composableBuilder(
    column: $table.articleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeliveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<int> get articleCount => $composableBuilder(
    column: $table.articleCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$DeliveriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveriesTable,
          DeliveryRow,
          $$DeliveriesTableFilterComposer,
          $$DeliveriesTableOrderingComposer,
          $$DeliveriesTableAnnotationComposer,
          $$DeliveriesTableCreateCompanionBuilder,
          $$DeliveriesTableUpdateCompanionBuilder,
          (
            DeliveryRow,
            BaseReferences<_$AppDatabase, $DeliveriesTable, DeliveryRow>,
          ),
          DeliveryRow,
          PrefetchHooks Function()
        > {
  $$DeliveriesTableTableManager(_$AppDatabase db, $DeliveriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
                Value<int> articleCount = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => DeliveriesCompanion(
                id: id,
                sentAt: sentAt,
                articleCount: articleCount,
                fileSize: fileSize,
                success: success,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
                required int articleCount,
                required int fileSize,
                Value<bool> success = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => DeliveriesCompanion.insert(
                id: id,
                sentAt: sentAt,
                articleCount: articleCount,
                fileSize: fileSize,
                success: success,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeliveriesTable, DeliveryRow>(table),
                  BaseReferences<_$AppDatabase, $DeliveriesTable, DeliveryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeliveriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveriesTable,
      DeliveryRow,
      $$DeliveriesTableFilterComposer,
      $$DeliveriesTableOrderingComposer,
      $$DeliveriesTableAnnotationComposer,
      $$DeliveriesTableCreateCompanionBuilder,
      $$DeliveriesTableUpdateCompanionBuilder,
      (
        DeliveryRow,
        BaseReferences<_$AppDatabase, $DeliveriesTable, DeliveryRow>,
      ),
      DeliveryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ArticleTagsTableTableManager get articleTags =>
      $$ArticleTagsTableTableManager(_db, _db.articleTags);
  $$ArticleImagesTableTableManager get articleImages =>
      $$ArticleImagesTableTableManager(_db, _db.articleImages);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$DeliveriesTableTableManager get deliveries =>
      $$DeliveriesTableTableManager(_db, _db.deliveries);
}
