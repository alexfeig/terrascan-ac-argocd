echo "\x1B[92m --- Deploying ArgoCD\x1B[0m"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
echo "\x1B[92m--- Creating Docker terrascan docker image and pushing to minikube\x1B[0m"
eval $(minikube docker-env)
docker build -t terrascan-argocd docker/
echo "\x1B[92m--- Deploying terrascan Admission Controller\x1B[0m"
mkdir admissioncontroller/keys/
openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
  -keyout admissioncontroller/keys/key.pem -out admissioncontroller/keys/certificate.pem -subj "/CN=ac.accurics.svc.cluster.local" \
  -addext "subjectAltName=DNS:ac.accurics.svc"
kubectl create ns accurics
kubectl create secret generic terrascan-certs-secret \
  --from-file=admissioncontroller/keys/key.pem \
  --from-file=admissioncontroller/keys/certificate.pem \
  --dry-run=client \
  --output=yaml \
  -n accurics \
  > admissioncontroller/secret.yaml
kubectl create configmap terrascan-config \
  --from-file=admissioncontroller/config.toml \
  --dry-run=client \
  --output=yaml \
  -n accurics \
  > admissioncontroller/configmap.yaml
kubectl apply -f admissioncontroller/secret.yaml
kubectl apply -f admissioncontroller/configmap.yaml
kubectl apply -f admissioncontroller/deployment.yaml
sed -i -e "s/caBundle.*$/caBundle: $(base64 admissioncontroller/\keys\/certificate.pem)/g" admissioncontroller/validatingwebhook.yaml
echo "\x1B[92m--- Waiting for 30 seconds for ArgoCD to initialize to get login information\x1B[0m"
sleep 30
argo_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "\x1B[92m--- ArgoCD login information:\x1B[0m"
echo "\x1B[93m----- username: admin\x1B[0m"
echo "\x1B[93m----- password: ${argo_password}\x1B[0m"
echo "\x1B[92m--- Done\x1B[0m"