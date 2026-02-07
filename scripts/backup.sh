#!/bin/bash

# Personal Finance Bot - Backup Script
# PostgreSQL veritabanı ve Excel dosyalarının yedeğini alır

set -e

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "💾 Kişisel Finans Botu Yedekleme İşlemi"
echo ""

# .env dosyasını yükle
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env dosyası bulunamadı!${NC}"
    exit 1
fi

source .env

# Yedekleme dizinini oluştur
BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"

mkdir -p "$BACKUP_PATH"

echo "📁 Yedekleme dizini: $BACKUP_PATH"
echo ""

# PostgreSQL container'ının çalışıp çalışmadığını kontrol et
if ! docker ps | grep -q finance-postgres; then
    echo -e "${RED}❌ PostgreSQL container'ı çalışmıyor!${NC}"
    echo "Servisleri başlatmak için: docker-compose up -d"
    exit 1
fi

# PostgreSQL veritabanı yedeği
echo "🗄️  PostgreSQL veritabanı yedekleniyor..."
docker exec finance-postgres pg_dump -U $POSTGRES_USER -d $POSTGRES_DB > "$BACKUP_PATH/database_backup.sql"

if [ -f "$BACKUP_PATH/database_backup.sql" ]; then
    DBSIZE=$(du -h "$BACKUP_PATH/database_backup.sql" | cut -f1)
    echo -e "${GREEN}✅ Veritabanı yedeklendi (Boyut: $DBSIZE)${NC}"
else
    echo -e "${RED}❌ Veritabanı yedeği başarısız!${NC}"
    exit 1
fi

echo ""

# Excel dosyası yedeği (eğer varsa)
echo "📊 Excel dosyası yedekleniyor..."

# Excel dosyasını docker volume'den kopyala
EXCEL_CONTAINER_PATH="/data/finance_records.xlsx"
EXCEL_EXISTS=$(docker exec finance-n8n test -f $EXCEL_CONTAINER_PATH && echo "yes" || echo "no")

if [ "$EXCEL_EXISTS" = "yes" ]; then
    docker cp finance-n8n:$EXCEL_CONTAINER_PATH "$BACKUP_PATH/finance_records.xlsx" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Excel dosyası kopyalanamadı (dosya henüz oluşturulmamış olabilir)${NC}"
    }
    
    if [ -f "$BACKUP_PATH/finance_records.xlsx" ]; then
        EXCELSIZE=$(du -h "$BACKUP_PATH/finance_records.xlsx" | cut -f1)
        echo -e "${GREEN}✅ Excel dosyası yedeklendi (Boyut: $EXCELSIZE)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Excel dosyası henüz oluşturulmamış${NC}"
fi

echo ""

# Yedekleme bilgilerini kaydet
cat > "$BACKUP_PATH/backup_info.txt" << EOF
Yedekleme Bilgileri
===================
Tarih: $(date)
PostgreSQL Veritabanı: $POSTGRES_DB
Kullanıcı: $POSTGRES_USER

Yedeklenen Dosyalar:
- database_backup.sql (PostgreSQL dump)
$([ -f "$BACKUP_PATH/finance_records.xlsx" ] && echo "- finance_records.xlsx (Excel dosyası)")

Geri Yükleme:
-------------
PostgreSQL:
  cat database_backup.sql | docker exec -i finance-postgres psql -U $POSTGRES_USER -d $POSTGRES_DB

Excel:
  docker cp finance_records.xlsx finance-n8n:/data/finance_records.xlsx
EOF

echo -e "${GREEN}✅ Yedekleme bilgileri kaydedildi${NC}"
echo ""

# Eski yedekleri temizle (30 günden eski)
echo "🧹 Eski yedekler temizleniyor (30 günden eski)..."
find "$BACKUP_DIR" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
echo -e "${GREEN}✅ Temizlik tamamlandı${NC}"
echo ""

# Yedekleme özeti
echo "=========================================="
echo -e "${GREEN}✅ Yedekleme Tamamlandı!${NC}"
echo "=========================================="
echo ""
echo "📁 Yedekleme konumu: $BACKUP_PATH"
echo ""
echo "📋 İçerik:"
ls -lh "$BACKUP_PATH"
echo ""
echo "💡 Geri yükleme için backup_info.txt dosyasına bakın"
echo ""

# Yedekleme dosyasını sıkıştır (opsiyonel)
read -p "Yedeklemeyi sıkıştırmak ister misiniz? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗜️  Yedekleme sıkıştırılıyor..."
    tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "$TIMESTAMP"
    
    if [ -f "$BACKUP_PATH.tar.gz" ]; then
        ARCHIVESIZE=$(du -h "$BACKUP_PATH.tar.gz" | cut -f1)
        echo -e "${GREEN}✅ Yedekleme arşivi oluşturuldu: $BACKUP_PATH.tar.gz (Boyut: $ARCHIVESIZE)${NC}"
        
        read -p "Orijinal klasörü silmek ister misiniz? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$BACKUP_PATH"
            echo -e "${GREEN}✅ Orijinal klasör silindi${NC}"
        fi
    fi
fi

echo ""
echo "🎉 Yedekleme işlemi başarıyla tamamlandı!"
echo ""
