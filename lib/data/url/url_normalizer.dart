/// Canonicalisation d'une adresse web.
///
/// La forme renvoyée sert de clé d'unicité : deux écritures de la même page
/// (tracking, `www`, port par défaut, fragment, ordre des paramètres) donnent la
/// même chaîne, ce qui suffit à détecter les doublons.
class UrlNormalizer {
  UrlNormalizer._();

  /// Paramètres retirés : ils servent à mesurer une campagne, pas à définir la page.
  static const Set<String> _trackingParameters = {
    'fbclid',
    'gclid',
    'gbraid',
    'wbraid',
    'dclid',
    'msclkid',
    'mc_cid',
    'mc_eid',
    'igshid',
    'ref_src',
    'yclid',
    '_ga',
  };

  static const Set<String> _schemes = {'http', 'https'};

  /// Renvoie l'adresse canonique, ou lève [FormatException] si l'entrée n'est pas
  /// une adresse web exploitable.
  static String normalize(String raw) {
    final uri = parse(raw);
    return _canonicalize(uri);
  }

  /// Analyse l'entrée sans la canonicaliser. Utile quand on veut garder l'adresse
  /// d'origine telle quelle.
  static Uri parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Adresse vide', raw);
    }

    final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';

    final uri = Uri.tryParse(withScheme);
    if (uri == null) {
      throw FormatException('Adresse illisible', raw);
    }
    if (!_schemes.contains(uri.scheme)) {
      throw FormatException('Schéma non web : ${uri.scheme}', raw);
    }
    if (uri.host.isEmpty) {
      throw FormatException('Adresse sans hôte', raw);
    }
    if (!_looksLikeHost(uri.host)) {
      throw FormatException('Hôte illisible : ${uri.host}', raw);
    }
    return uri;
  }

  /// `Uri.tryParse` accepte des espaces et desacentS dans l'hôte : une phrase
  /// collée dans le champ de saisie devient sinon une adresse « valide ».
  static bool _looksLikeHost(String host) {
    if (host.startsWith('[')) return host.contains(']'); // IPv6 littéral
    if (_isIpv4(host)) return true;

    final labels = host.split('.');
    if (labels.length < 2) return false;
    for (final label in labels) {
      if (label.isEmpty || label.length > 63) return false;
      if (!_labelPattern.hasMatch(label)) return false;
    }
    return _tldPattern.hasMatch(labels.last);
  }

  static final RegExp _labelPattern = RegExp(
    r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$',
  );

  /// Un TLD wholly numérique serait une adresse IP, pas un nom de site.
  static final RegExp _tldPattern = RegExp(r'^[a-zA-Z]{2,}$');

  static bool _isIpv4(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255 && p == n.toString();
    });
  }

  static bool isValid(String raw) {
    try {
      parse(raw);
      return true;
    } on FormatException {
      return false;
    }
  }

  static String _canonicalize(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = _stripWww(uri.host.toLowerCase());
    final port = _stripDefaultPort(uri.port, scheme);
    final path = _canonicalizePath(uri.path);
    final query = _canonicalizeQuery(uri.query);

    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      query: query.isEmpty ? null : query,
    ).toString();
  }

  static int? _stripDefaultPort(int port, String scheme) {
    if ((scheme == 'https' && port == 443) ||
        (scheme == 'http' && port == 80)) {
      return null;
    }
    return port;
  }

  static String _canonicalizePath(String path) {
    final withoutWww = path;
    if (withoutWww.length > 1 && withoutWww.endsWith('/')) {
      return withoutWww.substring(0, withoutWww.length - 1);
    }
    return withoutWww.isEmpty ? '/' : withoutWww;
  }

  /// Retire le `www.` de tête : `www.exemple.fr` et `exemple.fr` sont le même site,
  /// `www2.exemple.fr` n'est pas `www` suivi de quelque chose, c'est un autre site.
  static String _stripWww(String host) {
    if (!host.startsWith('www.')) return host;
    final rest = host.substring(4);
    return rest.contains('.') ? rest : host;
  }

  static String _canonicalizeQuery(String query) {
    if (query.isEmpty) return '';

    final kept = <MapEntry<String, String>>[];
    final droppedEmpty = <String>[];

    for (final pair in query.split('&')) {
      if (pair.isEmpty) continue;
      final index = pair.indexOf('=');
      final name = index == -1 ? pair : pair.substring(0, index);
      final value = index == -1 ? '' : pair.substring(index + 1);
      final lowerName = _decode(name).toLowerCase();

      if (_isTracking(lowerName)) continue;

      final decoded = _decode(value);
      if (decoded.isEmpty) {
        droppedEmpty.add(pair);
        continue;
      }
      kept.add(MapEntry(_decode(name), decoded));
    }

    // Un paramètre vide n'est retiré que s'il y en a d'autres : `?q=` seul reste
    // une adresse qui veut dire quelque chose.
    if (droppedEmpty.isNotEmpty && kept.isEmpty) {
      return Uri(query: query).query;
    }

    kept.sort((a, b) {
      final byName = a.key.compareTo(b.key);
      return byName != 0 ? byName : a.value.compareTo(b.value);
    });

    return Uri(queryParameters: {for (final e in kept) e.key: e.value}).query;
  }

  static bool _isTracking(String name) =>
      name.startsWith('utm_') || _trackingParameters.contains(name);

  static String _decode(String value) {
    try {
      return Uri.decodeQueryComponent(value);
    } on FormatException {
      return value;
    } on ArgumentError {
      return value;
    }
  }
}
