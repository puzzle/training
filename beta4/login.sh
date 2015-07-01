#!/bin/bash

#mkdir -p /home/joe/.kube
#touch /home/joe/.kube/.kubeconfig
#chown -R joe.joe /home/joe/.kube

echo redhat | su - joe -c 'osc login -u joe \
--certificate-authority=/etc/openshift/master/ca.crt \
--server=https://ose3-master.example.com:8443'

echo redhat | su - alice -c 'osc login -u alice \
--certificate-authority=/etc/openshift/master/ca.crt \
--server=https://ose3-master.example.com:8443'
