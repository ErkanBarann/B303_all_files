#!/bin/bash

echo "🔁 Senkronizasyon başlatılıyor..."

# === Değişiklik var mı kontrol et ===
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✅ Değişiklik bulundu, commit ve push ediliyor..."
  git add -A
  git commit -m "🧹 Günlük senkronizasyon: $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "🚀 Değişiklikler başarıyla GitHub'a gönderildi."
else
  echo "✅ Güncel. Yapılacak bir şey yok."
fi

echo "🎉 Tüm işlem tamamlandı."
