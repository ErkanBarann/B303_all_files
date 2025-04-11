#!/bin/bash

# Renkli çıktı için
GREEN='\033[0;32m'
NC='\033[0m' # no color

echo -e "${GREEN}📥 1. Upstream'den en güncel hali çekiliyor...${NC}"
git fetch upstream

echo -e "${GREEN}🔄 2. Upstream main ile birleştiriliyor...${NC}"
git merge upstream/main

echo -e "${GREEN}📂 3. Yeni dosyalar zorla ekleniyor (.gitignore'a rağmen)...${NC}"
git add -f .

echo -e "${GREEN}✅ 4. Commit atılıyor...${NC}"
DATE=$(date '+%Y-%m-%d %H:%M')
git commit -m "🔄 Günlük senkronizasyon: $DATE"

echo -e "${GREEN}🚀 5. GitHub'a push ediliyor...${NC}"
git push origin main

echo -e "${GREEN}🎉 Bitti. Repo güncellendi!${NC}"
