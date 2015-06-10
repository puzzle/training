#!/bin/bash

#mkdir -p /home/joe/.kube
#touch /home/joe/.kube/.kubeconfig
#chown -R joe.joe /home/joe/.kube

su - joe -c 'osc login -u joe \
--certificate-authority=/var/lib/openshift/openshift.local.certificates/ca/cert.crt \
--server=https://ose3-master.example.com:8443'

su - alice -c 'osc login -u alice \
--certificate-authority=/var/lib/openshift/openshift.local.certificates/ca/cert.crt \
--server=https://ose3-master.example.com:8443'
