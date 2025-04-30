Deploy linux jump box

Authenticate with iam key and secret by aws configure

Install Terraform using install_terraform.sh script

sign into redhat console with gmail and password and not with google auth

https://console.redhat.com/openshift/create

install rosa cli

wget https://mirror.openshift.com/pub/cgw/rosa/latest/rosa-linux.tar.gz

tar xvf rosa-linux.tar.gz

sudo mv rosa /usr/local/bin/rosa

rosa version

rosa login

rosa create ocm-role --admin

rosa create user-role

rosa create account-roles --mode auto

cleanup for demo

rosa delete ocm-role --mode auto --yes

aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"

