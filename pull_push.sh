#!/bin/bash

# === Bağlantı Bilgisi ===
origin_url="https://github.com/ErkanBarann/B303_all_files.git"
upstream_url="https://github.com/techproeducation-batchs/B303-aws-devops.git"

# === Başlangıç ===
echo "🔁 Senkronizasyon başlatılıyor..."

# === Remote kontrol ===
echo "🔍 Remote bağlantıları kontrol ediliyor..."
if ! git remote | grep -q "upstream"; then
  echo "🌐 'upstream' ekleniyor..."
  git remote add upstream $upstream_url
fi

# === Fetch ve Merge ===
echo "📥 Upstream'den en son güncelleme çekiliyor..."
git fetch upstream

echo "🔄 Merge işlemi (unrelated histories destekli)..."
git merge upstream/main --allow-unrelated-histories --no-edit

# === Fark var mı kontrol et ===
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✅ Değişiklik bulundu, commit ve push ediliyor..."
  git add -A
  git commit -m "Günlük senkronizasyon: $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "🚀 Değişiklikler başarıyla GitHub'a gönderildi."
else
  echo "✅ Güncel. Yapılacak bir şey yok."
fi

echo "🎉 İşlem tamamlandı."
