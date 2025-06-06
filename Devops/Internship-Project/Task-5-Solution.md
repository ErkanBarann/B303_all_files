# TASK-5---AWS EKS Cluster Kurulum ve Yönetim Süreci

## 1. Ön Gereksinimlerin Kurulumu

### Eksctl Kurulumu (EC2-user olarak):
```bash
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

### Kubectl Kurulumu:
```bash
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### Helm Kurulumu:
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
```

### Helm S3 Plugin Kurulumu:
```bash
helm plugin install https://github.com/hypnoglow/helm-s3.git
# veya kontrol ederek kurulum
helm plugin list | grep -q "s3" || helm plugin install https://github.com/hypnoglow/helm-s3.git
```

## 2. EKS Cluster Oluşturma ve Yönetim

### Jenkins Kullanıcısı ile Cluster YAML Oluşturma:
```bash
sudo su - jenkins -s /bin/bash
vim cluster.yaml  # Cluster konfigürasyonunu yapıştır
```

### Cluster Oluşturma:
```bash
eksctl create cluster -f cluster.yaml
```

### Cluster Kontrolleri:
```bash
eksctl get cluster --region us-east-1
kubectl get nodes
```

### Kubeconfig Güncelleme (Gerekirse):
```bash
aws eks --region us-east-1 update-kubeconfig --name realestate-cluster
```

### Cluster Silme:
```bash
eksctl delete cluster --name realestate-cluster --region us-east-1
```

## 3. Helm Chart Oluşturma ve Yönetimi

### Helm Chart Yapısı Oluşturma(ec2user kullanıcısında):
```bash
git clone https://git-token@github.com/techpro-aws-devops/RealEstateAppInternshipProject.git
cd RealEstateAppInternshipProject
mkdir Task-5-Solution
cd Task-5-Solution
helm create realestate_chart
rm -rf realestate_chart/templates/*
```

### Manifest Dosyalarını Düzenleme:
- Task-4'den manifest dosyalarını kopyala
- Deployment'larda image tag'leri düzenle: `{{ .Values.IMAGE_TAG_BE }}`
- Deployment'larda image tag'leri düzenle: `{{ .Values.IMAGE_TAG_FE }}`
- Ingress'e host ve ingressClassName ekle:
  ```yaml
  ingressClassName: nginx spec altında
  host: `{{ .Values.DNS_NAME }}`
  ```

### values-template.yaml Oluşturma:
```yaml
IMAGE_TAG_BE: "${IMAGE_TAG_BE}"
IMAGE_TAG_FE: "${IMAGE_TAG_FE}"
DNS_NAME: "realestate.techprodevops.com"
```

### Helm S3 Repo Kurulumu:
```bash
# S3 bucket oluştur (sadece isim ver)
aws s3 mb s3://realestate-techpro
aws s3 ls
helm s3 init s3://realestate-techpro/stable/myapp
helm repo add realestate-app-repo s3://realestate-techpro/stable/myapp/
helm repo ls
```

### Helm Chart Paketleme ve Yükleme:
```bash
cd realestate_chart
helm package .
helm s3 push ./realestate_chart-0.1.0.tgz realestate-app-repo
helm repo update
helm search repo realestate-app-repo --versions
```
- Chart.yaml version HELM_VERSION yap.

## 4. Diğer Adımlar

### Prometheus ve Grafana Kurulumu:
- İlgili manifest dosyalarını oluştur

### Wait.sh Oluşturma:
- Deployment'ların hazır olmasını bekleyen script

### Jenkinsfile Oluşturma:
- CI/CD pipeline için Jenkinsfile oluştur ve GitHub'a pushla

### Uygulama Deploy ve DNS Kaydı:
- Uygulamayı deploy et
- 3 adet alias kaydı oluştur ve Load Balancer'a bağla

### Grafana Erişimi:
```
URL: grafana.techprodevops.com
Kullanıcı Adı: admin
Şifre: prom-operator
```

## Notlar:
1. Tüm komutlar uygun kullanıcı yetkileriyle çalıştırılmalıdır
2. AWS bölgesi (region) komutlarında tutarlı olun (us-east-1)
3. Helm chart versiyonlarını güncellerken Chart.yaml'i düzenlemeyi unutmayın
4. DNS ayarlarının doğruluğunu kontrol edin
5. Güvenlik gruplarının doğru şekilde yapılandırıldığından emin olun