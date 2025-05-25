# DevOps Projesi TASK-3: AWS Üzerinde Docker Compose ile Uygulama Yayınlama

## Amaç
Bu proje, Terraform ile oluşturulan ve Ansible ile yapılandırılan AWS makinelerine, Docker Compose kullanarak çok servisli bir web uygulamasının yayınlanmasıdır. Bu süreç, Jenkins ile otomatik olarak yönetilecektir.

## Gereksinimler
- AWS hesabı
- Terraform
- Ansible
- Docker, Docker Compose
- Jenkins
- Git ve GitHub (veya benzeri bir versiyon kontrol sistemi)
- AWS CLI ve ECR erişimi

## Adım Adım Görevler

### 1. Dockerfile'ların Oluşturulması
- Backend ve frontend için Dockerfile'lar oluşturun. Bu Dockerfile'lar, uygulamanızın container image'larını build etmek için kullanılacaktır.

### 2. AWS ECR'a Docker Image'ların Yüklenmesi
- AWS ECR'da yeni bir repository oluşturun ve Docker image'larınızı build edip buraya yükleyin.

### 3. Docker Compose Yapılandırması
- `docker-compose.yml` dosyasını oluşturun. Bu dosya, backend ve frontend servislerinin nasıl birbirleriyle iletişim kuracağını ve hangi portlar üzerinden erişileceğini tanımlar.

### 4. Jenkins ile Otomasyon
- `Jenkinsfile` oluşturarak pipeline'ınızı tanımlayın. Bu pipeline, Docker image'larını build etmek, ECR'a yüklemek ve AWS üzerinde Docker Compose ile deploy etmek için gereken adımları içerir. (TASK-1 ve TASK-2 Jenkinsfile içeriğini de içerecek.)

### 5. Test ve Doğrulama
- Deploy edilen uygulamanın düzgün çalışıp çalışmadığını test edin.

### Ek Bilgi
- Bu task, TASK-1 (Terraform ile altyapının oluşturulması) ve TASK-2 (Ansible ile altyapının yapılandırılması) üzerine inşa edilmiştir. Bu nedenle, bu task'ları başarıyla tamamlamış olmanız beklenmektedir.
