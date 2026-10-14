import 'package:articles_kindle/data/share/share_receiver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extraction d\'adresse dans un texte partagé', () {
    test('une adresse seule', () {
      expect(ShareReceiver.extractUrls('https://exemple.fr/article'), [
        'https://exemple.fr/article',
      ]);
    });

    test('une adresse entourée de texte', () {
      expect(
        ShareReceiver.extractUrls(
          'Regarde ça : https://exemple.fr/article ? C\'est bien',
        ),
        ['https://exemple.fr/article'],
      );
    });

    test('une adresse avec des paramètres', () {
      expect(ShareReceiver.extractUrls('https://exemple.fr/a?b=1&c=2'), [
        'https://exemple.fr/a?b=1&c=2',
      ]);
    });

    test('deux adresses sont rendues dans l\'ordre', () {
      expect(
        ShareReceiver.extractUrls('https://un.fr/a et https://deux.fr/b'),
        ['https://un.fr/a', 'https://deux.fr/b'],
      );
    });

    test('la même adresse deux fois n\'est rendue qu\'une fois', () {
      expect(ShareReceiver.extractUrls('https://un.fr/a https://un.fr/a'), [
        'https://un.fr/a',
      ]);
    });

    test('un texte sans adresse ne rend rien', () {
      expect(ShareReceiver.extractUrls('un simple mot'), isEmpty);
      expect(ShareReceiver.extractUrls(''), isEmpty);
    });

    test('ne prend pas un schéma non web', () {
      expect(ShareReceiver.extractUrls('javascript:alert(1)'), isEmpty);
      expect(ShareReceiver.extractUrls('file:///etc/passwd'), isEmpty);
    });

    test('une adresse trop courte est ignorée', () {
      expect(ShareReceiver.extractUrls('http://a'), isEmpty);
    });

    test('retire la ponctuation finale collée par le navigateur', () {
      expect(ShareReceiver.extractUrls('https://exemple.fr/a.'), [
        'https://exemple.fr/a',
      ]);
    });
  });
}
