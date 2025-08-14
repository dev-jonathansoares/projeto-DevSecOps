# OpenShift local + Jenkins com testes na validação de pipeline

## 1) OpenShift Local (CRC)
1. Instale o **OpenShift Local**: https://developers.redhat.com/products/openshift-local/overview
2. Inicie:
```bash
crc setup
crc start
crc console
```
3. Use `oc` (já vem com o CRC) para logar se necessário.

## 2) Provisionar app (ImageStream, BuildConfig, DC, SVC, Route)
```bash
oc apply -f openshift/app.yaml
```

## 3) Jenkins no OpenShift (sem Docker Hub)
```bash
./openshift/jenkins-setup.sh
# ou:
# oc new-app jenkins-ephemeral -n devsecops-demo
# oc policy add-role-to-user edit system:serviceaccount:devsecops-demo:jenkins -n devsecops-demo
# oc expose svc/jenkins -n devsecops-demo
oc get route jenkins -n devsecops-demo
```

## 4) Pipeline com testes (Jenkinsfile.openshift)
- Crie um Pipeline no Jenkins apontando para este repo e use `Jenkinsfile.openshift` como Script Path.
- Etapas:
  - **Lint & Unit Tests (pytest)**: roda antes do build/deploy; se falhar, a pipeline para.
  - **SAST (Bandit)**: relatório arquivado.
  - **Build binário** no OpenShift (`oc start-build --from-dir=app`).
  - **Deploy/Rollout** via `DeploymentConfig` + **Route**.
  - **DAST (ZAP baseline)** contra a URL da Route.

## 5) Teste local do build (opcional)
```bash
oc apply -f openshift/app.yaml -n devsecops-demo
oc start-build secure-pyapp --from-dir=app --follow -n devsecops-demo
oc rollout status dc/secure-pyapp -n devsecops-demo
oc get route secure-pyapp -n devsecops-demo -o jsonpath='{.spec.host}{"\n"}'
```

## 6) Observações
- A imagem `jenkins-ephemeral` inclui `oc`. O pipeline ainda usa um container dedicado `oc` para garantir versão.
- Para SCA (Trivy) com o registry interno, faça `oc registry login` e aponte o nome da imagem do ImageStream.
- Se os **templates Jenkins** não estiverem disponíveis, peça ao admin para registrá-los ou faça deploy manual do Jenkins.
