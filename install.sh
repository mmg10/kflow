sudo kubeadm init \
  --pod-network-cidr=10.100.0.0/16 \
  --node-name=control
  
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# CNI plugin
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

#  remove taint on master node
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# create default storage class
kubectl apply -f local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl get sc

# kustomize
curl -Lo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod 777 kustomize
sudo mv kustomize /usr/local/bin/kustomize


git clone https://github.com/kubeflow/manifests
cd manifests

while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

echo "please run: kubectl port-forward --address="0.0.0.0" svc/istio-ingressgateway -n istio-system 8080:80 &"

echo "username: user@example.com, password: 12341234"
