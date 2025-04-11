#!/bin/bash

# === Bağlantı bilgileri ===
origin_url="https://github.com/ErkanBarann/B303_all_files.git"
upstream_url="https://github.com/techproeducation-batchs/B303-aws-devops.git"

echo "🔁 Senkronizasyon başlatılıyor..."

# === Remote bağlantı kontrolü ===
echo "🔍 Remote bağlantıları kontrol ediliyor..."
if ! git remote | grep -q "upstream"; then
  echo "🌐 'upstream' remote ekleniyor..."
  git remote add upstream $upstream_url
fi

# === .terraform klasörü varsa sil ===
if [ -d "Devops/Ansible/terraform-files/.terraform" ]; then
  echo "🧹 Büyük dosyalar içeren .terraform klasörü temizleniyor..."
  rm -rf Devops/Ansible/terraform-files/.terraform
  git rm -rf --cached Devops/Ansible/terraform-files/.terraform 2>/dev/null
  echo ".terraform/" >> .gitignore
fi

# === Git Merge ve Çakışma Kontrolü ===
echo "📥 Upstream'den veri çekiliyor..."
git fetch upstream

echo "🔄 Merge işlemi başlatılıyor..."
git merge upstream/main --allow-unrelated-histories --no-edit
if [ $? -ne 0 ]; then
  echo "❌ Merge sırasında çakışma oluştu. İşlem iptal edildi."
  git merge --abort
  exit 1
fi

# === Değişiklik kontrolü ===
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
