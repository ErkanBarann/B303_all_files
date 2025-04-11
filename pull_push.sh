#!/bin/bash

# === Bağlantı bilgileri ===
origin_url="https://github.com/ErkanBarann/B303_all_files.git"
upstream_url="https://github.com/techproeducation-batchs/B303-aws-devops.git"

echo "🔁 Senkronizasyon başlatılıyor..."

# === Remote bağlantı kontrolü ===
if ! git remote | grep -q "upstream"; then
  echo "🌐 'upstream' remote ekleniyor..."
  git remote add upstream $upstream_url
fi

# === Upstream fetch ===
echo "📥 Upstream'den veri çekiliyor..."
git fetch upstream

# === Geçici merge alanı oluştur ===
echo "📦 Geçici merge alanı oluşturuluyor..."
git checkout -b temp-merge upstream/main

# === .terraform klasörü varsa sil ===
if [ -d "Devops/Ansible/terraform-files/.terraform" ]; then
  echo "🧹 .terraform klasörü temizleniyor (upstream'den gelen dosyalar)..."
  rm -rf Devops/Ansible/terraform-files/.terraform
  git rm -rf --cached Devops/Ansible/terraform-files/.terraform 2>/dev/null
  echo ".terraform/" >> .gitignore
  git add .gitignore
  git commit -m "Remove .terraform after merging upstream"
fi

# === Ana dala dön ve temp-merge ile birleştir ===
git checkout main
git merge temp-merge --no-edit
git branch -D temp-merge

# === Değişiklik varsa push et ===
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✅ Değişiklik bulundu, commit ve push ediliyor..."
  git add -A
  git commit -m "🔄 Günlük senkronizasyon: $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "🚀 Değişiklikler başarıyla GitHub'a gönderildi."
else
  echo "✅ Güncel. Yapılacak bir şey yok."
fi

echo "🎉 Tüm işlem başarıyla tamamlandı."
