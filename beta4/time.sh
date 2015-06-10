#mkdir -p /home/joe/.kube
#chown -R joe.joe /home/joe/.kube

echo redhat | su - joe -c 'osc login -u joe \
--certificate-authority=/etc/openshift/master/ca.crt \
--server=https://ose3-master.example.com:8443'

osadm new-project time --display-name="Java EE Time Quickstart" \
 --description="Simple Java EE Application displaying time and timezone." \
 --admin=joe

su - joe -c "osc project time"

su - joe -c "osc create -f /vagrant/time-docker.json"

