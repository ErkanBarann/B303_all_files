#!/bin/bash

echo "🔁 Akıllı senkronizasyon başlatılıyor..."

# 1. Bağlantıları göster
echo "🔍 Remote bağlantıları:"
git remote -v

# 2. Upstream'deki yeni şeyleri kontrol et (fetch yap ama pull değil)
echo "📥 Upstream kontrol ediliyor..."
git fetch upstream

LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse upstream/main)

# 3. Değişiklik varsa merge et (ama çakışmaları otomatik çöz)
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
  echo "🔄 Upstream'de değişiklik bulundu, güncelleniyor..."
  git merge -X theirs upstream/main --no-edit
else
  echo "✅ Upstream güncel, çekmeye gerek yok."
fi

# 4. Gereksiz dosya klasörü varsa sil
if [ -d "Devops/Ansible/terraform-files/.terraform" ]; then
  echo "🧹 .terraform klasörü siliniyor..."
  rm -rf Devops/Ansible/terraform-files/.terraform
fi

# 5. Lokal değişiklik varsa commit & push
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✅ Lokal değişiklik bulundu, push ediliyor..."
  git add -A
  git commit -m "🧠 Akıllı sync: $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "🚀 Push başarılı!"
else
  echo "🟢 Lokal repon da güncel. Push gerekmedi."
fi

echo "🎉 İşlem tamamlandı."
