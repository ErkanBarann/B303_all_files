# DevOps Final Projesi - TASK-6: Rancher ve EFK ile Kubernetes Yönetimi ve İzleme

## Proje Amacı
Bu görev, Rancher UI kullanarak bir Kubernetes cluster kurmayı, Helm ile uygulama deploy etmeyi, Kubernetes Lens ile cluster yönetimini yapmayı ve EFK (Elasticsearch, Fluentd, Kibana) stack ile uygulamanın loglarını izlemeyi kapsamaktadır. Bu adımları tamamlayarak, Kubernetes üzerinde yönetim, uygulama dağıtımı ve log izleme yeteneklerinizi geliştireceksiniz.

## Gereksinimler
- **Bulut Sağlayıcı**: AWS EC2 (Ubuntu 22.04)
- **Yazılımlar**: Rancher, Helm, Kubernetes CLI (kubectl), Kubernetes Lens
- **Diğer Gereksinimler**: SSH erişimi, AWS Route 53 (opsiyonel)

## Adımlar

### 1. Rancher Kurulumu için Ortam Hazırlığı
İlk adımda, Rancher Server’ın kurulumu için gerekli ortamı hazırlamanız gerekiyor. Bu adımda bir AWS EC2 instance oluşturulmalı ve gerekli güvenlik grubu ayarları yapılmalıdır. Rancher’ın düzgün çalışabilmesi için gerekli portların açık olduğundan emin olunmalıdır. SSH ile sunucuya bağlanarak sistemin en güncel hale getirilmesi önerilir.

### 2. Rancher UI Üzerinden RKE ile Kubernetes Cluster Kurulumu
Rancher Server kurulduktan sonra, Rancher UI üzerinden RKE (Rancher Kubernetes Engine) kullanarak bir Kubernetes cluster oluşturulması gerekiyor. Bu adımda, cluster’ın ayarları yapılandırılacak ve Rancher UI kullanarak kolayca yönetilebilir hale getirilecektir.

### 3. Kurulu Cluster’a Helm ile Uygulama Deploy Etme
Oluşturulan Kubernetes cluster’a Helm kullanarak bir uygulama deploy edilmesi gerekmektedir. Helm chart kullanarak bir uygulama kurulumunun nasıl yapıldığı ve uygulamanın Kubernetes üzerinde nasıl yönetildiği bu adımda gerçekleştirilecektir.

### 4. Kubernetes Lens ile Cluster’ın Görüntülenmesi
Kubernetes Lens, Kubernetes cluster’ını yönetmek ve izlemek için güçlü bir kullanıcı arayüzüdür. Bu adımda, Lens arayüzünün kurulumunu yaparak, kubeconfig dosyasını ekleyecek ve oluşturduğunuz Kubernetes cluster’ını Lens ile görüntüleyeceksiniz.

### 5. Deploy Edilen Uygulamanın EFK ile Loglarının İzlenmesi
EFK (Elasticsearch, Fluentd, Kibana) stack, Kubernetes ortamında log toplama ve analiz etme işlemleri için kullanılır. Bu adımda, uygulamanızdan gelen logları Elasticsearch üzerinde toplamak, Fluentd ile yönlendirmek ve Kibana ile görselleştirmek için gerekli EFK yapılandırmasını yapacaksınız.

## Sonuç
Bu görev tamamlandığında, Rancher ile bir Kubernetes cluster kurmayı, Helm ile uygulama dağıtmayı, Kubernetes Lens ile cluster’ı izlemeyi ve EFK stack ile log takibi yapmayı öğrenmiş olacaksınız.
