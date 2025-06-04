# Rancher Server Kurulumu

Bu belge, Ubuntu 24.04 AMI kullanarak bir EC2 instance üzerinde Rancher Server kurulumunu ve konfigürasyonunu adım adım açıklar.

## Gereksinimler

- AWS EC2'de bir instance oluşturmak için gerekli izinler
- Route 53'te bir Hosted Zone
- SSH ile sunucuya erişim

## Adımlar

### 1. EC2 Instance Oluşturma

- **AMI**: Ubuntu 24.04
- **Instance Type**: t3a.medium
- **Security Group**: rancher k3s (Gerekli portları açın: 80, 443, 6443,8080, 10250, 22, 8472, 9200, 9300, 5601, 24231)
- **Volume**: 16 GB
- **Key Pair**: SSH ile bağlanmak için bir key pair seçin


### 2.  Route 53'te DNS Kaydı Oluşturma

AWS Console'dan Route 53 servisine gidin ve ilgili Hosted Zone'da aşağıdaki bilgileri kullanarak bir A kaydı oluşturun:
- **Name**: rancher.xxxxxxxxxxxxxxxx.com
- **Type**: A
- **Value**: EC2 instance'ınızın public IP adresi

### 3. Instance'a Bağlanma

SSH kullanarak instance'a bağlanın:
```sh
ssh -i /path/to/your-key.pem ubuntu@your-ec2-public-ip
```

### 4. Sistemi Güncelleme

```sh
sudo apt update -y && sudo apt upgrade -y
```

### 5. Docker container ile rancher kurulumu


# Docker ile Rancher Kurulumu

## Step-1 Docker install

```sh
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
docker version
```

## Step-2 Deploy rancer server in docker container

```sh
sudo docker run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```

### Step-3 Rancher UI'ye Erişim

Web tarayıcınızda `https://rancher.xxxxxxxxxxxxxx.com` adresine gidin ve Rancher yönetim arayüzüne erişin.

--------------------------------------------------------------------------------------

# Rancher ile Kubernetes Cluster Kurulum Rehberi

Bu rehber, Rancher kullanarak Amazon EC2 üzerinde Kubernetes Cluster kurulumunu adım adım anlatmaktadır.
Öncelikle Rancher UI giriş yapmalısın. (bootstrapPassword=admin)-(yeni password oluştur ve continue)

## Adım 1: Bulut Kimlik Bilgilerini Oluşturma

Eğer halihazırda kullanabileceğiniz bir bulut kimlik bilgisine sahipseniz, bu adımı atlayabilirsiniz.

1. **Menüyü açın**: ☰ > Cluster Management.
2. **Cloud Credentials** öğesine tıklayın.
3. **Create** düğmesine tıklayın.
4. **Amazon** seçeneğine tıklayın.
5. Bulut kimlik bilgisi için bir ad girin.
6. **Default Region** alanında, küme düğümlerinizin bulunacağı AWS bölgesini seçin.
7. AWS EC2 Erişim Anahtarınızı ve Gizli Anahtarınızı girin.
8. **Create** düğmesine tıklayın.

**Sonuç**: Düğümlerinizi sağlamak için kullanılacak bulut kimlik bilgilerini oluşturdunuz. Bu kimlik bilgilerini diğer düğüm şablonlarında veya diğer kümelerde yeniden kullanabilirsiniz.

## Adım 2: Kümeyi Oluşturma

1. **Menüyü açın**: ☰ > Cluster Management.
2. **Clusters** sayfasında, **Create** düğmesine tıklayın.
3. Anahtarı **RKE2/K3s** konumuna getirin.
4. **Amazon EC2** seçeneğine tıklayın.
5. Birden fazla Bulut Kimlik Bilgisi varsa, birini seçin. Aksi takdirde, otomatik olarak seçilecektir.
6. Bir **Cluster Name** girin.
7. Her Kubernetes rolü için bir makine havuzu oluşturun. Rol atamaları ve sayıları için en iyi uygulamalara bakın.
8. Her makine havuzu için makine yapılandırmasını tanımlayın. Yapılandırma seçenekleri hakkında bilgi almak için EC2 makine yapılandırma referansına bakın.
9. **Cluster Configuration** bölümünde, yüklenecek Kubernetes sürümünü, hangi ağ sağlayıcısının kullanılacağını ve proje ağ izolasyonunu etkinleştirmek isteyip istemediğinizi seçin. Küme yapılandırma konusunda yardım için RKE2 küme yapılandırma referansına bakın.
10. **Member Roles** kullanarak küme için kullanıcı yetkilendirmesini yapılandırın. Kullanıcıları eklemek için **Add Member** düğmesine tıklayın. Her kullanıcı için izinleri ayarlamak üzere **Role** açılır menüsünü kullanın.
11. **Create** düğmesine tıklayın.

**Sonuç**: 

Kümeniz oluşturulur ve **Provisioning** durumu atanır. Rancher, kümenizi ayağa kaldırıyor.

Kümenizin durumu **Active** olarak güncellendiğinde erişebilirsiniz.

Aktif kümelere iki Proje atanır:

- **Default**: Varsayılan namespace içerir.
- **System**: cattle-system, ingress-nginx, kube-public ve kube-system namespace'lerini içerir.

----------------------------------------------------------------------------------------
