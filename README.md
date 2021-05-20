# Quick Demo of Terrascan with local scanning, ArgoCD integration, and Admission Controller
One day I will go back and fix this documentation and greatly improve `deploy.sh`

## Requirements

* [Minikube](https://minikube.sigs.k8s.io/docs/)
* `kubectl`

## Basic run steps:

1. Run `deploy.sh`
2. Run `minikube tunnel` to expose ArgoCD on https://localhost
2. Use `repo/test-app-*` to demonstrate bad code either with `terrascan` local to your machine, or by applying the `argocd-application.yaml `file for ArgoCD, or just a plain old `kubectl apply -f` for testing the Admission Controller