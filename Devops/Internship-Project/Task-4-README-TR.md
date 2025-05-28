# DevOps Projesi TASK-4: Kubernetes Cluster Kurulumu ve Uygulamanın Deploy Edilmesi

## Amaç
AWS üzerinde Terraform ile oluşturulan ve Ansible ile yapılandırılan makineler üzerinde bir Kubernetes cluster'ı kurarak, Docker Compose ile hazırlanan uygulamanın Kubernetes manifest dosyalarına dönüştürülmesi ve bu cluster üzerine deploy edilmesi. Bu süreç, Jenkins ile otomatik olarak yönetilecektir.

## Gereksinimler
- AWS hesabı
- Terraform
- Ansible
- Docker
- Jenkins
- Git ve GitHub (veya benzeri bir versiyon kontrol sistemi)
- AWS CLI ve ECR erişimi
- Kustomize
- Kompose Tool
- Kubernetes(k3s)

## Adım Adım Görevler

### 1. AWS CLI ile Key Pair Oluşturma
1.1. AWS CLI kullanarak EC2 için yeni bir key pair oluşturun. Bu key pair, sonraki adımlarda oluşturulacak EC2 instance'larına SSH erişimi sağlamak için kullanılacaktır.

### 2. Terraform ile Kubernetes Cluster için Makinelerin Oluşturulması
2.1. Terraform kullanarak Kubernetes için gerekli olan en az iki EC2 instance oluşturun. Bu instance'lar Kubernetes master ve node olarak kullanılacaktır.
2.2. Terraform konfigürasyon dosyalarında, oluşturulan instance'lar için uygun security group, IAM roles ve diğer network ayarlarını yapılandırın.

### 3. Ansible ile Kubernetes Cluster Yapılandırması
3.1. Ansible playbook'ları kullanarak, oluşturulan EC2 instance'ları üzerinde Kubernetes cluster'ı kurun. Bu playbook'lar Kubernetes paketlerini yükleyecek, cluster'ı başlatacak ve node'ları cluster'a ekleyecektir.

### 4. Docker Image'ların Oluşturulması ve AWS ECR'ye Gönderilmesi
4.1. Uygulamanız için gerekli Docker image'ları build edin.
4.2. Oluşturulan Docker image'larını AWS ECR'ye push edin.

### 5. Docker Compose'dan Kubernetes Manifest'lerine Dönüşüm
5.1. Docker Compose dosyanızı kullanarak, Kompose tool ile Kubernetes manifest dosyalarına dönüştürün.
5.2. Kustomize ile oluşturulan Kubernetes manifest dosyalarını uygulamanız için gerekli yapılandırmalar ile güncelleyin.

### 6. Kubectl ile Uygulamanın Deploy Edilmesi
6.1. Oluşturulan manifest filelardan uygulamanın kubectl ile deploy edilmesi.

### 7. Jenkins ile Otomasyon
7.1. Jenkinsfile oluşturarak, bu süreçleri otomatik hale getirecek bir Jenkins pipeline'ını tanımlayın. Pipeline, Kubernetes cluster'ın kurulumundan, uygulamanın deploy edilmesine kadar tüm adımları kapsayacaktır.

### 8. Test ve Doğrulama
8.1. Kubernetes cluster üzerinde uygulamanın başarılı bir şekilde deploy edilip edilmediğini test edin.
8.2. Uygulamanın düzgün çalıştığından emin olmak için gerekli testleri gerçekleştirin.

### 9. Dokümantasyon ve Raporlama
9.1. Her adımı, kullanılan yapılandırmayı ve script'leri detaylı bir şekilde dokümante edin.
9.2. Karşılaşılan zorlukları ve çözümleri raporlayın.

