#!/bin/bash -x

## Install docker 

sudo apt update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
sudo chmod 666 /var/run/docker.sock

### Install de kind pour démarrer un cluster k8s dans des conteneurs docker


curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/bin/kind

### Install kubectl => kubectl est un client en cli pour communiquer avec le cluster.


curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/kubectl

### Generate config file

cat <<EOF | tee kind.yml 
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
    - containerPort: 30001
      hostPort: 30001
  - role: worker
  - role: worker
EOF

# Initialize cluster 

# kind create cluster --name demo-cluster --config kind.yml
kind create cluster --name demo-cluster --config kind.yml 2>&1 | tee output_logger.txt
OUT_PUT_STRING=`cat output_logger.txt`

BIGIN_STRING="cluster-info"
END_STRING="Have"

RESULT="${OUT_PUT_STRING#*${BIGIN_STRING}}"
RESULT="${RESULT%${END_STRING}*}"

echo $RESULT

echo "--------> The config command is : kubectl cluster-info $RESULT"

kubectl cluster-info$RESULT