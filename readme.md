Deploy linux jump box

Authenticate with iam key and secret by aws configure

sudo yum update -y

sudo yum install git -y

Install Terraform using install_terraform.sh script

sign into redhat console with gmail and password and not with google auth

https://console.redhat.com/openshift/create

install rosa cli

wget https://mirror.openshift.com/pub/cgw/rosa/latest/rosa-linux.tar.gz

tar xvf rosa-linux.tar.gz

sudo mv rosa /usr/local/bin/rosa

rosa version

rosa login

get rosa token

https://console.redhat.com/openshift/token/rosa/show

rosa create operator-roles  --prefix "rosa-test-muwy" --oidc-config-id "2ig0e61j4dk2g58jak27l2pe38d46tci"  --installer-role-arn arn:aws:iam::371917992023:role/ManagedOpenShift-Installer-Role

rosa create oidc-provider --oidc-config-id "2ig0e61j4dk2g58jak27l2pe38d46tci"

rosa create ocm-role --admin

rosa create user-role

rosa create account-roles --mode auto

cleanup for demo

rosa delete ocm-role --mode auto --yes

aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"

