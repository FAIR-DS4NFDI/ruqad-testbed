# RuQaD Testbed

<!-- TOC -->
* [RuQaD Testbed](#ruqad-testbed)
  * [1. Introduction](#1-introduction)
  * [2. Running the Testbed](#2-running-the-testbed)
    * [2.1 Build the runtime images](#21-build-the-runtime-images)
    * [2.2 Create the K8S cluster](#22-create-the-k8s-cluster)
    * [2.3 Create a Kadi Access Token](#23-create-a-kadi-access-token)
    * [2.4 Run the RuQaD demonstrator](#24-run-the-ruqad-demonstrator)
<!-- TOC -->

## 1. Introduction

This testbed is used to demonstrate the results of the project "RuQaD Batteries - Reuse Quality-assured Data
for Batteries". The project is a sub-project of the [FAIR Data Spaces](https://www.nfdi.de/fair-data-spaces/)
project, supported by the German Federal Ministry of Education and Research under the Förderkennzeichen
[FAIRDS05 (PR697238)](https://foerderportal.bund.de/foekat/jsp/SucheAction.do?actionMode=view&fkz=FAIRDS05).

Find more information: <https://docs.indiscale.com/fair-data-spaces/ruqad-docs>

The testbed is based on the [Minimum Viable Dataspace
Demo](https://github.com/eclipse-edc/MinimumViableDataspace) where you can find the original README and more
information on the Data Space Protocol.

## 2. Running the Testbed

For this section a basic understanding of Kubernetes, Docker, Gradle and Terraform is required. It is assumed that the
following tools are installed and readily available:

- Docker
- Minikube
- Terraform
- JDK 17+
- Git
- a POSIX compliant shell
- Postman (to comfortably execute REST requests)
- `openssl`, optional, but required to [regenerate keys](#91-regenerating-issuer-keys)
- `newman` (to run Postman collections from the command line)
- not needed, but recommended: Kubernetes monitoring tools like K9s

All commands are executed from the **repository's root folder** unless stated otherwise via `cd` commands.

> Since this is not a production deployment, all applications are deployed _in the same cluster_ and in the same
> namespace, plainly for the sake of simplicity.

### 2.1 Build the runtime images

```shell
./gradlew build
./gradlew -Ppersistence=true dockerize
```

this builds the runtime images and creates the following docker images: `controlplane:latest`, `dataplane:latest`,
`catalog-server:latest` and `identity-hub:latest` in the local docker image cache. Note the `-Ppersistence` flag which
puts the HashiCorp Vault module and PostgreSQL persistence modules on the runtime classpath.

> This demo will not work properly, if the `-Ppersistence=true` flag is omitted!

PostgreSQL and Hashicorp Vault obviously require additional configuration, which is handled by the Terraform scripts.

### 2.2 Create the K8S cluster

After the runtime images are built, we bring up and configure the Kubernetes cluster using Minikube.

0. `alias minikube='minikube -p mvd'`
1. `alias kubectl='minikube kubectl --'`
2. `minikube start`
3. `minikube addons enable ingress`
4. Wait for the ingress controller to become available:
    ```
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
    ```
5. Forward the local port 80 to the ingress controller:
    `sudo ssh -i $(minikube ssh-key) docker@$(minikube ip) -L 80:localhost:80`
   (You probably need to do this in a separate terminal, therefore you must set the alias for `minikube` from step 0 again.)
6. Load the images:
    `minikube image load controlplane:latest dataplane:latest identity-hub:latest catalog-server:latest sts:latest`

Now, deploy the dataspace, type 'yes' when promted:

```
cd deployment
terraform init
terraform apply
```

Once Terraform has completed the deployment, type `kubectl get pods` and verify the output:

```shell
❯ kubectl get pods -A
NAMESPACE       NAME                                                   READY   STATUS      RESTARTS      AGE
batcat          consumer-controlplane-677f95b875-tjr2m                 1/1     Running     0             38m
batcat          consumer-dataplane-59c6859656-8m4ws                    1/1     Running     0             37m
batcat          consumer-identityhub-877f556df-r85g4                   1/1     Running     0             38m
batcat          consumer-postgres-5546fb44f4-n26j6                     1/1     Running     0             38m
batcat          consumer-sts-67f5b9d88d-r7vb8                          1/1     Running     0             38m
batcat          consumer-vault-0                                       1/1     Running     0             38m
batcat          dataspace-issuer-server-7cbff4856d-6l8m6               1/1     Running     0             38m
batcat          kadi-kadi-77579d945-jm4j5                              1/1     Running     0             38m
batcat          provider-catalog-server-75754dc775-c4lsm               1/1     Running     0             38m
batcat          provider-identityhub-75f477c4f6-s8hn2                  1/1     Running     0             38m
batcat          provider-linkahead-649848c54c-kvsrm                    1/1     Running     0             38m
batcat          provider-manufacturing-controlplane-7f6fbd99d9-lfc56   1/1     Running     0             38m
batcat          provider-manufacturing-dataplane-fdc6f9f4b-vhg6t       1/1     Running     0             37m
batcat          provider-mariadb-6bcf68559b-cxc22                      1/1     Running     0             38m
batcat          provider-postgres-85fd8dc55-x7xcp                      1/1     Running     0             38m
batcat          provider-qna-controlplane-6b64d9b5b9-vg4p8             1/1     Running     0             38m
batcat          provider-qna-dataplane-865879db7d-szdmc                1/1     Running     0             37m
batcat          provider-sts-b7bf7498d-vjf2d                           1/1     Running     0             38m
batcat          provider-vault-0                                       1/1     Running     0             38m
batcat          redis-redis-759b9c796f-rbwp9                           1/1     Running     0             38m
ingress-nginx   ingress-nginx-admission-create-lfp8p                   0/1     Completed   0             27h
ingress-nginx   ingress-nginx-admission-patch-64g7f                    0/1     Completed   0             27h
ingress-nginx   ingress-nginx-controller-bc57996ff-vfb4d               1/1     Running     0             27h
kube-system     coredns-6f6b679f8f-h5zxp                               1/1     Running     0             27h
kube-system     etcd-batcat                                            1/1     Running     0             27h
kube-system     kube-apiserver-batcat                                  1/1     Running     0             27h
kube-system     kube-controller-manager-batcat                         1/1     Running     0             27h
kube-system     kube-proxy-wdvp2                                       1/1     Running     0             27h
kube-system     kube-scheduler-batcat                                  1/1     Running     0             27h
kube-system     storage-provisioner                                    1/1     Running     1 (27h ago)   27
```

## 2.3 Create a Kadi Access Token

0. Browse to <http://localhost/kadi/login>
1. login with user:user
2. Go to <http://localhost/kadi/settings/personal-tokens> and create an access token with at least
   "Record:read" and "User:read" permissions.

You'll need the access token in the next step.

## 2.4 Run the RuQaD Demonstrator

This demo uses the RuQaD repository to retrieve and install the code.

Clone the [RuQaD Demonstrator](https://gitlab.indiscale.com/caosdb/src/fair-data-spaces/ruqad) and follow the
steps in the README for installation and configuration. Here you need at least the following settings:
    * secrets.sh
        * `KADITOKEN` - the Kadi access token from the previous section.
        * `KADIHOST=http://localhost/kadi`
        * `SKIP_QUALITY_CHECK=True`
    * pylinkahead.ini
        ```
        [Connection]
        url = http://localhost:80/provider/linkahead/
        username=admin
        password=caosdb
        ```

Now run the RuQaD Demonstrator as explained in the README: `(set -a && . secrets.sh && rq_monitor)`

You can find the newly transferred entities in the LinkAhead instance under <http://localhost/provider/linkahead/Entity/?query=find%20Record&P=0L10>, login with admin:caosdb.

### Add Assurance Pipeline

The previous setup will skip the quality check with the FAIR Data Spaces Demonstrator 4.2 (Quality Assurance)
and just perform basic FAIR compliance
checks. Setting up the quality assurance pipeline is documented in the [Repository of the Quality Assurance Demonstrator](https://git.rwth-aachen.de/fair-ds/ap-4-2-demonstrator/ap-4.2-data-validation-and-quality-assurance-demonstrator). You need to optain access keys for an S3 storage and the gitlab pipeline which have to be added to the secrets.sh file as well. Then set `SKIP_QUALITY_CHECK=False` or remove that option.
