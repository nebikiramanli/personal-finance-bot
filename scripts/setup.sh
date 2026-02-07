#!/bin/bash

# Personal Finance Bot - Setup Script
# Bu script, ilk kurulum için gerekli tüm adımları gerçekleştirir

set -e

echo "🚀 Kişisel Finans Botu Kurulumu Başlıyor..."
echo ""

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Docker ve Docker Compose kontrolü
echo "🔍 Docker kontrolü yapılıyor..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker yüklü değil! Lütfen önce Docker'ı yükleyin.${NC}"
    echo "Kurulum için: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose yüklü değil! Lütfen önce Docker Compose'u yükleyin.${NC}"
    echo "Kurulum için: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker ve Docker Compose yüklü${NC}"
echo ""

# .env dosyası kontrolü
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env dosyası bulunamadı. .env.example'dan kopyalanıyor...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}📝 Lütfen .env dosyasını düzenleyin ve gerekli değerleri girin:${NC}"
    echo "   - TELEGRAM_BOT_TOKEN: Telegram bot token'ınız"
    echo "   - ALLOWED_CHAT_ID: Telegram chat ID'niz"
    echo "   - POSTGRES_PASSWORD: Güvenli bir PostgreSQL şifresi"
    echo "   - N8N_BASIC_AUTH_PASSWORD: n8n admin şifresi"
    echo "   - N8N_ENCRYPTION_KEY: Rastgele bir şifreleme anahtarı"
    echo ""
    echo "Değişiklikleri yaptıktan sonra bu scripti tekrar çalıştırın."
    exit 0
fi

echo -e "${GREEN}✅ .env dosyası mevcut${NC}"
echo ""

# .env dosyasını yükle
source .env

# Gerekli değişkenlerin kontrolü
echo "🔍 Environment değişkenleri kontrol ediliyor..."
MISSING_VARS=0

if [ "$TELEGRAM_BOT_TOKEN" = "your_bot_token_here" ]; then
    echo -e "${RED}❌ TELEGRAM_BOT_TOKEN ayarlanmamış${NC}"
    MISSING_VARS=1
fi

if [ "$ALLOWED_CHAT_ID" = "your_chat_id_here" ]; then
    echo -e "${RED}❌ ALLOWED_CHAT_ID ayarlanmamış${NC}"
    MISSING_VARS=1
fi

if [ "$POSTGRES_PASSWORD" = "secure_password_here" ]; then
    echo -e "${YELLOW}⚠️  POSTGRES_PASSWORD varsayılan değerde, güvenli bir şifre belirleyin${NC}"
fi

if [ "$N8N_BASIC_AUTH_PASSWORD" = "secure_password_here" ]; then
    echo -e "${YELLOW}⚠️  N8N_BASIC_AUTH_PASSWORD varsayılan değerde, güvenli bir şifre belirleyin${NC}"
fi

if [ $MISSING_VARS -eq 1 ]; then
    echo ""
    echo -e "${RED}Lütfen .env dosyasını düzenleyin ve eksik değerleri girin.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Gerekli environment değişkenleri ayarlanmış${NC}"
echo ""

# Docker volume'lerini oluştur
echo "📦 Docker volume'leri oluşturuluyor..."
docker volume create postgres_data 2>/dev/null || true
docker volume create n8n_data 2>/dev/null || true
docker volume create ollama_data 2>/dev/null || true
docker volume create excel_data 2>/dev/null || true
echo -e "${GREEN}✅ Volume'ler hazır${NC}"
echo ""

# Docker Compose ile servisleri başlat
echo "🚀 Docker servisleri başlatılıyor..."
echo "Bu işlem birkaç dakika sürebilir (özellikle ilk çalıştırmada)..."
echo ""

if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

echo ""
echo -e "${GREEN}✅ Servisler başlatıldı${NC}"
echo ""

# PostgreSQL'in hazır olmasını bekle
echo "⏳ PostgreSQL veritabanının hazır olması bekleniyor..."
sleep 10

MAX_TRIES=30
COUNT=0
until docker exec finance-postgres pg_isready -U $POSTGRES_USER -d $POSTGRES_DB &> /dev/null || [ $COUNT -eq $MAX_TRIES ]; do
    echo "   Bekleniyor... ($COUNT/$MAX_TRIES)"
    sleep 2
    COUNT=$((COUNT + 1))
done

if [ $COUNT -eq $MAX_TRIES ]; then
    echo -e "${RED}❌ PostgreSQL başlatılamadı. Loglara bakın: docker logs finance-postgres${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL hazır${NC}"
echo ""

# Ollama modelini indir
echo "🤖 Ollama LLaMA 3.1 modeli indiriliyor..."
echo "Bu işlem model boyutuna bağlı olarak uzun sürebilir (birkaç GB)..."
docker exec finance-ollama ollama pull llama3.1 || {
    echo -e "${YELLOW}⚠️  Model indirme başarısız oldu. Manuel olarak şu komutu çalıştırabilirsiniz:${NC}"
    echo "   docker exec finance-ollama ollama pull llama3.1"
}
echo ""

# Kurulum tamamlandı
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Kurulum Tamamlandı!${NC}"
echo "=========================================="
echo ""
echo "📌 Servis Durumları:"
echo "   n8n:        http://localhost:$N8N_PORT"
echo "   PostgreSQL: localhost:$POSTGRES_PORT"
echo "   Ollama:     http://localhost:$OLLAMA_PORT"
echo "   Tesseract:  http://localhost:$TESSERACT_PORT"
echo ""
echo "📝 Sonraki Adımlar:"
echo "   1. n8n'e giriş yapın: http://localhost:$N8N_PORT"
echo "      Kullanıcı adı: $N8N_BASIC_AUTH_USER"
echo "      Şifre: (belirlediğiniz şifre)"
echo ""
echo "   2. n8n'de Credentials ekleyin:"
echo "      - Telegram Bot API (TELEGRAM_BOT_TOKEN ile)"
echo "      - PostgreSQL (veritabanı bağlantısı için)"
echo ""
echo "   3. Workflow'ları import edin:"
echo "      n8n/workflows/ klasöründeki 4 JSON dosyasını"
echo "      n8n arayüzünden import edin"
echo ""
echo "   4. Telegram botunuzu test edin:"
echo "      Botunuza mesaj göndererek test edin"
echo ""
echo "🔧 Yönetim Komutları:"
echo "   - Servisleri durdur:    docker-compose down"
echo "   - Servisleri başlat:    docker-compose up -d"
echo "   - Logları görüntüle:    docker-compose logs -f"
echo "   - Yedek al:             ./scripts/backup.sh"
echo ""
echo "📚 Detaylı bilgi için: docs/SETUP_GUIDE.md"
echo ""
