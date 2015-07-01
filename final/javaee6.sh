#!/bin/bash

osadm new-project javaee6 --display-name="Java EE 6 Liquibase Quickstart" \
--description="Java EE 6 Liquibase Quickstart" \
--admin=htpasswd:joe

#osc create -f demo-quota.json --namespace=demo

mkdir -p /home/joe/.kube
#touch /home/joe/.kube/.kubeconfig
chown -R joe.joe /home/joe/.kube

su - joe -c 'cd .kube && osc login \
--certificate-authority=/var/lib/openshift/openshift.local.certificates/ca/cert.crt \
--cluster=master --server=https://ose3-master.example.com:8443 \
--namespace=javaee6'

#su - joe -c 'openshift ex generate --name=javaee6 --ref=ose3 \
#https://github.com/puzzle/.git \
#| python -m json.tool > ~/javaee6.json'


#su - joe -c 'osc create -f /vagrant/javaee6.json'
su - joe -c 'osc process \
-f /vagrant/javaee6-template.json \
| osc create -f -'

su - joe -c 'osc create -f /vagrant/quickstart-javaee6-liquibase-route.json'
