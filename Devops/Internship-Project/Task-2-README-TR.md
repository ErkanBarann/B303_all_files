# DevOps Projesi TASK-2: AWS Ortamının Ansible ve Jenkins ile Otomasyonu

## Amaç
Bu proje, AWS'de ortamları Terraform ile oluşturmayı ve bunları Ansible ile yapılandırmayı içerir. Bu kurulum, ortam kurulumu ve yönetim sürecini otomatikleştirir.

## Gereksinimler
- AWS hesabı
- Terraform
- Ansible
- Jenkins
- Git ve GitHub

## Adım Adım Görevler

### 1. Ansible Çalışma Dosyalarının Oluşturulması
- **1.1.** Gerekli Ansible çalışma dosyalarını oluşturun. Yazılım yüklemeleri, kullanıcı hesapları ve güvenlik ayarları gibi yapılandırmaları içermelidir.
- **1.2.** dev, test, staging ve prod ortamları gibi ortam değişkenlerine göre çalışacak dinamik çalışma dosyaları hazırlayın.

### 2. Terraform Çıktılarının Ansible ile Entegrasyonu
- **2.1.** Terraform çıktıları olarak elde edilen bilgileri (örneğin, EC2 Instance IP adresleri) bir Ansible envanter dosyasına veya dinamik envanter betiğine aktarın.
- **2.2.** Bu envanter dosyasını kullanarak Ansible çalışma dosyalarını çalıştırın.

### 3. Jenkinsfile Oluşturma ve Yapılandırma
- **3.1.** Hem Terraform hem de Ansible süreçlerini içeren bir Jenkinsfile oluşturun.
- **3.2.** Jenkins boru hattında, Terraform ile ortamlar oluşturulduktan sonra Ansible çalışma dosyalarını çalıştıracak adımlar ekleyin.

### 4. Jenkins Boru Hattında Dinamik Parametrelerin Tanımlanması
- **4.1.** Jenkins kullanıcı arayüzü üzerinden seçilebilecek parametreler ekleyin, örneğin ortam.
- **4.2.** Seçilen ortama göre ilgili Terraform ve Ansible komutlarını çalıştıracak betikler yazın.

### 5. Test ve Doğrulama
- **5.1.** Her bir ortam için Jenkins boru hattını çalıştırarak Terraform ve Ansible süreçlerinin başarıyla tamamlandığını kontrol edin.
- **5.2.** Ortamların istenildiği gibi yapılandırıldığını doğrulayın.

### 6. Dokümantasyon ve Raporlama
- **6.1.** Projede kullanılan her adımı, yapılandırmayı ve betiği detaylı bir şekilde dokümante edin.
- **6.2.** Karşılaşılan zorlukları ve çözümlerini raporlayın.
- **6.3.** Yapılandırılan kaynakları ve otomasyon sürecini detaylandıran son bir rapor hazırlayın.