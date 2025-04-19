# Python base image'ını kullanıyoruz
FROM python:3.9-slim

# Çalışma dizinini belirliyoruz
WORKDIR /app

RUN pip install flask

# Uygulama dosyalarını kopyalıyoruz
COPY . .

# Flask uygulamasını çalıştırıyoruz
CMD ["python", "app.py"]