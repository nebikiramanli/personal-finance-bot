# 📚 Detaylı Kurulum Kılavuzu

Bu kılavuz, Kişisel Finans Botu'nu sıfırdan kurmak için gereken tüm adımları detaylı bir şekilde açıklar.

## İçindekiler

1. [Sistem Gereksinimleri](#sistem-gereksinimleri)
2. [Docker Kurulumu](#docker-kurulumu)
3. [Telegram Bot Oluşturma](#telegram-bot-oluşturma)
4. [Chat ID Öğrenme](#chat-id-öğrenme)
5. [Proje Kurulumu](#proje-kurulumu)
6. [Environment Değişkenlerini Ayarlama](#environment-değişkenlerini-ayarlama)
7. [Servisleri Başlatma](#servisleri-başlatma)
8. [n8n Yapılandırması](#n8n-yapılandırması)
9. [Workflow Import İşlemi](#workflow-import-işlemi)
10. [İlk Test](#ilk-test)
11. [Sorun Giderme](#sorun-giderme)

---

## Sistem Gereksinimleri

### Minimum Gereksinimler
- **İşletim Sistemi**: Linux, macOS, veya Windows (WSL2 ile)
- **RAM**: 8 GB (Ollama LLM için)
- **Disk Alanı**: 10 GB boş alan
- **CPU**: 4 çekirdek (önerilen)
- **İnternet**: İlk kurulum için (model indirme)

### Önerilen Gereksinimler
- **RAM**: 16 GB
- **Disk Alanı**: 20 GB SSD
- **CPU**: 8 çekirdek
- **GPU**: NVIDIA GPU (opsiyonel, LLM hızlandırma için)

---

## Docker Kurulumu

### Linux (Ubuntu/Debian)

```bash
# Docker deposunu ekle
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker'ı yükle
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker'ı kullanıcı olarak çalıştır (opsiyonel)
sudo usermod -aG docker $USER
newgrp docker

# Test et
docker --version
docker compose version
```

### macOS

1. [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) indirin
2. DMG dosyasını açın ve Docker'ı Applications klasörüne sürükleyin
3. Docker Desktop'ı başlatın
4. Terminal'de test edin:
```bash
docker --version
docker compose version
```

### Windows

1. [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) indirin
2. WSL 2'yi etkinleştirin (gerekirse)
3. Docker Desktop'ı yükleyin
4. PowerShell veya WSL terminalinde test edin:
```bash
docker --version
docker compose version
```

---

## Telegram Bot Oluşturma

### Adım 1: BotFather ile İletişime Geç

1. Telegram uygulamasını açın
2. Arama kutusuna **@BotFather** yazın
3. BotFather'a tıklayın ve **Start** butonuna basın

### Adım 2: Yeni Bot Oluştur

1. BotFather'a şu komutu gönderin:
```
/newbot
```

2. Bot için bir isim girin (örnek: **Kişisel Finans Botum**)

3. Bot için benzersiz bir kullanıcı adı girin (bot ile bitmeli):
```
my_personal_finance_bot
```

4. BotFather size bir **token** verecek:
```
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567
```

**⚠️ ÖNEMLİ**: Bu token'ı güvenli bir yerde saklayın!

### Adım 3: Bot Ayarlarını Yapılandır (Opsiyonel)

Bot açıklaması ekle:
```
/setdescription
```

Bot komutları ekle:
```
/setcommands
```

Ardından şu komutları yapıştırın:
```
ekle - Manuel kayıt girişi yap
```

---

## Chat ID Öğrenme

### Yöntem 1: userinfobot Kullanma

1. Telegram'da **@userinfobot** botunu arayın
2. Bota **Start** deyin veya herhangi bir mesaj gönderin
3. Bot size ID'nizi verecek:
```
Your ID: 123456789
```

Bu numarayı not alın!

### Yöntem 2: API ile Öğrenme

1. Botunuza bir mesaj gönderin
2. Tarayıcıda şu URL'yi açın (TOKEN yerine bot token'ınızı yazın):
```
https://api.telegram.org/bot<TOKEN>/getUpdates
```

3. JSON yanıtında `chat.id` değerini bulun

---

## Proje Kurulumu

### Adım 1: Repoyu Klonlayın

```bash
cd ~
git clone https://github.com/nebikiramanli/personal-finance-bot.git
cd personal-finance-bot
```

### Adım 2: Dizin Yapısını Kontrol Edin

```bash
ls -la
```

Şu dosyaları görmelisiniz:
```
docker-compose.yml
.env.example
README.md
db/
n8n/
ollama/
scripts/
docs/
```

---

## Environment Değişkenlerini Ayarlama

### Adım 1: .env Dosyası Oluştur

```bash
cp .env.example .env
```

### Adım 2: .env Dosyasını Düzenle

```bash
nano .env
```

veya tercih ettiğiniz editörle açın.

### Adım 3: Değerleri Güncelle

```env
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567
ALLOWED_CHAT_ID=123456789

# PostgreSQL Configuration
POSTGRES_USER=finance_user
POSTGRES_PASSWORD=BuradaGüvenliŞifreYazın123!
POSTGRES_DB=personal_finance
POSTGRES_PORT=5432

# n8n Configuration
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=n8nAdminŞifren456!
N8N_ENCRYPTION_KEY=RastgeleUzunBirStringBurayaYaz789!XyZ
N8N_PORT=5678

# Ollama Configuration
OLLAMA_MODEL=llama3.1
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_PORT=11434

# Tesseract OCR Configuration
TESSERACT_API_URL=http://tesseract:8884
TESSERACT_PORT=8884

# Excel Configuration
EXCEL_FILE_PATH=/data/finance_records.xlsx

# Timezone
TZ=Europe/Istanbul
```

**⚠️ ÖNEMLİ**: 
- Güvenli şifreler kullanın
- N8N_ENCRYPTION_KEY en az 32 karakter olmalı
- TELEGRAM_BOT_TOKEN ve ALLOWED_CHAT_ID değerlerini mutlaka güncelleyin

### Güvenli Şifre Oluşturma

Linux/macOS:
```bash
openssl rand -base64 32
```

veya online araçlar kullanabilirsiniz (güvenilir sitelerden).

---

## Servisleri Başlatma

### Otomatik Kurulum (Önerilen)

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Script otomatik olarak:
- .env kontrolü yapar
- Docker volume'leri oluşturur
- Servisleri başlatır
- PostgreSQL'i bekler
- Ollama modelini indirir

### Manuel Kurulum

```bash
# Volume'leri oluştur
docker volume create postgres_data
docker volume create n8n_data
docker volume create ollama_data
docker volume create excel_data

# Servisleri başlat
docker compose up -d

# Logları takip et
docker compose logs -f
```

### Servis Durumlarını Kontrol Et

```bash
docker compose ps
```

Tüm servisler **Up** durumunda olmalı:
```
NAME                IMAGE                       STATUS
finance-n8n         n8nio/n8n:latest           Up
finance-postgres    postgres:15-alpine         Up (healthy)
finance-ollama      ollama/ollama:latest       Up
finance-tesseract   hertzg/tesseract-server    Up
```

---

## n8n Yapılandırması

### Adım 1: n8n'e Giriş Yap

1. Tarayıcıda şu adresi açın:
```
http://localhost:5678
```

2. Giriş bilgileri:
   - **Kullanıcı Adı**: admin (veya .env'de belirlediğiniz)
   - **Şifre**: .env'de belirlediğiniz N8N_BASIC_AUTH_PASSWORD

### Adım 2: Telegram Credential Ekle

1. Sol menüden **Settings** → **Credentials** → **Add Credential**
2. "Telegram" arayın ve seçin
3. **Access Token** alanına TELEGRAM_BOT_TOKEN değerini girin
4. Credential için bir isim verin: "Telegram Bot"
5. **Save** butonuna tıklayın

### Adım 3: PostgreSQL Credential Ekle

1. **Settings** → **Credentials** → **Add Credential**
2. "Postgres" arayın ve seçin
3. Bilgileri girin:
   - **Host**: `postgres`
   - **Database**: `personal_finance`
   - **User**: `finance_user`
   - **Password**: .env'deki POSTGRES_PASSWORD
   - **Port**: `5432`
4. Credential için bir isim verin: "Finance DB"
5. **Test Connection** ile test edin
6. **Save** butonuna tıklayın

---

## Workflow Import İşlemi

### Adım 1: İlk Workflow'u Import Et

1. Sol menüden **Workflows** seçin
2. Sağ üstten **Import from File** butonuna tıklayın
3. `n8n/workflows/01_text_message.json` dosyasını seçin
4. Workflow açıldığında, tüm node'ları kontrol edin
5. Credential'ları güncelleyin:
   - Telegram node'larında: "Telegram Bot" seçin
   - PostgreSQL node'larında: "Finance DB" seçin
6. Sağ üstten **Activate** butonuna tıklayın

### Adım 2: Diğer Workflow'ları Import Et

Aynı işlemi şu dosyalar için tekrarlayın:
- `n8n/workflows/02_photo_ocr.json`
- `n8n/workflows/03_manual_entry.json`
- `n8n/workflows/04_reminder.json`

Her workflow için:
1. Import edin
2. Credential'ları güncelleyin
3. Aktifleştirin

### Workflow Kontrolü

**Workflows** sayfasında şu 4 workflow'u görmelisiniz:
- ✅ 01 - Text Message Handler (Active)
- ✅ 02 - Photo OCR Handler (Active)
- ✅ 03 - Manual Entry (Active)
- ✅ 04 - Recurring Payment Reminder (Active)

---

## İlk Test

### Test 1: Basit Metin Mesajı

1. Telegram'da botunuzu bulun (BotFather'dan aldığınız kullanıcı adı)
2. **Start** butonuna basın
3. Şu mesajı gönderin:
```
500 TL market alışverişi
```

4. Bot size şuna benzer bir yanıt vermeli:
```
✅ Kayıt eklendi!

📊 Tür: expense
💰 Tutar: 500.00 TRY
📁 Kategori: market
📝 Açıklama: market alışverişi
📅 Tarih: 2026-02-07
```

### Test 2: Gelir Kaydı

```
Maaşım yattı 25000 TL
```

Bot benzer şekilde yanıt vermeli.

### Test 3: Manuel Giriş

```
/ekle
```

Bot interaktif sorular soracak:
1. Tür (1/2/3)
2. Tutar
3. Kategori
4. Açıklama

### Test 4: Veritabanı Kontrolü

```bash
docker exec -it finance-postgres psql -U finance_user -d personal_finance
```

PostgreSQL'de:
```sql
SELECT * FROM expenses ORDER BY created_at DESC LIMIT 5;
```

Kayıtlarınızı görmelisiniz!

```sql
\q
```

ile çıkın.

---

## Sorun Giderme

### Problem: Bot yanıt vermiyor

**Çözüm 1**: Workflow'ların aktif olduğunu kontrol edin
```
n8n arayüzünde Workflows → Her workflow'un yanında "Active" yazmalı
```

**Çözüm 2**: n8n loglarını kontrol edin
```bash
docker logs finance-n8n -f
```

**Çözüm 3**: Chat ID'yi kontrol edin
```
.env dosyasındaki ALLOWED_CHAT_ID doğru mu?
Telegram'dan aldığınız ID ile eşleşiyor mu?
```

**Çözüm 4**: Bot token'ı kontrol edin
```
.env dosyasındaki TELEGRAM_BOT_TOKEN doğru mu?
BotFather'dan aldığınız token ile aynı mı?
```

### Problem: Ollama modeli inmiyor

**Çözüm**:
```bash
# Manuel olarak model indirin
docker exec -it finance-ollama ollama pull llama3.1

# Model listesini kontrol edin
docker exec -it finance-ollama ollama list
```

### Problem: PostgreSQL başlamıyor

**Çözüm 1**: Logları kontrol edin
```bash
docker logs finance-postgres
```

**Çözüm 2**: Volume'u sıfırlayın
```bash
docker-compose down -v
docker volume rm postgres_data
docker-compose up -d
```

⚠️ Bu işlem tüm verileri siler!

### Problem: n8n'e erişemiyorum

**Çözüm 1**: Port kontrolü
```bash
sudo lsof -i :5678
```

Başka bir uygulama port 5678'i kullanıyorsa, .env'de farklı bir port belirleyin.

**Çözüm 2**: Container durumunu kontrol edin
```bash
docker ps | grep n8n
docker logs finance-n8n
```

### Problem: Tesseract OCR çalışmıyor

**Çözüm**:
```bash
# Tesseract loglarını kontrol edin
docker logs finance-tesseract

# Test isteği gönderin
curl http://localhost:8884/health
```

### Problem: Düşük güven skoru uyarısı

Bu normal! LLM mesajınızı tam anlayamadıysa güven skoru düşük olur.

**Çözüm**:
- Daha açık ve detaylı mesajlar yazın
- Önemli bilgileri (tutar, kategori) belirtin
- Tarih belirtmeyi unutmayın

---

## İleri Seviye Yapılandırma

### GPU Desteği (NVIDIA)

`docker-compose.yml` dosyasında Ollama servisinin altındaki GPU kısmını aktifleştirin:

```yaml
ollama:
  # ...
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
```

### Düzenli Ödeme Ekleme

PostgreSQL'e bağlanın:
```bash
docker exec -it finance-postgres psql -U finance_user -d personal_finance
```

Yeni ödeme ekleyin:
```sql
INSERT INTO recurring_payments (name, type, amount, currency, due_day, category, description)
VALUES ('İnternet Faturası', 'bill', 420.00, 'TRY', 5, 'Fatura', 'Aylık ev internet faturası');
```

### Farklı Zaman Dilimi

.env dosyasında:
```env
TZ=America/New_York
```

### Farklı LLM Modeli

Ollama'da başka bir model kullanmak için:

```bash
# Mevcut modelleri listele
docker exec finance-ollama ollama list

# Yeni model indir
docker exec finance-ollama ollama pull llama2

# .env'de değiştir
OLLAMA_MODEL=llama2
```

---

## Bakım ve Güncelleme

### Yedek Alma

```bash
./scripts/backup.sh
```

Yedekler `backups/` klasörüne kaydedilir.

### Güncelleme

```bash
git pull origin main
docker-compose down
docker-compose pull
docker-compose up -d
```

### Temizlik

Kullanılmayan Docker kaynaklarını temizleyin:
```bash
docker system prune -a
```

---

## Sonuç

Tebrikler! 🎉 Kişisel Finans Botunuzu başarıyla kurdunuz.

Artık:
- ✅ Telegram'dan harcamalarınızı kaydedebilirsiniz
- ✅ Fotoğraflarla fatura ekleyebilirsiniz
- ✅ Otomatik hatırlatıcılar alabilirsiniz
- ✅ Verileriniz güvende, local olarak saklanıyor

### Yardım ve Destek

Sorunlarınız için:
- GitHub Issues: [https://github.com/nebikiramanli/personal-finance-bot/issues](https://github.com/nebikiramanli/personal-finance-bot/issues)
- README.md dosyasına bakın
- Docker loglarını inceleyin

### İyi Kullanımlar! 💰📊
