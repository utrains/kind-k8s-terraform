# kind-k8s-terraform
Kind kubernetes wit kind

### Install de kind pour démarrer un cluster k8s dans des conteneurs docker
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/bin/kind
``` 
### Install kubectl => kubectl est un client en cli pour communiquer avec le cluster.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/bin/kubectl
```

### Création d'un cluster avec kind
```bash
kind create cluster --name demo-cluster --config cluster-kind.yml
```
