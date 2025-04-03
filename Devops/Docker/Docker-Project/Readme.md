## 📚 **Proje Ödevi: Flask Uygulamasını Docker, Gunicorn ve Nginx ile Deploy Etme**

### **Proje Tanımı:**
Bu projede, Python Flask ile geliştirilmiş bir araç kiralama uygulamasını Docker, Gunicorn, Nginx ve Terraform kullanarak bir EC2 instance’ına deploy etmeniz bekleniyor. Uygulamanız aşağıdaki adımları içermelidir:

1. **Flask Uygulaması:** Python Flask kullanılarak geliştirilmiş basit bir araç kiralama platformu. Bu platform kullanıcıların araç kiralayabilmesi ve araçları görüntüleyebilmesini sağlar.
2. **Docker Compose:** Uygulamanın birden fazla servisten oluşacak şekilde, her servisi bağımsız olarak çalıştıracak şekilde yapılandırılması. Servisler şunlardır:
    - **app**: Flask uygulaması ve Gunicorn
    - **mysql**: MySQL veritabanı
    - **nginx**: Uygulama için reverse proxy görevi görecek Nginx sunucusu.
3. **Nginx Konfigürasyonu:** Nginx, Flask uygulamasını internetten gelen taleplerle yönlendirecek şekilde yapılandırılmalıdır. Nginx, aynı zamanda SSL sertifikalarını da destekleyecek şekilde yapılandırılabilir.

### **Proje Adımları:**

1. **Dockerfile Yazımı:**
   - Flask uygulamanızın Docker imajını oluşturacak `Dockerfile` yazılacaktır.
   - Flask uygulamasının bağımlılıkları yüklenip çalıştırılacak, Gunicorn ile başlatılacak.
   - `Dockerfile`'ın temel yapı taşları şunları içermelidir:
     - Python 3.9 imajı kullanımı
     - Gerekli bağımlılıkların yüklenmesi
     - Gunicorn sunucusunun Flask uygulamasını çalıştırması

   **Dockerfile Örneği:**
   ```dockerfile
   # Base image
   FROM python:3.9

   # Set the working directory in the container
   WORKDIR /app

   # Copy the current directory contents into the container
   COPY . /app

   # Install dependencies
   RUN pip install --no-cache-dir -r requirements.txt

   # Expose port 8000 for Gunicorn
   EXPOSE 8000

   # Command to run the application using Gunicorn
   CMD ["gunicorn", "-b", "0.0.0.0:8000", "wsgi:app"]
   ```

2. **Docker Compose Dosyası:**
   - Docker Compose, uygulamanın `mysql`, `app` (Flask + Gunicorn), ve `nginx` (Reverse Proxy) servislerini yönetecek.
   - Her bir servisin bağımsız olarak yapılandırılması sağlanacak.
   
   **Docker Compose Örneği:**
   ```yaml
   version: '3'
   services:
     app:
       build: .
       container_name: flask_app
       environment:
         - DB_HOST=mysql
         - DB_USER=root
         - DB_PASSWORD=rootpassword
         - DB_NAME=arac_kiralama
       depends_on:
         - mysql
       networks:
         - app-network
       ports:
         - "8000:8000"

     mysql:
       image: mysql:5.7
       container_name: mysql_container
       environment:
         MYSQL_ROOT_PASSWORD: rootpassword
         MYSQL_DATABASE: arac_kiralama
       networks:
         - app-network
       ports:
         - "3306:3306"

     nginx:
       image: nginx:latest
       container_name: nginx_reverse_proxy
       volumes:
         - ./nginx.conf:/etc/nginx/nginx.conf
       ports:
         - "80:80"
       depends_on:
         - app
       networks:
         - app-network

   networks:
     app-network:
       driver: bridge
   ```

3. **Nginx Yapılandırması:**
   - Nginx, Flask uygulamasına gelen istekleri alacak ve Gunicorn ile çalışan Flask uygulamasına yönlendirecek.
   
   **nginx.conf Örneği:**
   ```nginx
   server {
       listen 80;
       server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};

       location / {
           proxy_pass http://app:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

4. **Terraform ile EC2 Deploy:**
   - Terraform, AWS üzerinde EC2 instance'ı başlatacak ve Docker Compose'u EC2 üzerinde çalıştıracaktır.
   
   **Terraform Örneği:**
   ```hcl
   provider "aws" {
     region = "us-east-1"
   }

   resource "aws_instance" "flask_app" {
     ami           = "ami-0c55b159cbfafe1f0" # Uygun bir EC2 AMI ID'si
     instance_type = "t2.micro"

     tags = {
       Name = "FlaskAppInstance"
     }

     user_data = <<-EOF
       #!/bin/bash
       apt update -y
       apt install -y docker.io
       apt install -y docker-compose
       cd /home/ubuntu
       git clone https://github.com/kullanici/arac-kiralama.git
       cd arac-kiralama
       docker-compose up -d
     EOF
   }
   ```

### **Ödevde İstenilenler:**

1. **Dockerfile ve Docker Compose Dosyalarını Oluşturma:**
   - Flask uygulamasını Docker ile çalıştırabilecek şekilde Dockerfile yazılmalıdır.
   - `docker-compose.yml` dosyası ile MySQL, Nginx, ve Flask servisleri yapılandırılmalıdır.

2. **Uygulamayı Çalıştırma:**
   - Docker Compose kullanarak uygulama başlatılmalıdır.
   - Nginx’in Flask uygulaması ile doğru bir şekilde çalıştığından emin olunmalıdır.

3. **Terraform ile EC2 Üzerine Deploy Etme:**
   - Terraform ile bir EC2 instance’ı başlatılmalı ve Docker Compose çalıştırılmalıdır.

4. **Projenin Repoya Yüklenmesi:**
   - Tüm dosyalar bir GitHub reposuna yüklenmelidir.