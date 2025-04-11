<<<<<<< HEAD
# Car Rental System 🚗

This project offers a modern car rental platform. It is a professional web application developed using the Flask framework and deployed with Nginx and Gunicorn.

## 🌟 Features

### 👥 User Operations
- User registration and login
- Profile editing
- Password reset
- Email verification

### 🚙 Vehicle Operations
- Vehicle listing and detailed search
- Filtering by brand, model, year, and price
- Viewing vehicle details
- Vehicle rental and reservation

### 📊 Admin Panel
- Viewing statistics
  - Total number of vehicles
  - Number of users
  - Number of rentals
  - Total revenue
- Vehicle management
- User management
- Rental tracking

## 🛠️ Technologies

- **Backend:** Python Flask
- **Frontend:** HTML, CSS, JavaScript
- **Database:** MySQL
- **Web Server:** Nginx
- **WSGI Server:** Gunicorn
- **Deployment:** Ubuntu Server

## 📋 Requirements

```bash
=======
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
>>>>>>> upstream/main
python3
python3-venv
mysql-server
nginx
<<<<<<< HEAD
```

## 🚀 Setup

1. **Clone the repository:**
```bash
git clone https://github.com/ErkanBarann/car-rental-system-with-terraform.git
cd car-rental-system-with-terraform
```

2. **Set up environment variables:**
```bash
cp .env.example .env
# Edit the .env file
```

3. **Create a virtual environment:**
```bash
python3 -m venv venv
source venv/bin/activate
```

4. **Install dependencies:**
```bash
pip install -r requirements.txt
```

5. **Create the database:**
```bash
mysql -u root -p
CREATE DATABASE arac_kiralama;
```

6. **Start the application:**
```bash
./deploy.sh
```

## 🛠️ Terraform Integration

This project is fully integrated with Terraform. The `.tf` files provided in the repository allow you to set up the entire infrastructure, including EC2 instances, networking, and RDS, in a modular and automated manner. Simply follow the Terraform configuration to bring the project to life.

## 🔧 Deployment

Files required for deployment:

1. **Nginx Configuration:**
```nginx
=======
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
>>>>>>> upstream/main
server {
    listen 80;
    server_name your_domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
<<<<<<< HEAD
```

2. **Gunicorn Service File:**
```ini
=======
\`\`\`

2. **Gunicorn Servis Dosyası:**
\`\`\`ini
>>>>>>> upstream/main
[Unit]
Description=Gunicorn instance for car rental app
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/path/to/app
ExecStart=/path/to/venv/bin/gunicorn --workers 4 wsgi:app

[Install]
WantedBy=multi-user.target
<<<<<<< HEAD
```

## 📝 Usage

1. `/register` - New user registration
2. `/login` - User login
3. `/search` - Vehicle search
4. `/profile` - Profile editing
5. `/statistics` - Admin statistics

## 👥 Roles

- **Regular User:**
  - Search and view vehicles
  - Make rentals
  - Edit profile

- **Admin:**
  - All user permissions
  - View statistics
  - Manage vehicles and users

## 🔒 Security

- Password hashing
- SQL injection protection
- XSS protection
- CSRF protection
- Rate limiting

## 📈 Performance

- Nginx reverse proxy
- Gunicorn multi-worker
- Database indexing
- Static file caching

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push your branch
5. Create a pull request

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Thanks to everyone who contributed to this project!

## 🛣️ Road Map

1. **Retrieve Project Files:**
   - Clone the batch GitHub repository containing the project files.
   - Create your own repository and push the files to it.

2. **Terraform Files:**
   - Create `.tf` files adhering to the project architecture.
   - Ensure a modular structure is implemented.

3. **EC2 Instances:**
   - Use Launch Templates to create EC2 instances.
   - AMI should be Ubuntu 24.04 and created using a data source.
   - Instance type: `t2.micro`.

4. **Networking:**
   - Use the default VPC and subnets.

5. **Output:**
   - Generate the DNS name as an output.

6. **User Data:**
   - Provide user data for the instances.

7. **Variables:**
   - Utilize variables for configuration.

8. **RDS Endpoint:**
   - Push the RDS endpoint to the project repository on GitHub using the GitHub provider.

## 🌟 Infrastructure (Terraform)

🎯 **Project Solution Files:** The `.tf` files provided in the repository represent the **resolved state** of the project. These files allow the project to be fully deployed and operational. 🚀



=======
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
>>>>>>> upstream/main
