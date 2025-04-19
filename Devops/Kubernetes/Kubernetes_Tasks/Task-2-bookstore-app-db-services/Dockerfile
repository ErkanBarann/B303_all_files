# Resmi Python imajını kullan
FROM python:3.9-slim

# Çalışma dizinini oluştur
WORKDIR /app

# Gereken bağımlılıkların yüklenmesi için requirements dosyasını kopyala
COPY requirements.txt .

# Bağımlılıkları yükle
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama dosyalarını kopyala
COPY . .

# Uygulamanın çalıştırılacağı portu belirle
EXPOSE 80

# Uygulamayı çalıştır
CMD ["python", "bookstore-api.py"]
