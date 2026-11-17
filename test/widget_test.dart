// Amadeus giriş noktası sınıflarının varlık testi.
//
// Uygulamanın gerçek giriş noktası AmadeusApp + AmadeusRoot'tur; eski counter
// şablonu kaldırılmıştır. Widget ağacını burada pump etmiyoruz çünkü kök,
// platform kanallarına (depolama, bildirim) bağlıdır; bunlar test/ altındaki
// birim testlerinde karşılanır.
import 'package:flutter_test/flutter_test.dart';

import 'package:amadeus/main.dart';

void main() {
  test('Giriş noktası sınıfları tanımlı', () {
    expect(AmadeusApp, isNotNull);
    expect(AmadeusRoot, isNotNull);
  });
}
