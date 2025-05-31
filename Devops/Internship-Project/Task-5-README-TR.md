# DevOps Final Projesi TASK-5: AWS EKS Üzerinde Helm ile Uygulama Deployment

## Amaç
Bu proje, AWS EKS cluster üzerine Helm kullanarak bir uygulamanın deploy edilmesini, Nginx Ingress kurulumunu ve Prometheus-Grafana monitoring stack'inin kurulumunu içermektedir. Bu süreç Jenkinsfile ile otomatik olarak yönetilecektir.

## Gereksinimler
- AWS hesabı
- AWS CLI
- kubectl
- eksctl
- Helm
- Jenkins
- Git ve GitHub (veya benzeri bir versiyon kontrol sistemi)
- AWS EKS
- AWS ECR
- Prometheus
- Grafana

## Adım Adım Görevler

### 1. Helm ve EKS CLI Yapılandırması
1.1. AWS CLI, kubectl ve Helm'in yerel makinanıza kurulu olduğundan emin olun.
1.2. AWS EKS cluster'ınıza bağlanmak için `aws eks update-kubeconfig --region region-code --name cluster-name` komutunu kullanın.

### 2. Nginx Ingress Kurulumu
2.1. Helm kullanarak Nginx Ingress controller'ı kurun:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-basic --create-namespace
```


### 3. Uygulama Deployment

3.1. Uygulamanızın Helm chart'ını hazırlayın veya mevcut bir chart kullanın.
3.2. Helm kullanarak EKS cluster üzerine uygulamanızı deploy edin:
helm upgrade --install my-application ./path-to-your-chart --namespace your-namespace

### 4. Prometheus-Grafana Monitoring Stack Kurulumu
4.1. Prometheus ve Grafana için Kube Prometheus Stack kurulumu:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

### 5. Jenkinsfile ile Süreç Otomasyonu
5.1. Jenkinsfile oluşturarak, tüm bu deployment süreçlerini otomatize edin. Jenkinsfile içerisinde gerekli helm install ve helm upgrade komutlarını konfigüre edin.

### 6. Test ve Doğrulama
6.1. Uygulamanızın ve monitoring servislerinin düzgün çalıştığını kontrol edin.
6.2. Nginx Ingress üzerinden uygulamanıza erişim sağlanabildiğini test edin.

### 7. Dokümantasyon ve Raporlama
7.1. Projede kullanılan her adımı, yapılandırmayı ve script'leri detaylı bir şekilde dokümante edin.
7.2. Karşılaşılan zorlukları ve çözümleri raporlayın.
