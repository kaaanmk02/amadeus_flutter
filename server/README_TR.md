# Amadeus API Proxy

Bu küçük Node.js sunucusu sağlayıcı anahtarını Flutter uygulamasından uzak tutar.

1. Node.js 20+ kurun ve `npm install` çalıştırın.
2. Ortam değişkenlerini `.env.example` dosyasından kopyalayarak barındırma sağlayıcısının Secrets bölümüne girin. `.env` dosyasını Git'e eklemeyin.
3. `UPSTREAM_URL` sağlayıcının OpenAI uyumlu kök adresi, `UPSTREAM_API_KEY` sağlayıcı anahtarı, `AMADEUS_PROXY_TOKEN` uzun rastgele istemci tokenıdır.
4. Sunucuyu HTTPS arkasında yayınlayın. Uygulamada API adresi `https://sunucu-adresiniz` olmalı ve proxy seçeneği açık olmalıdır.
5. `AMADEUS_PROXY_TOKEN` uygulamada API Anahtarı alanına girilir. Bu token sağlayıcı anahtarından farklıdır; istemcide bulunacağı için tek başına güçlü kimlik doğrulama sayılmaz. Gerçek kullanımda kullanıcı kimliği/oturum doğrulaması, kota ve abuse koruması ekleyin.

Not: Proxy, API sağlayıcı anahtarını uygulama paketinden çıkarır ama proxy erişim tokenını mobil uygulamada tutmak yine kopyalanabilir. Üretim ortamında kullanıcı başına kimlik doğrulama ve sunucu tarafı kota zorunludur.
