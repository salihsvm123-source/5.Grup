# 📊 NOVA | Perakende Satış ve Hava Durumu Analizi

Perakende satış verilerini hava durumu kayıtlarıyla birleştirerek satış performansını, dönemsel alışveriş davranışlarını ve kârlılığı inceleyen bir **dbt ve DuckDB veri analizi projesi**.

5. Grup tarafından hazırlanan proje, ham CSV dosyalarını SQL modelleriyle düzenleyerek raporlama ve görselleştirmede kullanılabilecek analiz tabloları oluşturur.

## 🎯 Projenin Amacı

Satışlar; mevsim, hava koşulları, satış kanalı ve indirim oranı gibi farklı değişkenlerle birlikte değerlendirilmelidir. Bu proje, söz konusu değişkenlere göre satışların nasıl farklılaştığını inceleyerek işletmelerin stok, kampanya ve kanal planlamasına veriyle destek sağlamayı amaçlar.

Cevap aranan temel sorular:

- Farklı hava koşullarında ciro ve sipariş tutarları nasıl değişiyor?
- Hangi ürünlerin satışları yağışlı günlerde daha fazla yoğunlaşıyor?
- Online ve mağaza kanallarının hava durumuna göre satış dağılımı nasıl?
- Ürün kategorilerinin satışları mevsimlere göre nasıl değişiyor?
- İndirim oranlarına göre ciro ve kâr marjı nasıl farklılaşıyor?
- Hafta içi ve hafta sonu alışverişleri arasında nasıl farklar var?
- Şehir ve ürün kategorisi bazında kârlılık nasıl dağılıyor?

> Analizler gözlenen ilişkileri ve dağılımları gösterir. Hava durumunun veya indirimin satışlara neden olduğunu tek başına kanıtlamaz.

## ✨ Özellikler

- **Veri hazırlama:** Tarih, metin ve sayısal alanların analiz için uygun biçimlere dönüştürülmesi.
- **Finansal hesaplamalar:** İndirim sonrası ciro ve ürün maliyetine dayalı kâr hesabı.
- **Veri birleştirme:** Satış ve hava durumu kayıtlarının şehir ve tarih üzerinden eşleştirilmesi.
- **Dönemsel analiz:** Mevsim, hafta içi ve hafta sonu bazında satış özetleri.
- **Kanal karşılaştırması:** Satış kanallarının hava koşullarıyla birlikte incelenmesi.
- **Yağış endeksi:** Ürünlerin yağışlı koşullardaki satış payının genel dağılımla karşılaştırılması.
- **Veri kontrolleri:** Boş değer, benzersizlik ve belirli sayısal sınır kontrolleri.

## 📂 Veri Kaynakları

| Dosya | İçerik | Kullanım |
|---|---|---|
| `seeds/perakende_satis.csv` | Sipariş, tarih, müşteri, şehir, bölge, kanal, kategori, ürün, miktar, fiyat, maliyet ve indirim alanları | Satış ve kârlılık analizleri |
| `seeds/hava_durumu.csv` | Tarih, şehir, plaka kodu, sıcaklık, yağış, rüzgâr ve hava durumu açıklaması | Satışların hava koşullarıyla eşleştirilmesi |

Satış dosyası, proje ayarlarında noktalı virgül (`;`) ayırıcıyla tanımlanmıştır. Hava durumu hazırlama modeli yalnızca **1 Ocak–31 Aralık 2024** tarihleri arasındaki kayıtları kullanır.

Veri setlerinin özgün sağlayıcısı, gerçek veya sentetik olma durumu ve kullanım lisansları mevcut depoda belgelenmemiştir.

## ⚙️ Veri İşleme Süreci

1. **Ham verilerin yüklenmesi:** CSV dosyaları dbt seed işlemiyle veritabanına aktarılır.
2. **Hazırlama katmanı — staging:** Tarihler ve sayılar dönüştürülür, sütunlar yeniden adlandırılır ve hesaplanan alanlar oluşturulur.
3. **Analiz katmanı — marts:** Hazırlanan verilerden farklı iş sorularına yönelik özet modeller üretilir.
4. **Kontrol:** Tanımlanan dbt testleriyle veri kalitesi kuralları değerlendirilir.
5. **Raporlama:** Ortaya çıkan modeller, sorgulama ve harici görselleştirme araçlarında kullanılabilir.

### Temel Hesaplamalar

- **Ciro:** Miktar × Birim fiyat × (1 − İndirim oranı)
- **Ürün maliyeti:** Miktar × Birim maliyet
- **Net kâr alanı:** Ciro − Ürün maliyeti
- **Kâr marjı (%):** Toplam kâr / Toplam ciro × 100

Kodda `net_kar` olarak adlandırılan alan yalnızca ürün maliyetini düşer. Kira, personel, vergi ve diğer işletme giderlerini içeren muhasebesel net kâr olarak değerlendirilmemelidir.

## 📈 Analiz Modelleri

| Model | Kırılım | Üretilen bilgiler |
|---|---|---|
| `gunlervesatislar` | Hafta içi / hafta sonu ve kategori | Benzersiz sipariş sayısı, satılan adet, ciro ve ortalama kayıt tutarı |
| `mart_havadurumu_ciro` | Hava durumu açıklaması | Kayıt sayısına dayalı sipariş sayacı, ciro ve ortalama kayıt tutarı |
| `mart_indirim_kar` | İndirim oranı | Sipariş sayacı, ciro, kâr ve kâr marjı |
| `mart_kanal_satis` | Satış kanalı ve hava durumu | Sipariş sayacı, ciro ve ortalama kayıt tutarı |
| `mart_mevsimsel_urun` | Mevsim ve kategori | Satılan ürün adedi ve ciro |
| `yagisvesatislar` | Ürün | Yağışlı koşullarda satılan adet, toplam adet, yağışlı satış payı ve endeks |
| `kategori_kar_marji` | Şehir ve kategori | Satış adedi, ciro, maliyet, kâr ve kâr marjı için tasarlanmış model; sütun uyarlaması gerekiyor |

### Yağış Endeksi Nasıl Okunur?

Yağış endeksi, bir ürünün yağışlı koşullardaki adet payını, eşleşen tüm satışların yağışlı koşullardaki adet payına böler.

- **1'in üzerinde:** Ürünün satışları, genel dağılıma göre yağışlı koşullarda daha fazla yoğunlaşmıştır.
- **1'e eşit:** Ürün, genel dağılımla aynı yağışlı satış payına sahiptir.
- **1'in altında:** Ürünün yağışlı satış payı genel dağılımın altındadır.

Bu ölçüt günlük ortalama satış artışı değildir. Mevcut model, hava durumu açıklamasında `rain`, `drizzle` veya `snow` geçen kayıtları yağışlı olarak sınıflandırır.

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Projedeki görevi |
|---|---|
| **SQL** | Veri dönüştürme, birleştirme, hesaplama ve özetleme |
| **dbt** | Model bağımlılıklarını, seed yüklemelerini ve testleri yönetme |
| **DuckDB** | Yerel analitik veritabanı; depoda `dev.duckdb` dosyası bulunur |
| **CSV** | Ham satış ve hava durumu verilerinin saklanması |
| **GitHub** | Kod ve proje dokümantasyonunun paylaşılması |

Depoda hazır bir dashboard veya grafik çıktısı bulunmamaktadır. Projenin mevcut çıktısı analiz modelleridir.

## 🚀 Kurulum ve Çalıştırma

### 1. Depoyu klonlayın

```bash
git clone https://github.com/salihsvm123-source/5.Grup.git
cd 5.Grup/nova_dbt
```

### 2. Sanal ortam oluşturun

```bash
python -m venv .venv
```

**Windows PowerShell:**

```powershell
.\.venv\Scripts\Activate.ps1
```

**macOS / Linux:**

```bash
source .venv/bin/activate
```

### 3. dbt DuckDB adaptörünü yükleyin

```bash
python -m pip install dbt-duckdb
```

Depoda sabitlenmiş bağımlılık dosyası bulunmadığından bu komut belirli bir sürümü hedeflemez.

### 4. Veritabanı bağlantısını tanımlayın

Kullanıcı dizininizdeki `~/.dbt/profiles.yml` dosyasına aşağıdaki profili ekleyin. Windows'ta bu konum kullanıcı klasörünüzün altındaki `.dbt\profiles.yml` dosyasıdır.

```yaml
nova_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb
      threads: 1
```

Profil adı, `dbt_project.yml` içindeki `nova_dbt` değeriyle aynı olmalıdır. Komutları `nova_dbt` klasöründen çalıştırın; göreli veritabanı yolu bu çalışma düzeni içindir.

### 5. Bağlantıyı kontrol edin ve verileri yükleyin

```bash
dbt debug
dbt seed
```

### 6. Modelleri oluşturun ve testleri çalıştırın

Kategori kârlılığı modelindeki mevcut sütun uyuşmazlığı giderilene kadar diğer modelleri çalıştırmak için:

```bash
dbt run --exclude kategori_kar_marji
dbt test
```

İlgili model düzeltildikten sonra tüm modeller için:

```bash
dbt run
dbt test
```

> Bu adımlar kurulum rehberidir. Deponun mevcut sürümünün baştan sona başarıyla çalıştığı doğrulanmış değildir; aşağıdaki sınırlamalar dikkate alınmalıdır.

## 📁 Proje Yapısı

| Yol | Açıklama |
|---|---|
| `dbt_project.yml` | Proje, klasör ve seed ayarları |
| `seeds/perakende_satis.csv` | Ham satış verileri |
| `seeds/hava_durumu.csv` | Ham hava durumu verileri |
| `models/staging/satislar.sql` | Satış alanlarının hazırlanması ve finansal hesaplamalar |
| `models/staging/stg_hava_durumu.sql` | Hava durumu verisinin hazırlanması ve 2024 filtresi |
| `models/marts/` | Analiz modelleri |
| `models/marts/schema.yml` | Model açıklamaları ve sütun testleri |
| `tests/kontroller.sql` | Özel veri kalite kontrolleri |
| `dev.duckdb` | Depoda bulunan yerel veritabanı dosyası |
| `analyses/` ve `snapshots/` | İleride kullanılabilecek, şu anda boş klasörler |

## ✅ Veri Kalitesi Kontrolleri

Mevcut test tanımları şunları kapsar:

- Belirli kategori, zaman dilimi, kanal ve diğer analiz alanlarında boş değer kontrolü.
- Hava durumu özeti, indirim oranı ve ürün bazında benzersizlik kontrolü.
- Mevsimsel ciroda negatif değer kontrolü.
- İndirim oranının 0–1 aralığında olması.
- Belirli sipariş ve yağışlı satış adetlerinin negatif olmaması.

Bu kontrollerin tanımlanmış olması, testlerin başarıyla geçtiği anlamına gelmez.

## ⚠️ Mevcut Sınırlamalar

- **Kategori kârlılığı modeli:** `kategori_kar_marji.sql`, satış modelinde bulunmayan `ciro`, `toplam_maliyet` ve `kar` alanlarını kullanır. Modelin mevcut `toplam_ciro`, `miktar`, `maliyet` ve `net_kar` alanlarına göre uyarlanması gerekir.
- **Eşleşmeyen kayıtlar:** Hava durumuyla birleştirilen analizler `inner join` kullanır. Şehir ve tarih eşleşmesi bulunmayan satışlar bu analizlere dahil edilmez.
- **Eşleşme kalitesi:** Şehir adlarında büyük harfe çevirme ve kenar boşluklarını temizleme uygulanır. Farklı yazımların ve şehir–tarih bazındaki olası yinelenen hava kayıtlarının ayrıca kontrol edilmesi gerekir.
- **Sipariş ve sepet ölçümü:** Bazı modeller `count(siparis_id)` ve `avg(toplam_ciro)` kullanır. Aynı sipariş birden fazla satırdaysa bu değerler benzersiz sipariş sayısını ve gerçek ortalama sepet tutarını temsil etmeyebilir.
- **Mevsim analizi:** Mevsimsel model, ayları mevsimlere ayırır; doğrudan sıcaklığa göre analiz yapmaz.
- **Bulgular:** Bu README'de hesaplanmış sonuç, satış artışı yüzdesi veya doğrulanmış işletme önerisi sunulmamaktadır.

## 📌 Geliştirme Planı

- [ ] Kategori kârlılığı modelindeki sütun uyuşmazlığını düzeltmek.
- [ ] Bağımlılık sürümlerini ve çalıştırma ortamını belgelemek.
- [ ] Veri kaynaklarını, kapsamlarını ve kullanım koşullarını açıklamak.
- [ ] Sipariş bazında sepet tutarı hesaplamalarını doğrulamak.
- [ ] Şehir–tarih eşleşmeleri ve yinelenen kayıtlar için kontroller eklemek.
- [ ] Grafikler ve etkileşimli bir raporlama ekranı hazırlamak.
- [ ] Doğrulanmış analiz sonuçlarını ve yorumlarını dokümantasyona eklemek.

## 👥 Proje Ekibi

**5. Grup**

Proje deposu: [salihsvm123-source/5.Grup](https://github.com/salihsvm123-source/5.Grup)

## 📄 Lisans

Depoda ayrı bir lisans dosyası bulunmamaktadır. Kod ve veri kullanım koşulları proje sahipleri tarafından ayrıca belirtilmelidir.

