- [OpenShift Beta 4](#openshift-beta-4)
    - [Docker Storage Setup (optional, recommended)](#docker-storage-setup-optional-recommended)
    - [Add Development Users](#add-development-users)
  - [Regions and Zones](#regions-and-zones)
    - [Scheduler and Defaults](#scheduler-and-defaults)
    - [The NodeSelector](#the-nodeselector)
    - [Customizing the Scheduler Configuration](#customizing-the-scheduler-configuration)
    - [Node Labels](#node-labels)
    - [Resources](#resources)
    - [Applying Limit Ranges to Projects](#applying-limit-ranges-to-projects)
    - [Creating a Wildcard Certificate In order to serve a valid certificate for](#creating-a-wildcard-certificate-in-order-to-serve-a-valid-certificate-for)
    - [Viewing Router Stats](#viewing-router-stats)
  - [Preparing for S2I: the Registry](#preparing-for-s2i-the-registry)
    - [Storage for the registry](#storage-for-the-registry)
    - [Creating the registry](#creating-the-registry)
  - [S2I - What Is It?](#s2i---what-is-it)
  - [Using Persistent Storage (Optional)](#using-persistent-storage-optional)
    - [Export an NFS Volume](#export-an-nfs-volume)
    - [NFS Firewall](#nfs-firewall)
    - [Allow NFS Access in SELinux Policy](#allow-nfs-access-in-selinux-policy)
    - [Create a PersistentVolume](#create-a-persistentvolume)
    - [Claim the PersistentVolume](#claim-the-persistentvolume)
    - [Use the Claimed Volume](#use-the-claimed-volume)
  - [S2I Builds](#s2i-builds)
# OpenShift Beta 4
* RHEL >=7.1 (Note: 7.1 kernel is required for openvswitch)
In almost all cases, when referencing VMs you must use hostnames and the
hostnames that you use must match the output of `hostname -f` on each of your
nodes. Forward DNS resolution of hostnames is an **absolute requirement**. This
We do our best to point out where you will need to change things if your
hostnames do not match.

Remember that NetworkManager may make changes to your DNS
configuration/resolver/etc. You will need to properly configure your interfaces'
DNS settings and/or configure NetworkManager appropriately.

More information on NetworkManager can be found in this comment:
    https://github.com/openshift/training/issues/193#issuecomment-105693742

## Setting Up the Environment
duties. See the [appendix on dnsmasq](#appendix---dnsmasq-setup) if you can't
easily manipulate your existing DNS environment.
    **Note:** You will have had to register/attach your system first.  Also,
    *rhel-server-7-ose-beta-rpms* is not a typo.  The name will change at GA to be
    consistent with the RHEL channel names.
### Docker Storage Setup (optional, recommended)
**IMPORTANT:** The default docker storage configuration uses loopback devices
and is not appropriate for production. Red Hat considers the dm.thinpooldev
storage option to be the only appropriate configuration for production use.

If you want to configure the storage for Docker, you'll need to first install
Docker, as the installer currently does not auto-configure this storage setup
for you.

    yum -y install docker

Make sure that you are running at least `docker-1.6.2-6.el7.x86_64`.

In order to use dm.thinpooldev you must have an LVM thinpool available, the
`docker-storage-setup` package will assist you in configuring LVM. However you
must provision your host to fit one of these three scenarios :

*  Root filesystem on LVM with free space remaining on the volume group. Run
`docker-storage-setup` with no additional configuration, it will allocate the
remaining space for the thinpool.

*  A dedicated LVM volume group where you'd like to reate your thinpool

        echo <<EOF > /etc/sysconfig/docker-storage-setup
        VG=docker-vg
        SETUP_LVM_THIN_POOL=yes
        EOF
        docker-storage-setup

*  A dedicated block device, which will be used to create a volume group and thinpool

        cat <<EOF > /etc/sysconfig/docker-storage-setup
        DEVS=/dev/vdc
        VG=docker-vg
        SETUP_LVM_THIN_POOL=yes
        EOF
        docker-storage-setup

Once complete you should have a thinpool named `docker-pool` and docker should
be configured to use it in `/etc/sysconfig/docker-storage`.

    # lvs
    LV                  VG        Attr       LSize  Pool Origin Data%  Meta% Move Log Cpy%Sync Convert
    docker-pool         docker-vg twi-a-tz-- 48.95g             0.00   0.44

    # cat /etc/sysconfig/docker-storage
    DOCKER_STORAGE_OPTIONS=--storage-opt dm.fs=xfs --storage-opt dm.thinpooldev=/dev/mapper/openshift--vg-docker--pool

**Note:** If you had previously used docker with loopback storage you should
clean out `/var/lib/docker` This is a destructive operation and will delete all
images and containers on the host.

    systemctl stop docker
    rm -rf /var/lib/docker/*
    systemctl start docker

environment happen **faster**, you'll need to first install Docker if you didn't
install it when (optionally) configuring the Docker storage previously.
Make sure that you are running at least `docker-1.6.2-6.el7.x86_64`.
    docker pull registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-deployer:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-sti-builder:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-sti-image-builder:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-builder:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-pod:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-registry:v0.5.2.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-keepalived-ipfailover:v0.5.2.2
    docker pull registry.access.redhat.com/jboss-eap-6/eap-openshift
    rm /etc/sysconfig/docker*
### Add Development Users
In the "real world" your developers would likely be using the OpenShift tools on
their own machines (`osc` and the web console). For the Beta training, we
will create user accounts for two non-privileged users of OpenShift, *joe* and
*alice*, on the master. This is done for convenience and because we'll be using
`htpasswd` for authentication.

    useradd joe
    useradd alice

We will come back to these users later. Remember to do this on the `master`
system, and not the nodes.

Install the packages for Ansible:
    git clone https://github.com/detiber/openshift-ansible.git -b v3-beta4
    /bin/cp -r ~/training/beta4/ansible/* /etc/ansible/
hostnames, modify /etc/ansible/hosts accordingly. 
There was also some information about "regions" and "zones" in the hosts file.
Let's talk about those concepts now.
## Regions and Zones
If you think you're about to learn how to configure regions and zones in
OpenShift 3, you're only partially correct.
In OpenShift 2, we introduced the specific concepts of "regions" and "zones" to
enable organizations to provide some topologies for application resiliency. Apps
would be spread throughout the zones in a region and, depending on the way you
configured OpenShift, you could make different regions accessible to users.

The reason that you're only "partially" correct in your assumption is that, for
OpenShift 3, Kubernetes doesn't actually care about your topology. In other
words, OpenShift is "topology agnostic". In fact, OpenShift 3 provides advanced
controls for implementing whatever topologies you can dream up, leveraging
filtering and affinity rules to ensure that parts of applications (pods) are
either grouped together or spread apart.

For the purposes of a simple example, we'll be sticking with the "regions" and
"zones" theme. But, as you go through these examples, think about what other
complex topologies you could implement. Perhaps "secure" and "insecure" hosts,
or other topologies.

First, we need to talk about the "scheduler" and its default configuration.

### Scheduler and Defaults
The "scheduler" is essentially the OpenShift master. Any time a pod needs to be
created (instantiated) somewhere, the master needs to figure out where to do
this. This is called "scheduling". The default configuration for the scheduler
looks like the following JSON (although this is embedded in the OpenShift code
and you won't find this in a file):

    {
      "predicates" : [
        {"name" : "PodFitsResources"},
        {"name" : "MatchNodeSelector"},
        {"name" : "HostName"},
        {"name" : "PodFitsPorts"},
        {"name" : "NoDiskConflict"}
      ],"priorities" : [
        {"name" : "LeastRequestedPriority", "weight" : 1},
        {"name" : "ServiceSpreadingPriority", "weight" : 1}
      ]
    }

When the scheduler tries to make a decision about pod placement, first it goes
through "predicates", which essentially filter out the possible nodes we can
choose. Note that, depending on your predicate configuration, you might end up
with no possible nodes to choose. This is totally OK (although generally not
desired).

These default options are documented in the link above, but the quick overview
is:

* Place pod on a node that has enough resources for it (duh)
* Place pod on a node that doesn't have a port conflict (duh)
* Place pod on a node that doesn't have a storage conflict (duh)

And some more obscure ones:

* Place pod on a node whose `NodeSelector` matches
* Place pod on a node whose hostname matches the `Host` attribute value

The next thing is, of the available nodes after the filters are applied, how do
we select the "best" one. This is where "priorities" come in. Long story short,
the various priority functions each get a score, multiplied by the weight, and
the node with the highest score is selected to host the pod.

Again, the defaults are:

* Choose the node that is "least requested" (the least busy)
* Spread services around - minimize the number of pods in the same service on
    the same node

And, for an extremely detailed explanation about what these various
configuration flags are doing, check out:

    http://docs.openshift.org/latest/admin_guide/scheduler.html

In a small environment, these defaults are pretty sane. Let's look at one of the
important predicates (filters) before we move on to "regions" and "zones".

### The NodeSelector
`NodeSelector` is a part of the Pod data model. And, if we think back to our pod
definition, there was a "label", which is just a key:value pair. In the case of
a `NodeSelector`, our labels (key:value pairs) are used to help us try to find
nodes that match, assuming that:

* The scheduler is configured to MatchNodeSelector
* The end user creating the pod knows which labels are out there

But this use case is also pretty simplistic. It doesn't really allow for a
topology, and there's not a lot of logic behind it. Also, if I specify a
NodeSelector label when using MatchNodeSelector and there are no matching nodes,
my workload will never get scheduled. Bummer.

How can we make this more intelligent? We'll finally use "regions" and "zones".

### Customizing the Scheduler Configuration
The Ansible installer is configured to understand "regions" and "zones" as a
matter of convenience. However, for the master (scheduler) to actually do
something with them requires changing from the default configuration Take a look
at `/etc/openshift/master/master-config.yaml` and find the line with `schedulerConfigFile`.

You should see:

    schedulerConfigFile: "/etc/openshift/master/scheduler.json"

Then, take a look at `/etc/openshift/master/scheduler.json`. It will have the
following content:

    {
      "predicates" : [
        {"name" : "PodFitsResources"},
        {"name" : "PodFitsPorts"},
        {"name" : "NoDiskConflict"},
        {"name" : "Region", "argument" : {"serviceAffinity" : { "labels" : ["region"]}}}
      ],"priorities" : [
        {"name" : "LeastRequestedPriority", "weight" : 1},
        {"name" : "ServiceSpreadingPriority", "weight" : 1},
        {"name" : "Zone", "weight" : 2, "argument" : {"serviceAntiAffinity" : { "label" : "zone" }}}
      ]
    }

To quickly review the above (this explanation sort of assumes that you read the
scheduler documentation, but it's not critically important):

* Filter out nodes that don't fit the resources, don't have the ports, or have
    disk conflicts
* If the pod specifies a label with the key "region", filter nodes by the value.

So, if we have the following nodes and the following labels:

* Node 1 -- "region":"infra"
* Node 2 -- "region":"primary"
* Node 3 -- "region":"primary"

If we try to schedule a pod that has a `NodeSelector` of "region":"primary",
then only Node 1 and Node 2 would be considered.

OK, that takes care of the "region" part. What about the "zone" part?

Our priorities tell us to:

* Score the least-busy node higher
* Score any nodes who don't already have a pod in this service higher
* Score any nodes whose zone label's value **does not** match higher

Why do we score a zone that **doesn't** match higher? Note that the definition
for the Zone priority is a `serviceAntiAffinity` -- anti affinity. In this case,
our anti affinity rule helps to ensure that we try to get nodes from *different*
zones to take our pod.

If we consider that our "primary" region might be a certain datacenter, and that
each "zone" in that datacenter might be on its own power system with its own
dedicated networking, this would ensure that, within the datacenter, pods of an
application would be spread across power/network segments.

The documentation link has some more complicated examples. The topoligical
possibilities are endless!

### Node Labels
The assignments of "regions" and "zones" at the node-level are handled by labels
on the nodes. You can look at how the labels were implemented by doing:

    osc get nodes

    NAME                      LABELS                                                                     STATUS
    ose3-master.example.com   kubernetes.io/hostname=ose3-master.example.com,region=infra,zone=default   Ready
    ose3-node1.example.com    kubernetes.io/hostname=ose3-node1.example.com,region=primary,zone=east     Ready
    ose3-node2.example.com    kubernetes.io/hostname=ose3-node2.example.com,region=primary,zone=west     Ready

At this point we have a running OpenShift environment across three hosts, with
one master and three nodes, divided up into two regions -- "*infra*structure"
and "primary".

From here we will start to deploy "applications" and other resources into
OpenShift.
**Note:** You will want to do this on the other nodes, but you won't need the
"-master" service. You may also wish to watch the Docker logs, too.
    touch /etc/openshift/openshift-passwd
    htpasswd -b /etc/openshift/openshift-passwd joe redhat
    htpasswd -b /etc/openshift/openshift-passwd alice redhat

Remember, you created these users previously.
`/etc/openshift/master/master-config.yaml`. Ansible was configured to edit
the `oauthConfig`'s `identityProviders` stanza so that it looks like the following:
        file: /etc/openshift/openshift-passwd
More information on these configuration settings (and other identity providers) can be found here:
Be aware that it may take up to 90 seconds for the web console to be available
any time you restart the master.
On your first visit your browser will need to accept the self-signed SSL
certificate. You will then be asked for a username and a password. Remembering
that we created a user previously, `joe`, go ahead and enter that and use
the password (`redhat`) you set earlier.
Also, don't forget, the materials for these labs are in your `~/training/beta4`
### Resources
to it. Still in a `root` terminal in the `training/beta4` folder:
### Applying Limit Ranges to Projects
In order for quotas to be effective you need to also create Limit Ranges
which set the maximum, minimum, and default allocations of memory and cpu at
both a pod and container level. Without default values for containers projects
with quotas will fail because the deloyer and other infrastructure pods are
unbounded and therefore forbidden.

As `root` in the `training/beta4` folder:

    osc create -f limits.json --namespace=demo

Review your limit ranges
    osc describe limitranges limits -n demo
    Name:           limits
    Type            Resource        Min     Max     Default
    ----            --------        ---     ---     ---
    Pod             memory          5Mi     750Mi   -
    Pod             cpu             10m     500m    -
    Container       cpu             10m     500m    100m
    Container       memory          5Mi     750Mi   100Mi


    --certificate-authority=/etc/openshift/master/ca.crt \
        certificate-authority: ../../../../etc/openshift/master/ca.crt
      name: ose3-master-example-com:8443
        cluster: ose3-master-example-com:8443
        user: joe/ose3-master-example-com:8443
      name: demo/ose3-master-example-com:8443/joe
    current-context: demo/ose3-master-example-com:8443/joe
    - name: joe/ose3-master-example-com:8443
        token: _ebJfOdcHy8TW4XIDxJjOQEC_yJp08zW0xPI-JWWU3c
    cd ~/training/beta4
In the beta4 training folder, you can see the contents of our pod definition by
using `cat`:
      "apiVersion": "v1beta3",
      "metadata": {
        "name": "hello-openshift",
        "creationTimestamp": null,
        "labels": {
          "name": "hello-openshift"
        }
      "spec": {
        "containers": [
          {
            "ports": [
              {
                "hostPort": 36061,
                "containerPort": 8080,
                "protocol": "TCP"
              }
            ],
            "resources": {
              "limits": {
                "cpu": "10m",
                "memory": "16Mi"
              }
            },
            "terminationMessagePath": "/dev/termination-log",
            "imagePullPolicy": "IfNotPresent",
            "capabilities": {},
            "securityContext": {
              "capabilities": {},
              "privileged": false
            },
            "nodeSelector": {
              "region": "primary"
            }
          }
        ],
        "restartPolicy": "Always",
        "dnsPolicy": "ClusterFirst",
        "serviceAccount": ""
      },
      "status": {}
As `joe`, to create the pod from our JSON file, execute the following:
    POD               IP         CONTAINER(S)      IMAGE(S)                           HOST                                   LABELS                 STATUS    CREATED      MESSAGE
    hello-openshift   10.1.1.2                                                        ose3-node1.example.com/192.168.133.3   name=hello-openshift   Running   16 seconds   
                                 hello-openshift   openshift/hello-openshift:v0.4.3                                                                 Running   2 seconds   

The output of this command shows all of the Docker containers in a pod, which
explains some of the spacing.

On the node where the pod is running (`HOST`), look at the list of Docker
containers with `docker ps` (in a `root` terminal) to see the bound ports.  We
should see an `openshift3_beta/ose-pod` container bound to 36061 on the host and
bound to 8080 on the container, along with several other `ose-pod` containers.
To verify that the app is working, you can issue a curl to the app's port *on
the node where the pod is running*
    [root@ose3-node1 ~]# curl localhost:36061
You can also use `osc` to determine the current quota usage of your project. As
`joe`:

    osc describe quota test-quota -n demo

As `joe`, go ahead and delete this pod so that you don't get confused in later examples:
As `joe`, go ahead and use `osc create` and you will see the following:
    osc create -f hello-quota.json 
    pods/hello-openshift-1
    pods/hello-openshift-2
    pods/hello-openshift-3
    Error from server: Pod "hello-openshift-4" is forbidden: Limited to 3 pods
      "apiVersion": "v1beta3",
      "metadata": {
        "name": "hello-service"
      },
      "spec": {
        "selector": {
          "name":"hello-openshift"
        },
        "ports": [
          {
            "protocol": "TCP",
            "port": 80,
            "targetPort": 9376
          }
        ]
      "apiVersion": "v1beta3",
      "spec": {
        "host": "hello-openshift.cloudapps.example.com",
        "to": {
          "name": "hello-openshift-service"
        },
        "tls": {
          "termination": "edge"
        }
      }
You'll notice that the definition above specifies TLS edge termination. This
means that the router should provide this route via HTTPS. Because we provided
no certificate info, the router will provide the default SSL certificate when
the user connects. Because this is edge termination, user connections to the
router will be SSL encrypted but the connection between the router and the pods
is unencrypted.

It is possible to utilize various TLS termination mechanisms, and more details
is provided in the router documentation:

    http://docs.openshift.org/latest/architecture/core_objects/routing.html#securing-routes

We'll see this edge termination in action shortly.

### Creating a Wildcard Certificate In order to serve a valid certificate for
secure access to applications in our cloud domain, we will need to create a key
and wildcard certificate that the router will use by default for any routes that
do not specify a key/cert of their own. OpenShift supplies a command for
creating a key/cert signed by the OpenShift CA which we will use.  On the
master, as `root`:

    CA=/etc/openshift/master
    osadm create-server-cert --signer-cert=$CA/ca.crt \
          --signer-key=$CA/ca.key --signer-serial=$CA/ca.serial.txt \
          --hostnames='*.cloudapps.example.com' \
          --cert=cloudapps.crt --key=cloudapps.key

Now we need to combine `cloudapps.crt` and `cloudapps.key` with the CA into
a single PEM format file that the router needs in the next step.

    cat cloudapps.crt cloudapps.key $CA/ca.crt > cloudapps.router.pem

Make sure you remember where you put this PEM file.

interface, unlike most containers that listen only on private IPs. The router
As the `root` user, try running it with no options and you will see that
some options are needed to create the router:
    F0223 11:50:57.985423    2610 router.go:143] Router "router" does not exist
    F0223 11:51:19.350154    2617 router.go:148] You must specify a .kubeconfig
    osadm router --dry-run \
    --credentials=/etc/openshift/master/openshift-router.kubeconfig

Adding that would be enough to allow the command to proceed, but if we want
this router to work for our environment, we also need to specify the beta
router image (the tooling defaults to upstream/origin otherwise) and we need
to supply the wildcard cert/key that we created for the cloud domain.

    osadm router --default-cert=cloudapps.router.pem \
    --credentials=/etc/openshift/master/openshift-router.kubeconfig \
    --selector='region=infra' \
**Note:** You will have to reference the absolute path of the PEM file if you
did not run this command in the folder where you created it.
Let's check the pods:

    osc get pods 
    POD              IP         CONTAINER(S)   IMAGE(S)                                                                 HOST                                    LABELS                                                      STATUS    CREATED      MESSAGE
    router-1-cutck   10.1.0.4                                                                                           ose3-master.example.com/192.168.133.2   deployment=router-1,deploymentconfig=router,router=router   Running   18 minutes   
                                router         registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.5.2.2                                                                                                       Running   18 minutes

Note: This output is huge, wide, and ugly. We're working on making it nicer. You
can chime in here:

    https://github.com/GoogleCloudPlatform/kubernetes/issues/7843

In the above router creation command (`osadm router...`) we also specified
`--selector`. This flag causes a `nodeSelector` to be placed on all of the pods
created. If you think back to our "regions" and "zones" conversation, the
OpenShift environment is currently configured with an *infra*structure region
called "infra". This `--selector` argument asks OpenShift:
*Please place all of these router pods in the infra region*.
DNS entry points to the public IP address of the master, the `--selector` flag
used above ensures that the router is placed on our master as it's the only node
with the label `region=infra`.
For a true HA implementation, one would want multiple "infra" nodes and
multiple, clustered router instances. We will describe this later.
### Viewing Router Stats
Haproxy provides a stats page that's visible on port 1936 of your router host.
Currently the stats page is password protected with a static password, this
password will be generated using a template parameter in the future, for now the
password is `cEVu2hUb` and the username is `admin`.
To make this acessible publicly, you will need to open this port on your master:
    iptables -I OS_FIREWALL_ALLOW -p tcp -m tcp --dport 1936 -j ACCEPT

You will also want to add this rule to `/etc/sysconfig/iptables` as well to keep it
across reboots. However, don't restart the iptables service, as this would destroy
docker networking. Use the `iptables` command to change rules on a live system.

Feel free to not open this port if you don't want to make this accessible, or if
you only want it accessible via port fowarding, etc.

**Note**: Unlike OpenShift v2 this router is not specific to a given project, as
such it's really intended to be viewed by cluster admins rather than project
admins.

Ensure that port 1936 is accessible and visit:

    http://admin:cEVu2hUb@ose3-master.example.com:1936 

to view your router stats.
Don't forget -- the materials are in `~/training/beta4`.
      "kind": "Config",
      "apiVersion": "v1beta3",
      "metadata": {
        "name": "hello-service-complete-example"
      "items": [
          "apiVersion": "v1beta3",
          "metadata": {
            "name": "hello-openshift-service"
          },
          "spec": {
            "selector": {
              "name": "hello-openshift"
            },
            "ports": [
              {
                "protocol": "TCP",
                "port": 27017,
                "targetPort": 8080
              }
            ]
          "apiVersion": "v1beta3",
          "spec": {
            "host": "hello-openshift.cloudapps.example.com",
            "to": {
              "name": "hello-openshift-service"
            },
            "tls": {
              "termination": "edge"
            }
          }
          "kind": "DeploymentConfig",
          "apiVersion": "v1beta3",
          },
          "spec": {
            "strategy": {
              "type": "Recreate",
              "resources": {}
            },
            "replicas": 1,
            "selector": {
              "name": "hello-openshift"
              "metadata": {
                "creationTimestamp": null,
                "labels": {
                  "name": "hello-openshift"
                }
              },
              "spec": {
                "containers": [
                  {
                    "name": "hello-openshift",
                    "image": "openshift/hello-openshift:v0.4.3",
                    "ports": [
                      {
                        "name": "hello-openshift-tcp-8080",
                        "containerPort": 8080,
                        "protocol": "TCP"
                      }
                    ],
                    "resources": {},
                    "terminationMessagePath": "/dev/termination-log",
                    "imagePullPolicy": "PullIfNotPresent",
                    "capabilities": {},
                    "securityContext": {
                      "capabilities": {},
                      "privileged": false
                    "livenessProbe": {
                      "tcpSocket": {
                        "port": 8080
                      },
                      "timeoutSeconds": 1,
                      "initialDelaySeconds": 10
                  }
                ],
                "restartPolicy": "Always",
                "dnsPolicy": "ClusterFirst",
                "serviceAccount": "",
                "nodeSelector": {
                  "region": "primary"
              }
            }
          },
          "status": {
          }
* There is a pod whose containers have the label `name=hello-openshift-label` and the nodeSelector `region=primary`
  * with the `spec` `to` `name=hello-openshift-service`
    `name=hello-openshift-label`
    `name=hello-openshift-label`
If you are not using the `example.com` domain you will need to edit the route
portion of `test-complete.json` to match your DNS environment.

**Logged in as `joe`,** go ahead and use `osc` to create everything:
You should see something like the following:
    pods/hello-openshift
**Note:** May need to force resize:

    https://github.com/openshift/origin/issues/2939

    
    service hello-openshift-service (172.30.197.132:27017 -> 8080)
    
    To see more information about a Service or DeploymentConfig, use 'osc describe service <name>' or 'osc describe dc <name>'.
You can use 'osc get all' to see lists of each of the types described above.
We can use `osc exec` to get a bash interactive shell inside the running
router container. The following command will do that for us:
    osc exec -it -p $(osc get pods | grep router | awk '{print $1}' | head -n 1) /bin/bash
      "Name": "demo/hello-openshift-service",
      "EndpointTable": {
        "10.1.0.9:8080": {
          "ID": "10.1.0.9:8080",
          "IP": "10.1.0.9",
          "Port": "8080"
        }
      },
      "ServiceAliasConfigs": {
        "demo-hello-openshift-route": {
          "Host": "hello-openshift.cloudapps.example.com",
          "Path": "",
          "TLSTermination": "edge",
          "Certificates": {
            "hello-openshift.cloudapps.example.com": {
              "ID": "demo-hello-openshift-route",
              "Contents": "",
              "PrivateKey": ""
            }
          },
          "Status": "saved"
Go ahead and `exit` from the container.

    [root@router-1-2yefi /]# exit
    exit
You can reach the route securely and check that it is using the right certificate:

    curl --cacert /etc/openshift/master/ca.crt \
             https://hello-openshift.cloudapps.example.com
And:
    openssl s_client -connect hello.cloudapps.example.com:443 \
                       -CAfile /etc/openshift/master/ca.crt
    CONNECTED(00000003)
    depth=1 CN = openshift-signer@1430768237
    verify return:1
    depth=0 CN = *.cloudapps.example.com
    verify return:1
    [...]
Since we used OpenShift's CA to create the wildcard SSL certificate, and since
that CA is not "installed" in our system, we need to point our tools at that CA
certificate in order to validate the SSL certificate presented to us by the
router. With a CA or all certificates signed by a trusted authority, it would
not be necessary to specify the CA everywhere.
Open a new terminal window as the `alice` user:

    su - alice

and login to OpenShift:
    --certificate-authority=/etc/openshift/master/ca.crt \
You'll interact with the tool as follows:

pods` and so forth should show her the same thing as `joe`:
    POD               IP         CONTAINER(S)      IMAGE(S)                           HOST                                   LABELS                 STATUS    CREATED      MESSAGE
    hello-openshift   10.1.1.2                                                        ose3-node1.example.com/192.168.133.3   name=hello-openshift   Running   14 minutes   
                                 hello-openshift   openshift/hello-openshift:v0.4.3                                                                 Running   14 minutes   
However, she cannot make changes:

    [alice]$ osc delete pod hello-openshift
    Error from server: User "alice" cannot delete pods in project "demo"
`joe` could also give `alice` the role of `edit`, which gives her access
to do nearly anything in the project except adjust access.
There is no "owner" of a project, and projects can certainly be created
without any administrator. `alice` or `joe` can remove the `admin`
role (or all roles) from each other or themselves at any time without
affecting the existing project.
**Note:** There is a bug that actually prevents the remove-user from removing
the user:

https://github.com/openshift/origin/issues/2785

It appears to be fixed but may not have made beta4.

## Preparing for S2I: the Registry
### Storage for the registry
The registry is stores docker images and metadata. If you simply deploy a pod
with the registry, it will use an ephemeral volume that is destroyed once the
pod exits. Any images anyone has built or pushed into the registry would
disappear. That would be bad.

What we will do for this demo is use a directory on the master host for
persistent storage. In production, this directory could be backed by an NFS
mount supplied from the HA storage solution of your choice. That NFS mount
could then be shared between multiple hosts for multiple replicas of the
registry to make the registry HA.

For now we will just show how to specify the directory and the and leave the NFS
configuration as an exercise. On the master, as `root`, create the storage
directory with:

    mkdir -p /mnt/registry

### Creating the registry

    --credentials=/etc/openshift/master/openshift-registry.kubeconfig \
    --images='registry.access.redhat.com/openshift3_beta/ose-${component}:${version}' \
    --selector="region=infra" --mount-host=/mnt/registry
      docker-registry deploys registry.access.redhat.com/openshift3_beta/ose-docker-registry
      router deploys registry.access.redhat.com/openshift3_beta/ose-haproxy-router
One interesting features of `osc status` is that it lists recent deployments.
When we created the router and registry, each created one deployment.  We will
talk more about deployments when we get into builds.

Anyway, you will ultimately have a Docker registry that is being hosted by OpenShift
and that is running on the master (because we specified "region=infra" as the
registry's node selector).
    curl -v `osc get services | grep registry | awk '{print $4":"$5}' | sed -e 's/\/.*//'`/v2/
And you should see [a 200
response](https://docs.docker.com/registry/spec/api/#api-version-check) and a
mostly empty body.  Your IP addresses will almost certainly be different.

~~~~
* About to connect() to 172.30.17.114 port 5000 (#0)
*   Trying 172.30.17.114...
* Connected to 172.30.17.114 (172.30.17.114) port 5000 (#0)
> GET /v2/ HTTP/1.1
> User-Agent: curl/7.29.0
> Host: 172.30.17.114:5000
> Accept: */*
>
< HTTP/1.1 200 OK
< Content-Length: 2
< Content-Type: application/json; charset=utf-8
< Docker-Distribution-Api-Version: registry/2.0
< Date: Tue, 26 May 2015 17:18:02 GMT
<
* Connection #0 to host 172.30.17.114 left intact
{}    
~~~~
    Type:                   ClusterIP
    IP:                     172.30.239.41
    Endpoints:              <unnamed>       10.1.0.4:5000
Once there is an endpoint listed, the curl should work and the registry is available.
Highly available, actually. You should be able to delete the registry pod at any
point in this training and have it return shortly after with all data intact.
## S2I - What Is It?
S2I stands for *source-to-image* and is the process where OpenShift will take
By default, users are allowed to create their own projects. Let's try this now.
As the `joe` user, we will create a new project to put our first S2I example
into:

    osc new-project sinatra --display-name="Sinatra Example" \
    --description="This is your first build on OpenShift 3" 

Logged in as `joe` in the web console, if you click the OpenShift image you
should be returned to the project overview page where you will see the new
project show up. Go ahead and click the *Sinatra* project - you'll see why soon.
    osc new-app -o json https://github.com/openshift/simple-openshift-sinatra-sti.git
Essentially, the S2I process is as follows:
There are currently two ways to get from source code to components on OpenShift.
The CLI has a tool (`new-app`) that can take a source code repository as an
input and will make its best guesses to configure OpenShift to do what we need
to build and run the code. You looked at that already.

You can also just run `osc new-app --help` to see other things that `new-app`
can help you achieve.

The web console also lets you point directly at a source code repository, but
requires a little bit more input from a user to get things running. Let's go
through an example of pointing to code via the web console. Later examples will
use the CLI tools.
While `new-app` has some built-in logic to help automatically determine the
correct builder ImageStream, the web console currently does not have that
capability. The user will have to first target the code repository, and then
select the appropriate builder image.
Perform the following command as `root` in the `beta4`folder in order to add all
of the builder images:
    osc create -f image-streams-rhel7.json \
    -f image-streams-jboss-rhel7.json -n openshift
    imageStreams/ruby
    imageStreams/nodejs
    imageStreams/perl
    imageStreams/php
    imageStreams/python
    imageStreams/mysql
    imageStreams/postgresql
    imageStreams/mongodb
    imageStreams/jboss-webserver3-tomcat7-openshift
    imageStreams/jboss-webserver3-tomcat8-openshift
    imageStreams/jboss-eap6-openshift
    imageStreams/jboss-amq-62
    imageStreams/jboss-mysql-55
    imageStreams/jboss-postgresql-92
    imageStreams/jboss-mongodb-24
S2I builder) and the application code. While it's "obvious" that we need to
An organization will likely choose several supported builders and databases from
Red Hat, but may also create their own builders, DBs, and other images. This
system provides a great deal of flexibility.
`ruby:latest`. You'll see a pop-up with some more details asking for
    osc get builds
    ruby-example-1   Source    Running   ruby-example-1
    A build of ruby-example is running. A new deployment will be
    osc build-logs ruby-example-1
    SERVICE: RUBY-EXAMPLE routing traffic on 172.30.17.20 port 8080 - 8080 (tcp)
**Hint:** It is `ruby-example`.

    ruby-example         ruby-example.sinatra.router.default.local             ruby-example   generatedby=OpenShiftWebConsole,name=ruby-example
**Note:** HTTPS will *not* work for this route, because we have not specified
any TLS termination.

**THIS SECTION IS BROKEN**

There is currently a bug with quota enforcement. Do **NOT** apply the quota to
this project. Skip ahead to the scaling part.

    https://github.com/openshift/origin/issues/2821

** SKIP THIS**

`*
There is currently no default "size" for applications that are created with the
web console. This means that, whether you think it's a good idea or not, the
application is actually unbounded -- it can consume as much of a node's
resources as it wants.

Before we can try to scale our application, we'll need to update the deployment
to put a memory and CPU limit on the pods. Go ahead and edit the
`deploymentConfig`, as `joe`:

    osc edit dc/ruby-example-1 -o json

You'll need to find "spec", "containers" and then the "resources" block in
there. It's after a bunch of `env`ironment variables. Update that "resources"
block to look like this:

        "resources": {
          "limits": {
            "cpu": "10m",
            "memory": "16Mi"
          }
        },
`*
As `joe` scale your application up to three instances using the `osc resize`
command:
    osc resize --replicas=3 rc/ruby-example-1
    osc get pods | grep -v "example"
"east" and "west". You can also see this in the web console. Cool!
**SKIP THIS**

*`
    ruby-example-1   Source    Complete   ruby-example-1
    ruby-example-2   Source    New        ruby-example-2
this project to three and this includes ephemeral pods like S2I builders.
`*
As `joe`, create a new project:
    osc new-project quickstart --display-name="Quickstart" \
    --description='A demonstration of a "quickstart/template"'
This also changes you to use that project:
    Now using project "quickstart" on server "https://ose3-master.example.com:8443".
Go ahead and do the following as `root` in the `~/training/beta4` folder:
of template (relaly, it just has the "instant-app" tag). The idea behind an
a fully functional application. in this example, our "instant" app is just a
the *frontend* service:
Then, create a project for this example:
    osc new-project wiring --display-name="Exploring Parameters" \
    --description='An exploration of wiring using parameters'
    cd ~/training/beta4
This template uses the Red Hat MySQL Docker container, which knows to take some
the upstream of this container can be found here:
**Note:** There is a process to deploy instances of templates that we already
used in the "quickstart" case. For some reason, the MySQL database template
doesn't deploy successfully with the current example. Otherwise we would have
done 100% of this through the webUI.

Here's the bug for reference:

    https://github.com/openshift/origin/issues/2947

## Using Persistent Storage (Optional)
Having a database for development is nice, but what if you actually want the
data you store to stick around after the DB pod is redeployed? Pods are
ephemeral, and so is their storage by default. For shared or persistent
storage, we need a way to specify that pods should use external volumes.

We can do this a number of ways. [Kubernetes provides methods for directly
specifying the mounting of several different volume
types.](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/volumes.md)
This is perfect if you want to use known external resources. But that's
not very PaaS-y. If I'm using a PaaS, I might really just rather request a
chunk of storage and not need a side channel to provision that. OpenShift 3
provides a mechanism for doing just this.

### Export an NFS Volume
For the purposes of this training, we will just demonstrate the master
exporting an NFS volume for use as storage by the database. **You would
almost certainly not want to do this in production.** If you happen
to have another host with an NFS export handy, feel free to substitute
that instead of the master.

As `root` on the master:

1. Ensure that nfs-utils is installed (**on all systems**):

        yum install nfs-utils

2. Create the directory we will export:

        mkdir -p /var/export/vol1
        chown nfsnobody:nfsnobody /var/export/vol1
        chmod 700 /var/export/vol1

3. Edit `/etc/exports` and add the following line:

        /var/export/vol1 *(rw,sync,all_squash)

4. Enable and start NFS services:

        systemctl enable rpcbind nfs-server
        systemctl start rpcbind nfs-server nfs-lock nfs-idmap

Note that the volume is owned by `nfsnobody` and access by all remote users
is "squashed" to be access by this user. This essentially disables user
permissions for clients mounting the volume. While another configuration
might be preferable, one problem you may run into is that the container
cannot modify the permissions of the actual volume directory when mounted.
In the case of MySQL below, MySQL would like to have the volume belong to
the `mysql` user, and assumes that it is, which causes problems later.
Arguably, the container should operate differently. In the long run, we
probably need to come up with best practices for use of NFS from containers.

### NFS Firewall
We will need to open ports on the firewall on the master to enable NFS to
communicate from the nodes. First, let's add rules for NFS to the running state
of the firewall:

    iptables -I OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 111 -j ACCEPT
    iptables -I OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 2049 -j ACCEPT
    iptables -I OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 20048 -j ACCEPT
    iptables -I OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 50825 -j ACCEPT
    iptables -I OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 53248 -j ACCEPT

Next, let's add the rules to `/etc/sysconfig/iptables`. Put them at the top of
the `OS_FIREWALL_ALLOW` set:

    -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 53248 -j ACCEPT
    -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 50825 -j ACCEPT
    -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 20048 -j ACCEPT
    -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 2049 -j ACCEPT
    -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 111 -j ACCEPT

Now, we have to edit NFS' configuration to use these ports. First, let's edit
`/etc/sysconfig/nfs`. Change the RPC option to the following:

    RPCMOUNTDOPTS="-p 20048"

Change the STATD option to the following:

    STATDARG="-p 50825"

Then, edit `/etc/sysctl.conf`:

    fs.nfs.nlm_tcpport=53248
    fs.nfs.nlm_udpport=53248

Then, persist the `sysctl` changes:

    sysctl -p

Lastly, restart NFS:

    systemctl restart nfs

### Allow NFS Access in SELinux Policy
By default policy, containers are not allowed to write to NFS mounted
directories.  We want to do just that with our database, so enable that on
all nodes where the pod could land (i.e. all of them) with:

    setsebool -P virt_use_nfs=true

Once the ansible-based installer does this automatically, we can remove this
section from the document.

### Create a PersistentVolume
It is the PaaS administrator's responsibility to define the storage that is
available to users. Storage is represented by a PersistentVolume that
encapsulates the details of a particular volume which can be backed by any
of the [volume types available via
Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/volumes.md).
In this case it will be our NFS volume.

Currently PersistentVolume objects must be created "by hand". Modify the
`beta4/persistent-volume.json` file as needed if you are using a different
NFS mount:

    {
      "apiVersion": "v1",
      "kind": "PersistentVolume",
      "metadata": {
        "name": "pv0001"
      },
      "spec": {
        "capacity": {
            "storage": "5Gi"
            },
        "accessModes": [ "ReadWriteMany" ],
        "nfs": {
            "path": "/var/export/vol1",
            "server": "ose3-master.example.com"
        }
      }
    }

Create this object as the `root` (administrative) user:

    # osc create -f persistent-volume.json
    persistentvolumes/pv0001

This defines a volume for OpenShift projects to use in deployments. The
storage should correspond to how much is actually available (make each
volume a separate filesystem if you want to enforce this limit). Take a
look at it now:

    # osc describe persistentvolumes/pv0001
    Name:   pv0001
    Labels: <none>
    Status: Available
    Claim:

### Claim the PersistentVolume
Now that the administrator has provided a PersistentVolume, any project can
make a claim on that storage. We do this by creating a PersistentVolumeClaim
that specifies what kind and how much storage is desired:

    {
      "apiVersion": "v1",
      "kind": "PersistentVolumeClaim",
      "metadata": {
        "name": "claim1"
      },
      "spec": {
        "accessModes": [ "ReadWriteMany" ],
        "resources": {
          "requests": {
            "storage": "5Gi"
          }
        }
      }
    }

We can have `alice` do this in the `wiring` project:

    $ osc create -f persistent-volume-claim.json
    persistentVolumeClaim/claim1

This claim will be bound to a suitable PersistentVolume (one that is big
enough and allows the requested accessModes). The user does not have any
real visibility into PersistentVolumes, including whether the backing
storage is NFS or something else; they simply know when their claim has
been filled ("bound" to a PersistentVolume).

    $ osc get pvc
    NAME      LABELS    STATUS    VOLUME
    claim1    map[]     Bound     pv0001

If as `root` we now go back and look at our PV, we will also see that it has
been claimed:

    # osc describe pv/pv0001
    Name:   pv0001
    Labels: <none>
    Status: Bound
    Claim:  wiring/claim1

The PersistentVolume is now claimed and can't be claimed by any other project.

Although this flow assumes the administrator pre-creates volumes in
anticipation of their use later, it would be possible to create an external
process that watches the API for a PersistentVolumeClaim to be created,
dynamically provisions a corresponding volume, and creates the API object
to fulfill the claim.

### Use the Claimed Volume
Finally, we need to modify our `database` DeploymentConfig to specify that
this volume should be mounted where the database will use it. As `alice`:

    $ osc edit dc/database

The part we will need to edit is the pod template. We will need to add two
parts: 

* a definition of the volume
* where to mount it inside the container

First, directly under the `template` `spec:` line, add this YAML (indented from the `spec:` line):

          volumes:
          - name: pvol
            persistentVolumeClaim:
              claimName: claim1

Then to have the container mount this, add this YAML after the
`terminationMessagePath:` line:

            volumeMounts:
            - mountPath: /var/lib/mysql/data
              name: pvol

Remember that YAML is sensitive to indentation. The final template should
look like this:

    template:
      metadata:
        creationTimestamp: null
        labels:
          deploymentconfig: database
      spec:
        volumes:
        - name: pvol
          persistentVolumeClaim:
            claimName: claim1
        containers:
        - capabilities: {}
    [...]
          terminationMessagePath: /dev/termination-log
          volumeMounts:
          - mountPath: /var/lib/mysql/data
            name: pvol
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        serviceAccount: ""

Save and exit. This change to configuration will trigger a new deployment
of the database, and this time, it will be using the NFS volume we exported
from master.

### Restart the Frontend
Any values or data we had inserted previously just got blown away. The
`deploymentConfig` update caused a new MySQL pod to be launched. Since this is
the first time the pod was launched with persistent data, any previous data was
lost.

Additionally, the Frontend pod will perform a database initialization when it
starts up. Since we haven't restarted the frontend, our database is actually
bare. If you try to use the app now, you'll get "Internal Server Error".

Go ahead and kill the Frontend pod like we did previously to cause it to
restart:

     osc delete pod `osc get pod | grep front | awk {'print $1'}`

Once the new pod has started, go ahead and visit the web page. Add a few values
via the application. Then delete the database pod and wait for it to come back.
You should be able to retrieve the same values you entered.

Remember, to quickly delete the Database pod you can do the following:

    osc delete pod/`osc get pod | grep -e "database-[0-9]" | awk {'print $1'}`

**Note:** This doesn't seem to work right now, but we're not sure why. I think
it has to do with Ruby's persistent connection to the MySQL service not going
away gracefully, or something. Killing the frontend again will definitely work.

For further confirmation that your database pod is in fact using the NFS
volume, simply check what is stored there on `master`:

    # ls /var/export/vol1
    database-3-n1i2t.pid  ibdata1  ib_logfile0  ib_logfile1  mysql  performance_schema  root

Further information on use of PersistentVolumes is available in the
[OpenShift Origin documentation](http://docs.openshift.org/latest/dev_guide/volumes.html).
This is a very new feature, so it is very manual for now, but look for more tooling
taking advantage of PersistentVolumes to be created in the future.
          ref: beta4
    https://ose3-master.example.com:8443/osapi/v1beta1/buildConfigHooks/ruby-sample-build//github?namespace=wiring
    https://ose3-master.example.com:8443/osapi/v1beta1/buildConfigHooks/ruby-sample-build//github?namespace=wiring
    ruby-sample-build-1   Source    Complete   ruby-sample-build-1
    ruby-sample-build-2   Source    Pending    ruby-sample-build-2
Generally speaking, this involves modifying the various S2I scripts from the
Once the file is added, we can now do another build. The "custom" assemble
script will log some extra data.
    https://ose3-master.example.com:8443/osapi/v1beta1/buildConfigHooks/ruby-sample-build//github?namespace=wiring
    ---> CUSTOM S2I ASSEMBLE COMPLETE
run inside of your builder pod. That's what you see by using `build-logs` - the
output of the assemble script. The
was built based on the `ruby-20-rhel7` S2I builder. 
To look inside the builder pod, as `alice`:
    osc logs `osc get pod | grep -e "[0-9]-build" | tail -1 | awk {'print $1'}` | grep CUSTOM
You should see something similar to:
    2015-04-27T22:23:24.110630393Z ---> CUSTOM S2I ASSEMBLE COMPLETE
before and after the **deployment**. In other words, once an S2I build is
your built image, execute your hook script(s), and then shut the instance down.
Neat, huh?
let's go ahead and add a database migration file. In the `beta4` folder you will
to the right folder, the rest of the steps will fail.
### Examining Deployment Hooks
Take a look at the following JSON:
        "resource": {},
You can see that both a *pre* and *post* deployment hook are defined. They don't
actually do anything useful. But they are good examples.
Since we are talking about **deployments**, let's look at our
`DeploymentConfig`s. As the `alice` user in the `wiring` project:

    osc get dc

You should see something like:

    NAME       TRIGGERS       LATEST VERSION
    database   ConfigChange   1
    frontend   ImageChange    7

Since we are trying to associate a Rails database migration hook with our
application, we are ultimately talking about a deployment of the frontend. If
you edit the frontend's `DeploymentConfig` as `alice`:

    osc edit dc frontend -ojson

Yes, the default for `osc edit` is to use YAML. For this exercise, JSON will be
easier as it is indentation-insensitive. Find the section that looks like the
following before continuing:

    "spec": {
        "strategy": {
            "type": "Recreate",
            "resources": {}
        },

Smartly, our hook pods inherit the same environment variables as the main
deployed pods, so we'll have access to the same datbase information.
Looking at the original hook example in the previous section, and our command
reference above, in the end, you will have something that looks like:
        "resources": {},
Remember, indentation isn't critical in JSON, but closing brackets and braces
are. When you are done editing the deployment config, save and quit your editor.
    grep -E "[0-9]-build" |\
need to do another build. Remember, the S2I process starts with the builder
Or go into the web console and click the "Start Build" button in the Builds
area.

About a minute after the build completes, you should see something like the following output
    POD                                IP          CONTAINER(S)               IMAGE(S)                                                                                                                HOST                                    LABELS                                                                                                                  STATUS       CREATED         MESSAGE
    database-2-rj72q                   10.1.0.15                                                                                                                                                      ose3-master.example.com/192.168.133.2   deployment=database-2,deploymentconfig=database,name=database                                                           Running      About an hour   
                                                   ruby-helloworld-database   registry.access.redhat.com/openshift3_beta/mysql-55-rhel7                                                                                                                                                                                                                               Running      About an hour   
    deployment-frontend-7-hook-4i8ch                                                                                                                                                                  ose3-node1.example.com/192.168.133.3    <none>                                                                                                                  Succeeded    41 seconds      
                                                   lifecycle                  172.30.118.110:5000/wiring/origin-ruby-sample@sha256:2984cfcae1dd42c257bd2f79284293df8992726ae24b43470e6ffd08affc3dfd                                                                                                                                                                   Terminated   36 seconds      exit code 0
    frontend-7-nnnxz                   10.1.1.24                                                                                                                                                      ose3-node1.example.com/192.168.133.3    deployment=frontend-7,deploymentconfig=frontend,name=frontend                                                           Running      29 seconds      
                                                   ruby-helloworld            172.30.118.110:5000/wiring/origin-ruby-sample@sha256:2984cfcae1dd42c257bd2f79284293df8992726ae24b43470e6ffd08affc3dfd                                                                                                                                                                   Running      26 seconds      
    ruby-sample-build-7-build                                                                                                                                                                         ose3-master.example.com/192.168.133.2   build=ruby-sample-build-7,buildconfig=ruby-sample-build,name=ruby-sample-build,template=application-template-stibuild   Succeeded    2 minutes       
                                                   sti-build                  openshift3_beta/ose-sti-builder:v0.5.2.2                                                                                                                                                                                                                                                Terminated   2 minutes       exit code 0

Yes, it's ugly, thanks for reminding us.
    osc logs deployment-frontend-7-hook-4i8ch
The output should show something like:
    == 1 SampleTable: migrating ===================================================
    -- create_table(:sample_table)
       -> 0.1075s
    == 1 SampleTable: migrated (0.1078s) ==========================================
using the `mysql` client and the environment variables (you would need the
`mysql` package installed on your master, for example).
    [alice@ose3-master beta4]$ osc get service
    NAME       LABELS    SELECTOR        IP(S)            PORT(S)
    database   <none>    name=database   172.30.108.133   5434/TCP
    frontend   <none>    name=frontend   172.30.229.16    5432/TCP
      -h 172.30.108.133 \
As `alice`, go ahead and create a new project:
    osc new-project wordpress --display-name="Wordpress" \
    --description='Building an arbitrary Wordpress Docker image'
    imageStreams/centos
    services/centos7-wordpress
    Service "centos7-wordpress" created at 172.30.135.252 with port mappings 22.
    imageStreams/centos
    deploymentConfigs/centos7-wordpress
    replicationcontrollers/centos7-wordpress-1
also brought in JBoss EAP and Tomcat S2I builder images.
Take a look at the `eap6-basic-sti.json` in the `beta4` folder.  You'll see that
there are a number of bash-style variables (`${SOMETHING}`) in use in this
template. This template is already configured to use the EAP builder image, so
we can use the web console to simply isntantiate it in the desired way.
We want to:
* set the application name to *helloworld*
* set the application hostname to *helloworld.cloudapps.example.com*
* set the Git URI to
    *https://github.com/jboss-developer/jboss-eap-quickstarts/*
* set the Git ref to *6.4.x*
* set the Git context dir to *helloworld*
* set Github and Generic trigger secrets to *secret*
Ok, we're ready:
1. Add the `eap6-basic-sti.json` template to your project using the commandline:
        osc create -f eap6-basic-sti.json
1. Go into the web console.

1. Find the project you created and click on it.

1. Click the "Create..." button.

1. Click the "Browse all templates..." button.

1. Click the "eap6-basic-sti" example.

1. Click "Select template".

Now that you are on the overview page, you'll have to click "Edit Paremeters"
and fill in the values with the things we wanted above. Hit "Create" when you
are done.

In the UI you will see a bunch of things get created -- several services, some
routes, and etc.
    osc edit bc helloworld
    strategy:
      sourceStrategy:
        from:
          kind: ImageStreamTag
          name: jboss-eap6-openshift:6.4
          namespace: openshift

**REMEMBER** indentation is *important* in YAML.

### Watch the Build
In a few moments a build will start. You can watch the build if you choose, or
just look at the web console and wait for it to finish. If you do watch the
build, you might notice some Maven errors.  These are non-critical and will not
affect the success or failure of the build.
We specified a route via defining the application hostname, so you should be able to
    http://helloworld.cloudapps.example.com/jboss-helloworld
This concludes the Beta 4 training. Look for more example applications to come!
communication.
* Your master and nodes `/etc/resolv.conf` points to the IP address of the node
* The second nameserver in `/etc/resolv.conf` on the node running dnsmasq points
  to your corporate or upstream DNS resolver (eg: Google DNS @ 8.8.8.8)

Hub.  You can find the source for it [here](beta4/images/openldap-example/).
required for `/etc/openshift/master/master-config.yaml` as well as create
    curl -v -u joe:redhat --cacert /etc/openshift/master/ca.crt \
    curl -u joe:redhat --cacert /etc/openshift/master/ca.crt \
If you've made the required changes to `/etc/openshift/master/master-config.yaml` and
Before GA the need for S2I builds in this authentication approach may go away.
    docker pull registry.access.redhat.com/openshift3_beta/ose-haproxy-router
    docker pull registry.access.redhat.com/openshift3_beta/ose-deployer
    docker pull registry.access.redhat.com/openshift3_beta/ose-sti-builder
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-builder
    docker pull registry.access.redhat.com/openshift3_beta/ose-pod
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-registry
    docker pull openshift/ruby-20-centos7
    docker pull openshift/mysql-55-centos7
    docker pull centos:centos7
    docker save -o beta1-images.tar \
    registry.access.redhat.com/openshift3_beta/ose-haproxy-router \
    registry.access.redhat.com/openshift3_beta/ose-deployer \
    registry.access.redhat.com/openshift3_beta/ose-sti-builder \
    registry.access.redhat.com/openshift3_beta/ose-docker-builder \
    registry.access.redhat.com/openshift3_beta/ose-pod \
    registry.access.redhat.com/openshift3_beta/ose-docker-registry \
    openshift/ruby-20-centos7 \
    openshift/mysql-55-centos7 \
    openshift/hello-openshift \
    centos:centos7
(STUB)

An experimental diagnostics command is in progress for OpenShift v3.
Once merged it should be available as `openshift ex diagnostics`. There may
be out-of-band updated versions of diagnostics under
[Luke Meyer's release page](https://github.com/sosiouxme/origin/releases).
**Common problems**
    In most cases if admin (certificate) auth is still working this means the token is invalid.  Soon there will be more polish in the osc tooling to handle this edge case automatically but for now the simplist thing to do is to recreate the .kubeconfig.
        # The login command creates a .kubeconfig file in the CWD.
        # But we need it to exist in ~/.kube
        cd ~/.kube
        # If a stale token exists it will prevent the beta4 login command from working
        rm .kubeconfig
        --certificate-authority=/etc/openshift/master/ca.crt \
    Check the value of $KUBECONFIG:

        echo $kubeconfig

    If you don't see anything, you may have changed your `.bash_profile` but
    have not yet sourced it. Make sure that you followed the step of adding
    `$KUBECONFIG`'s export to your `.bash_profile` and then source it:

        source ~/.bash_profile
## S2I Builds

    ec2-52-6-179-239.compute-1.amazonaws.com openshift_node_labels="{'region': 'infra', 'zone': 'default'}" #The master
    ec2-52-4-251-128.compute-1.amazonaws.com openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
- hostname
To override the the defaults, you can set the variables in your inventory. For example, if using AWS and managing dns externally, you can override the host public hostname as follows:
    ec2-52-6-179-239.compute-1.amazonaws.com openshift_node_labels="{'region': 'infra', 'zone': 'default'}" openshift_public_hostname=ose3-master.public.example.com
**Running ansible:**
    ansible ~/openshift-ansible/playbooks/byo/config.yml
Visit [Download Red Hat OpenShift Enterprise Beta](https://access.redhat.com/downloads/content/289/ver=/rhel---7/0.5.2.2/x86_64/product-downloads)
to download the Beta4 clients. You will need to sign into Customer Portal using
The CA is created on your master in `/etc/openshift/master/ca.crt`
    C:\Users\test\Downloads> osc --certificate-authority="ca.crt"
