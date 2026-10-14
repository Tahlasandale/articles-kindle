import 'package:articles_kindle/data/url/url_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalize — rejet', () {
    test('refuse une chaîne vide', () {
      expect(() => UrlNormalizer.normalize(''), throwsFormatException);
    });

    test('refuse du texte qui n\'est pas une adresse', () {
      expect(
        () => UrlNormalizer.normalize('pas une url'),
        throwsFormatException,
      );
      expect(
        () => UrlNormalizer.normalize('article sur les oiseaux'),
        throwsFormatException,
      );
    });

    test('refuse un schéma non http', () {
      expect(
        () => UrlNormalizer.normalize('javascript:alert(1)'),
        throwsFormatException,
      );
      expect(
        () => UrlNormalizer.normalize('file:///etc/passwd'),
        throwsFormatException,
      );
    });

    test('refuse une adresse sans hôte', () {
      expect(
        () => UrlNormalizer.normalize('https:///article'),
        throwsFormatException,
      );
    });

    test('accepte une adresse collée avec des espaces autour', () {
      expect(
        UrlNormalizer.normalize('  https://exemple.fr/article  '),
        'https://exemple.fr/article',
      );
    });

    test('accepte une adresse sans schéma', () {
      expect(
        UrlNormalizer.normalize('exemple.fr/article'),
        'https://exemple.fr/article',
      );
    });
  });

  group('normalize — canonicalisation', () {
    test('met le schéma et l\'hôte en minuscules', () {
      expect(
        UrlNormalizer.normalize('HTTPS://Exemple.FR/Article'),
        'https://exemple.fr/Article',
      );
    });

    test('retire le www', () {
      expect(
        UrlNormalizer.normalize('https://www.exemple.fr/a'),
        'https://exemple.fr/a',
      );
    });

    test('conserve un sous-domaine qui commence par www', () {
      expect(
        UrlNormalizer.normalize('https://www2.exemple.fr/a'),
        'https://www2.exemple.fr/a',
      );
    });

    test('retire le fragment', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a#section-2'),
        'https://exemple.fr/a',
      );
    });

    test('retire le port par défaut', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr:443/a'),
        'https://exemple.fr/a',
      );
      expect(
        UrlNormalizer.normalize('http://exemple.fr:80/a'),
        'http://exemple.fr/a',
      );
    });

    test('conserve un port non standard', () {
      expect(
        UrlNormalizer.normalize('http://exemple.fr:8080/a'),
        'http://exemple.fr:8080/a',
      );
    });

    test('retire la barre oblique finale hors racine', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a/'),
        'https://exemple.fr/a',
      );
    });

    test('conserve la racine', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/'),
        'https://exemple.fr/',
      );
    });
  });

  group('normalize — paramètres de suivi', () {
    test('retire utm_*', () {
      expect(
        UrlNormalizer.normalize(
          'https://exemple.fr/a?utm_source=rss&utm_medium=feed&id=42',
        ),
        'https://exemple.fr/a?id=42',
      );
    });

    test('retire les traqueurs connus', () {
      expect(
        UrlNormalizer.normalize(
          'https://exemple.fr/a?fbclid=abc&gclid=xyz&mc_cid=1&mc_eid=2&gbraid=3&wbraid=4',
        ),
        'https://exemple.fr/a',
      );
    });

    test('retire aussi les variantes en majuscules', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a?UTM_Source=rss'),
        'https://exemple.fr/a',
      );
    });

    test('conserve les paramètres qui portent du sens', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a?page=2&q=chat'),
        'https://exemple.fr/a?page=2&q=chat',
      );
    });

    test('trie les paramètres restants pour que l\'ordre n\'importe plus', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a?b=2&a=1'),
        'https://exemple.fr/a?a=1&b=2',
      );
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a?a=1&b=2'),
        'https://exemple.fr/a?a=1&b=2',
      );
    });

    test('retire un paramètre sans valeur, sauf s\'il est seul', () {
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a?flag=&b=1'),
        'https://exemple.fr/a?b=1',
      );
      expect(
        UrlNormalizer.normalize('https://exemple.fr/a?flag='),
        'https://exemple.fr/a?flag=',
      );
    });
  });

  group('isDuplicate — deux écritures de la même adresse', () {
    test('mêmes articles malgré le tracking et le www', () {
      const a = 'https://www.exemple.fr/article?utm_source=twitter#ancre';
      const b = 'https://exemple.fr/article';
      expect(UrlNormalizer.normalize(a), UrlNormalizer.normalize(b));
    });

    test('diffèrent si le chemin change', () {
      const a = 'https://exemple.fr/article-1';
      const b = 'https://exemple.fr/article-2';
      expect(UrlNormalizer.normalize(a), isNot(UrlNormalizer.normalize(b)));
    });
  });
}
