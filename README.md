# 🤖 Kişisel Finans Botu

Telegram üzerinden çalışan, yapay zeka destekli, tamamen yerel (local) kişisel finans takip sistemi.

## 🎯 Özellikler

- ✍️ **Metin Mesajı ile Kayıt**: Telegram'a "850 TL market alışverişi" yazın, otomatik kaydedilsin
- 📸 **Fotoğraf/Fatura Okuma**: Faturanın fotoğrafını atın, OCR ile okusun
- 🧠 **Yerel LLM**: Verileriniz tamamen local, internete gönderilmez (Ollama + LLaMA 3.1)
- 🗄️ **PostgreSQL + Excel**: Güvenli veritabanı + Excel yedeklemesi
- 🔄 **Tekrar Önleme**: Aynı harcamayı tekrar eklenmez
- 🔔 **Hatırlatıcı**: Düzenli ödemeleri (fatura, abonelik) hatırlatır
- 🏦 **Çoklu Kategori**: Harcama, gelir, yatırım takibi
- 🇹🇷 **Türkçe Destek**: Tüm arayüz ve LLM Türkçe

## 🏗️ Teknoloji Yığını

- **n8n**: Workflow orkestrasyon motoru
- **PostgreSQL**: Veritabanı
- **Ollama (LLaMA 3.1)**: Local LLM (AI beyni)
- **Tesseract OCR**: Fotoğraflardan metin çıkarma
- **Telegram Bot API**: Kullanıcı arayüzü
- **Docker**: Tüm sistem containerize

## 🚀 Hızlı Başlangıç

### Ön Gereksinimler

- Docker ve Docker Compose
- Telegram hesabı
- En az 8 GB RAM (Ollama modeli için)
- 10 GB boş disk alanı

### Kurulum

1. **Repoyu klonlayın**
```bash
git clone https://github.com/nebikiramanli/personal-finance-bot.git
cd personal-finance-bot
```

2. **Telegram Bot oluşturun**
   - Telegram'da [@BotFather](https://t.me/botfather) ile konuşun
   - `/newbot` komutu ile yeni bot oluşturun
   - Bot token'ınızı kaydedin

3. **Chat ID'nizi öğrenin**
   - [@userinfobot](https://t.me/userinfobot) botuna mesaj gönderin
   - Size verilen ID numarasını kaydedin

4. **Setup scriptini çalıştırın**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Script size `.env` dosyasını oluşturacak. Gerekli bilgileri girdikten sonra tekrar çalıştırın.

5. **.env dosyasını düzenleyin**
```bash
nano .env
```

Şu değerleri güncelleyin:
- `TELEGRAM_BOT_TOKEN`: BotFather'dan aldığınız token
- `ALLOWED_CHAT_ID`: userinfobot'tan aldığınız ID
- `POSTGRES_PASSWORD`: Güvenli bir şifre
- `N8N_BASIC_AUTH_PASSWORD`: n8n için şifre
- `N8N_ENCRYPTION_KEY`: Rastgele uzun bir string

6. **Servisleri başlatın**
```bash
docker-compose up -d
```

7. **n8n'e giriş yapın**
   - Tarayıcıda `http://localhost:5678` adresine gidin
   - Kullanıcı adı: `admin` (veya .env'de belirlediğiniz)
   - Şifre: .env'de belirlediğiniz şifre

8. **Credentials ekleyin**

   **Telegram Bot Credential:**
   - Settings → Credentials → Add Credential
   - "Telegram" seçin
   - Access Token: TELEGRAM_BOT_TOKEN değerinizi girin
   - Kaydet

   **PostgreSQL Credential:**
   - Settings → Credentials → Add Credential
   - "Postgres" seçin
   - Host: `postgres`
   - Database: `personal_finance`
   - User: `finance_user`
   - Password: .env'deki POSTGRES_PASSWORD
   - Port: `5432`
   - Kaydet

9. **Workflow'ları import edin**
   - n8n arayüzünde → Workflows
   - Her bir JSON dosyası için:
     - `n8n/workflows/01_text_message.json`
     - `n8n/workflows/02_photo_ocr.json`
     - `n8n/workflows/03_manual_entry.json`
     - `n8n/workflows/04_reminder.json`
   - Import → Dosyayı seçin → Workflow'u aktifleştirin

10. **Test edin!**
    - Telegram botunuza mesaj gönderin: "500 TL market"
    - Yanıt almalısınız! 🎉

## 📱 Kullanım

### Metin ile Kayıt

Telegram botunuza doğal dille yazın:

```
850 TL Garanti kartımdan market alışverişi
```

```
Bugün maaşım yattı 25000 TL
```

```
BIST100'den THYAO hissesinden 100 adet aldım, toplam 3500 TL
```

Bot otomatik olarak:
- Türü belirler (harcama/gelir/yatırım)
- Tutarı çıkarır
- Kategoriyi tanır
- Bankayı algılar
- Veritabanına kaydeder
- Size onay mesajı gönderir

### Fotoğraf ile Kayıt

Faturanın, makbuzun veya ekran görüntüsünün fotoğrafını botunuza gönderin. OCR ile okunup otomatik kaydedilecek.

### Manuel Kayıt

```
/ekle
```

Komutu ile adım adım interaktif giriş yapabilirsiniz.

### Hatırlatıcılar

Her gün sabah 09:00'da düzenli ödemeleriniz size hatırlatılır.

## 🗂️ Veritabanı Yapısı

### Harcamalar (expenses)
- Tarih, tutar, kategori, alt kategori
- Banka, ödeme yöntemi
- Açıklama ve güven skoru

### Gelirler (incomes)
- Tarih, tutar, kategori
- Kaynak adı, banka
- Açıklama

### Yatırımlar (investments)
- İşlem türü (alım/satım)
- Varlık türü (hisse/kripto/altın/döviz)
- Miktar, birim fiyat
- Toplam tutar

### Düzenli Ödemeler (recurring_payments)
- İsim, tür, tutar
- Ödeme günü
- Aktif/pasif durum

## 🛡️ Güvenlik

- ✅ **Tek Kullanıcı**: Sadece belirttiğiniz Chat ID erişebilir
- ✅ **Local LLM**: Verileriniz internete gönderilmez
- ✅ **Şifreli n8n**: Basic Auth koruması
- ✅ **Fingerprint**: Tekrar eden kayıtları engeller
- ✅ **PostgreSQL**: Güvenli ve güvenilir veritabanı

## 🔧 Yönetim

### Servisleri Durdur
```bash
docker-compose down
```

### Servisleri Başlat
```bash
docker-compose up -d
```

### Logları Görüntüle
```bash
docker-compose logs -f [servis_adı]
```

Servis adları: `n8n`, `postgres`, `ollama`, `tesseract`

### Yedek Al
```bash
./scripts/backup.sh
```

Veritabanı ve Excel dosyalarının yedeğini `backups/` klasörüne alır.

### Yedekten Geri Yükle
```bash
cat backups/[tarih]/database_backup.sql | docker exec -i finance-postgres psql -U finance_user -d personal_finance
```

## 📊 Excel Yapısı

Excel dosyası otomatik oluşturulur: `/data/finance_records.xlsx`

Sheet'ler otomatik formatlanır:
- `2026_02_expenses` - Şubat 2026 harcamaları
- `2026_02_incomes` - Şubat 2026 gelirleri
- `2026_02_investments` - Şubat 2026 yatırımları

Her ay ve tür için ayrı sheet oluşur.

## 🎨 Özelleştirme

### LLM Prompt'u Değiştirme

`ollama/prompts/finance_parser.txt` dosyasını düzenleyerek LLM'in davranışını özelleştirebilirsiniz.

### Kategorileri Güncelleme

SQL üzerinden veya LLM prompt'unda kategori listesini güncelleyebilirsiniz.

### Düzenli Ödeme Ekleme

```sql
INSERT INTO recurring_payments (name, type, amount, currency, due_day, category, description)
VALUES ('Netflix', 'subscription', 149.99, 'TRY', 1, 'Eğlence', 'Aylık abonelik');
```

## 🐛 Sorun Giderme

### Ollama modeli inmiyor
```bash
docker exec finance-ollama ollama pull llama3.1
```

### PostgreSQL başlamıyor
```bash
docker logs finance-postgres
```

### n8n'e erişemiyorum
Port 5678'in başka bir uygulama tarafından kullanılmadığından emin olun.

### Bot yanıt vermiyor
- Telegram bot token'ı doğru mu?
- Chat ID doğru mu?
- n8n workflow'ları aktif mi?
- n8n credential'lar doğru ayarlanmış mı?

## 🚧 Gelecek Planları

- [ ] Grafik ve raporlama paneli (Grafana entegrasyonu)
- [ ] Bütçe belirleme ve uyarılar
- [ ] Aylık/yıllık özet raporları
- [ ] Kategori bazlı harcama analizleri
- [ ] Multi-currency (çoklu para birimi) desteği
- [ ] Mobil uygulama (React Native)
- [ ] WhatsApp entegrasyonu
- [ ] Banka API entegrasyonları

## 📄 Lisans

MIT License - İstediğiniz gibi kullanabilir, değiştirebilirsiniz.

## 🤝 Katkıda Bulunma

Pull request'ler memnuniyetle karşılanır! Büyük değişiklikler için önce issue açıp tartışalım.

## 📞 İletişim

Sorularınız için GitHub Issues kullanabilirsiniz.

## ⭐ Yıldız Vermeyi Unutmayın!

Projeyi beğendiyseniz yıldız vererek destek olabilirsiniz 🌟

---

**Not**: Bu proje tamamen açık kaynak ve kişisel kullanım içindir. Verileriniz tamamen sizin kontrolünüzde, local olarak saklanır.
