#!/bin/bash

echo "🔁 Günlük senkronizasyon başlatılıyor..."

# 1. Git bağlantılarını kontrol et
echo "🔍 Remote bağlantıları:"
git remote -v

# 2. Upstream'den güncel veriyi çek
echo "📥 Upstream'den veri çekiliyor..."
git pull upstream main

# 3. Gereksiz .terraform klasörü varsa sil
if [ -d "Devops/Ansible/terraform-files/.terraform" ]; then
  echo "🧹 .terraform klasörü siliniyor..."
  rm -rf Devops/Ansible/terraform-files/.terraform
fi

# 4. Değişiklik var mı kontrol et
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✅ Değişiklik bulundu, commit ve push ediliyor..."
  git add -A
  git commit -m "🔄 Günlük senkronizasyon: $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "🚀 Push başarılı!"
else
  echo "✅ Güncel. Değişiklik yok."
fi

echo "🎉 İşlem tamamlandı."
