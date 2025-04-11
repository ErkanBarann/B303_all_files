# Araç Kiralama Sistemi 🚗

Bu proje, modern bir araç kiralama platformu sunmaktadır. Flask framework'ü kullanılarak geliştirilmiş, Nginx ve Gunicorn ile deploy edilmiş profesyonel bir web uygulamasıdır.

## 🌟 Özellikler

### 👥 Kullanıcı İşlemleri
- Kullanıcı kaydı ve girişi
- Profil düzenleme
- Şifre sıfırlama
- E-posta doğrulama

### 🚙 Araç İşlemleri
- Araç listeleme ve detaylı arama
- Marka, model, yıl ve fiyat bazlı filtreleme
- Araç detay görüntüleme
- Araç kiralama ve rezervasyon

### 📊 Admin Paneli
- İstatistik görüntüleme
  - Toplam araç sayısı
  - Kullanıcı sayısı
  - Kiralama sayısı
  - Toplam gelir
- Araç yönetimi
- Kullanıcı yönetimi
- Kiralama takibi

## 🛠️ Teknolojiler

- **Backend:** Python Flask
- **Frontend:** HTML, CSS, JavaScript
- **Veritabanı:** MySQL
- **Web Sunucusu:** Nginx
- **WSGI Sunucusu:** Gunicorn
- **Deployment:** Ubuntu Server

## 📋 Gereksinimler

\`\`\`bash
python3
python3-venv
mysql-server
nginx
\`\`\`

## 🚀 Kurulum

1. **Repo'yu klonlayın:**
\`\`\`bash
git clone https://github.com/kullanici/arac-kiralama.git
cd arac-kiralama
\`\`\`

2. **Çevresel değişkenleri ayarlayın:**
\`\`\`bash
cp .env.example .env
# .env dosyasını düzenleyin
\`\`\`

3. **Virtual environment oluşturun:**
\`\`\`bash
python3 -m venv venv
source venv/bin/activate
\`\`\`

4. **Bağımlılıkları yükleyin:**
\`\`\`bash
pip install -r requirements.txt
\`\`\`

5. **Veritabanını oluşturun:**
\`\`\`bash
mysql -u root -p
CREATE DATABASE arac_kiralama;
\`\`\`

6. **Uygulamayı başlatın:**
\`\`\`bash
./deploy.sh
\`\`\`

## 🔧 Deployment

Deployment için gerekli dosyalar:

1. **Nginx Yapılandırması:**
\`\`\`nginx
server {
    listen 80;
    server_name your_domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
\`\`\`

2. **Gunicorn Servis Dosyası:**
\`\`\`ini
[Unit]
Description=Gunicorn instance for car rental app
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/path/to/app
ExecStart=/path/to/venv/bin/gunicorn --workers 4 wsgi:app

[Install]
WantedBy=multi-user.target
\`\`\`

## 📝 Kullanım

1. \`/register\` - Yeni kullanıcı kaydı
2. \`/login\` - Kullanıcı girişi
3. \`/arama\` - Araç arama
4. \`/profil\` - Profil düzenleme
5. \`/istatistikler\` - Admin istatistikleri

## 👥 Roller

- **Normal Kullanıcı:**
  - Araç arama ve görüntüleme
  - Kiralama yapma
  - Profil düzenleme

- **Admin:**
  - Tüm kullanıcı yetkileri
  - İstatistik görüntüleme
  - Araç ve kullanıcı yönetimi

## 🔒 Güvenlik

- Şifre hashleme
- SQL injection koruması
- XSS koruması
- CSRF koruması
- Rate limiting

## 📈 Performans

- Nginx reverse proxy
- Gunicorn multi-worker
- Veritabanı indeksleme
- Statik dosya önbellekleme

## 🤝 Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun
3. Değişikliklerinizi commit'leyin
4. Branch'inizi push'layın
5. Pull request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- Website: [www.techprodevops.com](http://www.techprodevops.com)
- Email: [info@techprodevops.com](mailto:info@techprodevops.com)

## 🙏 Teşekkürler

Bu projeye katkıda bulunan herkese teşekkürler!

---

⭐️ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
