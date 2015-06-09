<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [OpenShift Beta 3](#openshift-beta-3)
  - [Architecture and Requirements](#architecture-and-requirements)
    - [Architecture](#architecture)
    - [Requirements](#requirements)
  - [Setting Up the Environment](#setting-up-the-environment)
    - [Use a Terminal Window Manager](#use-a-terminal-window-manager)
    - [DNS](#dns)
    - [Assumptions](#assumptions)
    - [Git](#git)
    - [Preparing Each VM](#preparing-each-vm)
    - [Grab Docker Images (Optional, Recommended)](#grab-docker-images-optional-recommended)
    - [Clone the Training Repository](#clone-the-training-repository)
  - [Ansible-based Installer](#ansible-based-installer)
    - [Install Ansible](#install-ansible)
    - [Generate SSH Keys](#generate-ssh-keys)
    - [Distribute SSH Keys](#distribute-ssh-keys)
    - [Clone the Ansible Repository](#clone-the-ansible-repository)
    - [Configure Ansible](#configure-ansible)
    - [Modify Hosts](#modify-hosts)
    - [Run the Ansible Installer](#run-the-ansible-installer)
    - [Add Development Users](#add-development-users)
  - [Useful OpenShift Logs](#useful-openshift-logs)
  - [Auth, Projects, and the Web Console](#auth-projects-and-the-web-console)
    - [Configuring htpasswd Authentication](#configuring-htpasswd-authentication)
    - [A Project for Everything](#a-project-for-everything)
    - [Web Console](#web-console)
  - [Your First Application](#your-first-application)
    - ["Resources"](#resources)
    - [Applying Quota to Projects](#applying-quota-to-projects)
    - [Login](#login)
    - [Grab the Training Repo Again](#grab-the-training-repo-again)
    - [The Hello World Definition JSON](#the-hello-world-definition-json)
    - [Run the Pod](#run-the-pod)
    - [Looking at the Pod in the Web Console](#looking-at-the-pod-in-the-web-console)
    - [Quota Usage](#quota-usage)
    - [Extra Credit](#extra-credit)
    - [Delete the Pod](#delete-the-pod)
    - [Quota Enforcement](#quota-enforcement)
  - [Adding Nodes](#adding-nodes)
    - [Modifying the Ansible Configuration](#modifying-the-ansible-configuration)
  - [Regions and Zones](#regions-and-zones)
    - [Scheduler and Defaults](#scheduler-and-defaults)
    - [The NodeSelector](#the-nodeselector)
    - [Customizing the Scheduler Configuration](#customizing-the-scheduler-configuration)
    - [Restart the Master](#restart-the-master)
    - [Label Your Nodes](#label-your-nodes)
  - [Services](#services)
  - [Routing](#routing)
    - [Creating the Router](#creating-the-router)
    - [Router Placement By Region](#router-placement-by-region)
  - [The Complete Pod-Service-Route](#the-complete-pod-service-route)
    - [Creating the Definition](#creating-the-definition)
    - [Project Status](#project-status)
    - [Verifying the Service](#verifying-the-service)
    - [Verifying the Routing](#verifying-the-routing)
    - [The Web Console](#the-web-console)
  - [Project Administration](#project-administration)
    - [Deleting a Project](#deleting-a-project)
  - [Preparing for STI: the Registry](#preparing-for-sti-the-registry)
    - [Registry Placement By Region (optional)](#registry-placement-by-region-optional)
  - [STI - What Is It?](#sti---what-is-it)
    - [Create a New Project](#create-a-new-project)
    - [Switch Projects](#switch-projects)
    - [A Simple Code Example](#a-simple-code-example)
    - [CLI versus Console](#cli-versus-console)
    - [Adding the Builder ImageStreams](#adding-the-builder-imagestreams)
    - [Wait, What's an ImageStream?](#wait-whats-an-imagestream)
    - [Adding Code Via the Web Console](#adding-code-via-the-web-console)
    - [The Web Console Revisited](#the-web-console-revisited)
    - [Examining the Build](#examining-the-build)
    - [Testing the Application](#testing-the-application)
    - [Adding a Route to Our Application](#adding-a-route-to-our-application)
    - [Implications of Quota Enforcement on Scaling](#implications-of-quota-enforcement-on-scaling)
  - [Templates, Instant Apps, and "Quickstarts"](#templates-instant-apps-and-quickstarts)
    - [A Project for the Quickstart](#a-project-for-the-quickstart)
    - [A Quick Aside on Templates](#a-quick-aside-on-templates)
    - [Adding the Template](#adding-the-template)
    - [Create an Instance of the Template](#create-an-instance-of-the-template)
    - [Using Your App](#using-your-app)
  - [Creating and Wiring Disparate Components](#creating-and-wiring-disparate-components)
    - [Create a New Project](#create-a-new-project-1)
    - [Stand Up the Frontend](#stand-up-the-frontend)
    - [Visit Your Application](#visit-your-application)
    - [Create the Database Config](#create-the-database-config)
    - [Visit Your Application Again](#visit-your-application-again)
    - [Replication Controllers](#replication-controllers)
    - [Revisit the Webpage](#revisit-the-webpage)
  - [Rollback/Activate and Code Lifecycle](#rollbackactivate-and-code-lifecycle)
    - [Fork the Repository](#fork-the-repository)
    - [Update the BuildConfig](#update-the-buildconfig)
    - [Change the Code](#change-the-code)
- [ Welcome to an OpenShift v3 Demo App! ](#welcome-to-an-openshift-v3-demo-app)
- [ This is my crustom demo! ](#this-is-my-crustom-demo)
    - [Start a Build with a Webhook](#start-a-build-with-a-webhook)
    - [Rollback](#rollback)
    - [Activate](#activate)
  - [Customized Build and Run Processes](#customized-build-and-run-processes)
    - [Add a Script](#add-a-script)
    - [Kick Off a Build](#kick-off-a-build)
    - [Watch the Build Logs](#watch-the-build-logs)
  - [Lifecycle Pre and Post Deployment Hooks](#lifecycle-pre-and-post-deployment-hooks)
    - [Examining the Deployment Configuration](#examining-the-deployment-configuration)
    - [Modifying the Hooks](#modifying-the-hooks)
    - [Quickly Clean Up](#quickly-clean-up)
    - [Build Again](#build-again)
    - [Verify the Migration](#verify-the-migration)
  - [Arbitrary Docker Image (Builder)](#arbitrary-docker-image-builder)
    - [Create a Project](#create-a-project)
    - [Build Wordpress](#build-wordpress)
    - [Test Your Application](#test-your-application)
    - [Application Resource Labels](#application-resource-labels)
  - [EAP Example](#eap-example)
    - [Create a Project](#create-a-project-1)
    - [Instantiate the Template](#instantiate-the-template)
    - [Update the BuildConfig](#update-the-buildconfig-1)
    - [Run the EAP Build](#run-the-eap-build)
    - [Visit Your Application](#visit-your-application-1)
  - [Conclusion](#conclusion)
- [APPENDIX - DNSMasq setup](#appendix---dnsmasq-setup)
    - [Verifying DNSMasq](#verifying-dnsmasq)
- [APPENDIX - LDAP Authentication](#appendix---ldap-authentication)
    - [Prerequirements:](#prerequirements)
    - [Setting up an example LDAP server:](#setting-up-an-example-ldap-server)
    - [Creating the Basic Auth service](#creating-the-basic-auth-service)
    - [Using an LDAP server external to OpenShift](#using-an-ldap-server-external-to-openshift)
    - [Upcoming changes](#upcoming-changes)
- [APPENDIX - Import/Export of Docker Images (Disconnected Use)](#appendix---importexport-of-docker-images-disconnected-use)
- [APPENDIX - Cleaning Up](#appendix---cleaning-up)
- [APPENDIX - Pretty Output](#appendix---pretty-output)
- [APPENDIX - Troubleshooting](#appendix---troubleshooting)
- [APPENDIX - Infrastructure Log Aggregation](#appendix---infrastructure-log-aggregation)
  - [Enable Remote Logging on Master](#enable-remote-logging-on-master)
  - [Enable logging to /var/log/openshift](#enable-logging-to-varlogopenshift)
  - [Configure nodes to send openshift logs to your master](#configure-nodes-to-send-openshift-logs-to-your-master)
  - [Optionally Log Each Node to a unique directory](#optionally-log-each-node-to-a-unique-directory)
- [APPENDIX - JBoss Tools for Eclipse](#appendix---jboss-tools-for-eclipse)
  - [Installation](#installation)
  - [Connecting to the Server](#connecting-to-the-server)
- [APPENDIX - Working with HTTP Proxies](#appendix---working-with-http-proxies)
  - [Importing ImageStreams](#importing-imagestreams)
  - [STI Builds](#sti-builds)
  - [Setting Environment Variables in Pods](#setting-environment-variables-in-pods)
  - [Git Repository Access](#git-repository-access)
  - [Proxying Docker Pull](#proxying-docker-pull)
  - [Future Considerations](#future-considerations)
- [APPENDIX - Installing in IaaS Clouds](#appendix---installing-in-iaas-clouds)
  - [Generic Cloud Install](#generic-cloud-install)
  - [Automated AWS Install With Ansible](#automated-aws-install-with-ansible)
- [APPENDIX - Linux, Mac, and Windows clients](#appendix---linux-mac-and-windows-clients)
  - [Downloading The Clients](#downloading-the-clients)
  - [Log In To Your OpenShift Environment](#log-in-to-your-openshift-environment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# OpenShift Beta 3
## Architecture and Requirements
### Architecture
The documented architecture for the beta testing is pretty simple. There are
three systems:

* Master + Node
* Node
* Node

The master is the scheduler/orchestrator and the API endpoint for all commands.
This is similar to V2's "broker". We are also running the node software on the
master.

The "node" is just like in OpenShift 2 -- it hosts user applications. The main
difference is that "gears" have been replaced with Docker container instances.
You will learn much more about the inner workings of OpenShift throughout the
rest of the document.
### Requirements
Each of the virtual machines should have 4+ GB of memory, 20+ GB of disk space,
and the following configuration:

* RHEL 7.1 (Note: 7.1 kernel is required for openvswitch)
* "Minimal" installation option
* NetworkManager **disabled**
The majority of storage requirements are related to Docker and etcd (the data
store). Both of their contents live in /var, so it is recommended that the
majority of the storage be allocated to /var.

As part of signing up for the beta program, you should have received an
evaluation subscription. This subscription gave you access to the beta software.
You will need to use subscription manager to both register your VMs, and attach
them to the *OpenShift Enterprise High Touch Beta* subscription.

All of your VMs should be on the same logical network and be able to access one
another.

Forward DNS resolution of hostnames is an **absolute requirement**. This
training document assumes the following configuration:

* ose3-master.example.com (master+node)
* ose3-node1.example.com
* ose3-node2.example.com

If you cannot create real forward resolving DNS entries in your DNS system, you
will need to set up your own DNS server in the beta testing environment.
Documentation is provided on DNSMasq in an appendix, [APPENDIX - DNSMasq
setup](#appendix---dnsmasq-setup)

## Setting Up the Environment
### Use a Terminal Window Manager
address of the OpenShift router. For this training, we will ensure that the
router will end up on the OpenShift server that is running the master. Go
### Assumptions
In most cases you will see references to "example.com" and other FQDNs related
to it. If you choose not to use "example.com" in your configuration, that is
fine, but remember that you will have to adjust files and actions accordingly.

Once your VMs are built and you have verified DNS and network connectivity you
can:
* Configure yum / subscription manager as follows:

    **Note:** You will have had to register/attach your system first.

Onn **each** VM:
        yum -y install wget vim-enhanced net-tools bind-utils tmux git
Make sure that you are running at least `docker-1.6.0-6.el7.x86_64`.

    docker pull registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-deployer:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-sti-builder:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-builder:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-pod:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-registry:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/sti-basicauthurl:latest
    docker pull registry.access.redhat.com/openshift3_beta/ruby-20-rhel7
    docker pull registry.access.redhat.com/openshift3_beta/mysql-55-rhel7
    docker pull openshift/hello-openshift:v0.4.3

**Note:** If you built your VM for a previous beta version and at some point
used an older version of Docker, you need to *reinstall* or *remove+install*
Docker after removing `/etc/sysconfig/docker`. The options in the config file
changed and RPM will not overwrite your existing file if you just do a "yum
update".

    yum -y remove docker
    rm /etc/sysconfig/docker
    yum -y install docker
**REMINDER**
There's currently a bug in the latest Ansible version, so we need to use a
slightly older one. Install the packages for Ansible:
    yum -y --enablerepo=epel install ansible
    git clone https://github.com/detiber/openshift-ansible.git -b v3-beta3
Copy the staged Ansible configuration files to `/etc/ansible`:
    /bin/cp -r ~/training/beta3/ansible/* /etc/ansible/
    ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml

If you looked at the Ansible hosts file, note that our master
(ose3-master.example.com) was present in both the `master` and the `node`
section.

Effectively, Ansible is going to install and configure both the master and node
software on `ose3-master.example.com`. Later, we will modify the Ansible
configuration to add the extra nodes.
their own machines (`osc` and the web console). For the Beta training, we
*alice*, on the master. This is done for convenience and because we'll be using
`htpasswd` for authentication.
## Useful OpenShift Logs
**Note:** You will want to do this on the other nodes as they are added, but you
again.

**Note:** There is an appendix on configuring [Log
Aggregation](#appendix---infrastructure-log-aggregation)
The OpenShift configuration is kept in a YAML file which currently lives at
`/etc/openshift/master.yaml`. We need to edit the `oauthConfig`'s
`identityProviders` stanza so that it looks like the following:

    identityProviders:
    - challenge: true
      login: true
      name: apache_auth
      provider:
        apiVersion: v1
        file: /etc/openshift-passwd
        kind: HTPasswdPasswordIdentityProvider

More information on these configuration settings can be found here:

    http://docs.openshift.org/latest/admin_guide/configuring_authentication.html#HTPasswdPasswordIdentityProvider

If you're feeling lazy, use your friend `sed`:

    sed -i -e 's/name: anypassword/name: apache_auth/' \
    -e 's/kind: AllowAllPasswordIdentityProvider/kind: HTPasswdPasswordIdentityProvider/' \
    -e '/kind: HTPasswdPasswordIdentityProvider/i \      file: \/etc\/openshift-passwd' \
    /etc/openshift/master.yaml
V3 has a concept of "projects" to contain a number of different resources:
services and their pods, builds and so on. They are somewhat similar to
"namespaces" in OpenShift v2. We'll explore what this means in more details
throughout the rest of the labs. Let's create a project for our first
application.
user, which is allowed to create projects. We can use the "admin"
    osadm new-project demo --display-name="OpenShift 3 Demo" \
    --admin=joe
* with a description
    https://fqdn.of.master:8443

project.
Also, don't forget, the materials for these labs are in your `~/training/beta3`
      "apiVersion": "v1beta3",
      "metadata": {
        "name": "test-quota"
      },
          "memory": "512Mi",
          "cpu": "200m",
          "replicationcontrollers": "3",
          "resourcequotas": "1"
The above quota (simply called *test-quota*) defines limits for several
resources. In other words, within a project, users cannot "do stuff" that will
cause these resource limits to be exceeded. Since quota is enforced at the
project level, it is up to the users to allocate resources (more specifically,
memory and CPU) to their pods/containers. OpenShift will soon provide sensible
defaults.

* Memory

    The memory figure is in bytes, but various other suffixes are supported (eg:
    Mi (mebibytes), Gi (gibibytes), etc.

* CPU

    CPU is a little tricky to understand. The unit of measure is actually a
    "Kubernetes Compute Unit" (KCU, or "kookoo"). The KCU is a "normalized" unit
    that should be roughly equivalent to a single hyperthreaded CPU core.
    Fractional assignment is allowed. For fractional assignment, the
    **m**illicore may be used (eg: 200m = 0.2 KCU)

More details on CPU will come in later betas and documentation.

We will get into a description of what pods, services and replication
controllers are over the next few labs. Lastly, we can ignore "resourcequotas",
as it is a bit of a trick so that Kubernetes doesn't accidentally try to apply
two quotas to the same namespace.
to it. Still in a `root` terminal in the `training/beta3` folder:
    osc create -f quota.json --namespace=demo
    test-quota
    osc describe quota test-quota -n demo
    Name:                   test-quota
    cpu                     0m      200m
    memory                  0       512Mi
    replicationcontrollers  0       3
**Note:** Once creating the quota, it can take a few moments for it to be fully
processed. If you get blank output from the `get` or `describe` commands, wait a
few moments and try again.

him, we can log into a terminal as *joe* and then set up the command line
tooling.
Then, execute:
    osc login -u joe \
    --certificate-authority=/var/lib/openshift/openshift.local.certificates/ca/cert.crt \
    --server=https://ose3-master.example.com:8443
OpenShift, by default, is using a self-signed SSL certificate, so we must point
our tool at the CA file.
The `login` process created a file called `.config` in the `~/.config/openshift`
folder. Take a look at it, and you'll see something like the following:
        certificate-authority: /var/lib/openshift/openshift.local.certificates/ca/cert.crt
      name: ose3-master-example-com-8443
        cluster: ose3-master-example-com-8443
      name: demo
    current-context: demo
        token: ZmQwMjBiZjUtYWE3OC00OWE1LWJmZTYtM2M2OTY2OWM0ZGIw
our server lives, our project, etc.
**Note:** See the [troubleshooting guide](#appendix---troubleshooting) for
details on how to fetch a new token once this one expires.  The installer sets
the default token lifetime to 4 hours.
    cd ~/training/beta3
In the beta3 training folder, you can see the contents of our pod definition by using cat`:
    cat hello-pod.json
            "image": "openshift/hello-openshift:v0.4.3",
      }
    pods/hello-openshift
Issue a `get pods` to see the details of how it was defined:
    POD               IP         CONTAINER(S)      IMAGE(S)                           HOST                                    LABELS                 STATUS    CREATED
    hello-openshift   10.1.0.6   hello-openshift   openshift/hello-openshift:v0.4.3   ose3-master.example.com/192.168.133.2   name=hello-openshift   Running   10 seconds
    CONTAINER ID        IMAGE                              COMMAND              CREATED             STATUS              PORTS                    NAMES
    ded86f750698        openshift/hello-openshift:v0.4.3   "/hello-openshift"   7 minutes ago       Up 7 minutes                                 k8s_hello-openshift.9ac8152d_hello-openshift_demo_18d03b48-0089-11e5-98b9-525400616fe9_c43c7d54   
    405d63115a60        openshift3_beta/ose-pod:v0.4.3.2   "/pod"               7 minutes ago       Up 7 minutes        0.0.0.0:6061->8080/tcp   k8s_POD.a01602bc_hello-openshift_demo_18d03b48-0089-11e5-98b9-525400616fe9_dffebcf1     


### Extra Credit
If you try to curl the pod IP and port, you get "connection refused". See if you
can figure out why.

Go ahead and delete this pod so that you don't get confused in later examples. Don't forget to
do this as the ```joe``` user:
### Quota Enforcement
Since we know we can run a pod directly, we'll go through a simple quota
enforcement exercise. The `hello-quota` JSON will attempt to create four
instances of the "hello-openshift" pod. It will fail when it tries to create the
fourth, because the quota on this project limits us to three total pods.

Go ahead and use `osc create` and you will see the following:

    osc create -f hello-quota.json
    pods/1-hello-openshift
    pods/2-hello-openshift
    pods/3-hello-openshift
    Error: pods "4-hello-openshift" is forbidden: Limited to 3 pods

Let's delete these pods quickly. As `joe` again:

    osc delete pod --all

**Note:** You can delete most resources using "--all" but there is *no sanity
check*. Be careful.

We are getting ready to build out our complete environment and add more
infrastructure. We will begin by adding our other two nodes.

to a `root` terminal on your master.
    ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml

Once the installer is finished, you can check the status of your environment
(nodes) with `osc get nodes`. You'll see something like:
    NAME                      LABELS        STATUS
    ose3-master.example.com   Schedulable   <none>    Ready
    ose3-node1.example.com    Schedulable   <none>    Ready
    ose3-node2.example.com    Schedulable   <none>    Ready

## Regions and Zones
application and deployment paradigms. If you think you're about to learn how to
configure regions and zones in OpenShift 3, you're only partially correct.

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
complex topologies you could implement.

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

These default options are documented in the link below, but the quick overview
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
The first step is to edit the OpenShift master's configuration to tell it to
look for a specific scheduler config file. As `root` edit
`/etc/openshift/master.yaml` and find the line with `schedulerConfigFile`.
Change it to:

    schedulerConfigFile: "/etc/openshift/scheduler.json"

Then, create `/etc/openshift/scheduler.json` from the training materials:

    /bin/cp -r ~/training/beta3/scheduler.json /etc/openshift/

It will have the following content:

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

* Node 1 -- "region":"primary"
* Node 2 -- "region":"primary"
* Node 3 -- "region":"infra"

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

### Restart the Master
Go ahead and restart the master. This will make the new scheduler take effect.
As `root` on your master:

    systemctl restart openshift-master

### Label Your Nodes
Just before configuring the scheduler, we added more nodes. If you perform the
following as the `root` user:

    osc get node -o json | sed -e '/"resourceVersion"/d' > ~/nodes.json

You will have the JSON output of the definition of all of your nodes. Go ahead and
edit this file. Add the following to the beginning of the `"metadata": {}`
block for your "master" node inside the files `"items"` list:

    "labels" : {
      "region" : "infra",
      "zone" : "NA"
    },

So the end result should look like (note, indentation is not significant in JSON):

    {
        "kind": "List",
        "apiVersion": "v1beta3",
        "items": [
            {
                "kind": "Node",
                "apiVersion": "v1beta3",
                "metadata": {
                    "labels" : {
                      "region" : "infra",
                      "zone" : "NA"
                    },
                    "name": "ose3-master.example.com",
                    [...]


For your node1, add the following:

    "labels" : {
      "region" : "primary",
      "zone" : "east"
    },

For your node2, add the following:

    "labels" : {
      "region" : "primary",
      "zone" : "west"
    },

Then, as `root` update your nodes using the following:

    osc update node -f ~/nodes.json

Note: At release the user should not need to edit JSON like this; the
installer should be able to configure nodes initially with desired labels,
and there should be better tools for changing them afterward.

Note: If you end up getting an error while attempting to update the nodes, review your json. Ensure that there are commas in the previous element to your added label sections.

Check the results to ensure the labels were applied:

    osc get nodes

    NAME                       LABELS                     STATUS
    ose3-master.example.com    region=infra,zone=NA       Ready
    ose3-node1.example.com     region=primary,zone=east   Ready
    ose3-node2.example.com     region=primary,zone=west   Ready

Now there is one final step that is necessary due to a [caching
bug](https://github.com/openshift/origin/issues/1727#issuecomment-94518311)
which is not fixed for beta3. Each node needs to be restarted with:

    systemctl restart openshift-node
      "id": "hello-openshift-service",
`name:hello-openshift`. If you looked at the output of `osc get pods` on your
master, you saw that the `hello-openshift` pod has a label:
and that is where the routing tier comes in.
The OpenShift routing tier is how FQDN-destined traffic enters the OpenShift
environment so that it can ultimately reach pods. In a simplification of the
process, the `openshift3_beta/ose-haproxy-router` container we will create below
is a pre-configured instance of HAProxy as well as some of the OpenShift
framework. The OpenShift instance running in this container watches for route
resources on the OpenShift master.
Here is an example route resource JSON definition:
*resource* is created inside OpenShift's data store. This route resource is
affiliated with a service.

The HAProxy/Router is watching for changes in route resources. When a new route
is detected, an HAProxy pool is created. When a change in a route is detected,
the pool is updated.

This HAProxy pool ultimately contains all pods that are in a service. Which
service? The service that corresponds to the `serviceName` directive that you
see above.

### Creating the Router
The router is the ingress point for all traffic destined for OpenShift
v3 services. It currently supports only HTTP(S) traffic (and "any"
TLS-enabled traffic via SNI). While it is called a "router", it is essentially a
proxy.

The `openshift3_beta/ose-haproxy-router` container listens on the host network
interface unlike most containers that listen only on private IPs. The router
proxies external requests for route names to the IPs of actual pods identified
by the service associated with the route.

OpenShift's admin command set enables you to deploy router pods automatically.
As the `root` user, try running it with no options and you should see the note
that a router is needed:

    osadm router
    F0529 11:50:57.985423    2610 router.go:143] Router "router" does not exist
    (no service). Pass --create to install.

So, go ahead and do what it says:

    osadm router --create
    F0529 11:51:19.350154    2617 router.go:148] You must specify a .kubeconfig
    file path containing credentials for connecting the router to the master
    with --credentials

Just about every form of communication with OpenShift components is secured by
SSL and uses various certificates and authentication methods. Even though we set
up our `.kubeconfig` for the root user, `osadm router` is asking us what
credentials the *router* should use to communicate. We also need to specify the
router image, since the tooling defaults to upstream/origin:
    osadm router --create \
    --credentials=/var/lib/openshift/openshift.local.certificates/openshift-router/.kubeconfig \
    --images='registry.access.redhat.com/openshift3_beta/ose-${component}:${version}'

If this works, you'll see some output:

    services/router
    deploymentConfigs/router

Let's check the pods with the following:

    osc get pods | awk '{print $1"\t"$3"\t"$5"\t"$7"\n"}' | column -t

In the output, you should see the router pod status change to "running" after a
few moments (it may take up to a few minutes):

    POD                   CONTAINER(S)  HOST                                   STATUS
    deploy-router-1f99mb  deployment    ose3-master.example.com/192.168.133.2  Succeeded
    router-1-ats7z        router        ose3-node2.example.com/192.168.133.4   Running

Note: You may or may not see the deploy pod, depending on when you run this
command. Also the router may not end up on the master.
### Router Placement By Region
In the very beginning of the documentation, we indicated that a wildcard DNS
entry is required and should point at the master. When the router receives a
request for an FQDN that it knows about, it will proxy the request to a pod for
a service. But, for that FQDN request to actually reach the router, the FQDN has
to resolve to whatever the host is where the router is running. Remember, the
router is bound to ports 80 and 443 on the *host* interface. Since our wildcard
DNS entry points to the public IP address of the master, we need to ensure that
the router runs *on* the master.

Remember how we set up regions and zones earlier? In our setup we labeled the
master with the "infra" region. Without specifying a region or a zone in our
environment, the router pod had an equal chance of ending up on any node, but we
can ensure that it always and only lands in the "infra" region (thus, on the
master) using a NodeSelector.

To do this, we will modify the `deploymentConfig` for the router. If you recall,
when we created the router we saw both a `deploymentConfig` and `service`
resource.

We have not discussed DeploymentConfigs (or even Deployments) yet. The brief
summary is that a DeploymentConfig defines not only the pods (and containers)
but also how many pods should be created and also transitioning from one pod
definition to another.  We'll learn a little bit more about deployment
configurations later.  For now, as `root`, we will use `osc edit` to manipulate
the router DeploymentConfig and modify the router's pod definition to add a
NodeSelector, so that router pods will be placed where we want them.  Whew!

    osc edit deploymentConfigs/router

`osc edit` will bring up the default system editor (vi) with a YAML
representation of the resource, in this case the router's `deploymentConfig`.
You could also edit it as JSON or use a different editor; see `osc edit --help`.

Note: In future releases, you will be able to supply NodeSelector and other
labels at creation time rather than editing the object after the fact.

We will specify our NodeSelector within the `podTemplate:` block that
defines the pods to create. It is easiest to just place it right after
that line, like this: (indentation *is* significant in YAML)

    [...]
    template:
      controllerTemplate:
        podTemplate:
          nodeSelector:
            region: infra
          desiredState:
            manifest:
    [...]

Once you save this file and exit the editor, the DeploymentConfig will be
updated in OpenShift's data store and a new router deployment will be created
based on the new definition.  It will take at least a few seconds for this to
happen (possibly longer if the router image has not been pulled to the master
yet).  Watch `osc get pods` until the router pod has been recreated and assigned
to the master host.
For a true HA implementation, one would want multiple "infra" nodes and
multiple, clustered router instances. Look for this to be described in beta4.
With a router now available, let's take a look at an entire
Pod-Service-Route definition template and put all the pieces together.

Don't forget -- the materials are in `~/training/beta3`.

and a corresponding route. It also includes a deployment configuration.
        "name":"hello-service-pod-meta"
          "id": "hello-openshift-service",
          "containerPort": 8080,
            "name": "hello-openshift"
            "name": "hello-openshift-route"
        },
        {
          "apiVersion": "v1beta1",
          "kind": "ImageStream",
          "metadata": {
            "name": "hello-openshift"
          }
        },
        {
            "kind": "DeploymentConfig",
            "apiVersion": "v1beta1",
            "metadata": {
                "name": "hello-openshift"
            },
            "triggers": [
                {
                  "imageChangeParams": {
                    "automatic": true,
                    "containerNames": [
                      "hello-openshift"
                    ],
                    "from": {
                      "name": "hello-openshift"
                    },
                    "tag": "latest"
                  },
                  "type": "ImageChange"
                },
                {
                  "type": "ConfigChange"
                }
            ],
            "template": {
                "strategy": {
                    "type": "Recreate"
                },
                "controllerTemplate": {
                    "replicas": 1,
                    "replicaSelector": {
                        "name": "hello-openshift"
                    },
                    "podTemplate": {
                        "desiredState": {
                            "manifest": {
                                "version": "v1beta2",
                                "id": "",
                                "volumes": null,
                                "containers": [
                                    {
                                        "name": "hello-openshift",
                                        "image": "openshift/hello-openshift:v0.4.3",
                                        "ports": [
                                            {
                                                "containerPort": 8080,
                                                "protocol": "TCP"
                                            }
                                        ],
                                        "resources": {},
                                        "livenessProbe": {
                                            "tcpSocket": {
                                                "port": 8080
                                            },
                                            "timeoutSeconds": 1,
                                            "initialDelaySeconds": 10
                                        },
                                        "terminationMessagePath": "/dev/termination-log",
                                        "imagePullPolicy": "PullIfNotPresent",
                                        "capabilities": {}
                                    }
                                ],
                                "restartPolicy": {
                                    "always": {}
                                },
                                "dnsPolicy": "ClusterFirst"
                            }
                        },
                        "nodeSelector": {
                          "region": "primary"
                        },
                        "labels": {
                            "name": "hello-openshift"
                        }
                    }
                }
            },
            "latestVersion": 1
* There is a pod that has the label `name=hello-openshift` and the nodeSelector `region=primary`
  * with the selector `name=hello-openshift`
    `name=hello-openshift`
    `name=hello-openshift`
**Logged in as `joe`,** edit `test-complete.json` and change the `host` stanza for
environment. Once this is done, go ahead and use `osc` to apply it:
    osc create -f test-complete.json

 You should see something like the following:

    services/hello-openshift-service
    routes/hello-openshift-route
    imageStreams/openshift/hello-openshift
    deploymentConfigs/hello-openshift

### Project Status
OpenShift provides a handy tool, `osc status`, to give you a summary of
common resources existing in the current project:

    osc status
    In project OpenShift 3 Demo (demo)

    service hello-openshift-service (172.30.17.237:27017 -> 8080)
      hello-openshift deploys hello-openshift:latest
        #1 deployed about a minute ago

    To see more information about a service or deployment config, use 'osc describe service <name>' or 'osc describe dc <name>'.
    You can use 'osc get pods,svc,dc,bc,builds' to see lists of each of the types described above.

`osc status` does not yet show bare pods or routes. The output will be
more interesting when we get to builds and deployments.
    NAME                      LABELS    SELECTOR                     IP              PORT(S)
    hello-openshift-service   <none>    name=hello-openshift-label   172.30.17.229   27017/TCP
    curl `osc get services | grep hello-openshift | awk '{print $4":"$5}' | sed -e 's/\/.*//'`
specified that the router should land in the "infra" region, we know that its
Docker container is on the master.
"inside" it. On the master system, as the `root` user, issue the following to
get the PID of the router:
        "Name": "demo/hello-openshift-service",
        "EndpointTable": {
          "10.1.2.2:8080": {
            "ID": "10.1.2.2:8080",
            "IP": "10.1.2.2",
            "Port": "8080"
          }
        },
        "ServiceAliasConfigs": {
          "hello-openshift.cloudapps.example.com-": {
            "Host": "hello-openshift.cloudapps.example.com",
            "Path": "",
            "TLSTermination": "",
            "Certificates": null
          }
If your machine is capable of resolving the wildcard DNS, you should also be
able to view this in your web browser:

    http://hello-openshift.cloudapps.example.com

## Project Administration
When we created the `demo` project, `joe` was made a project administrator. As
an example of an administrative function, if `joe` now wants to let `alice` look
at his project, with his project administrator rights he can add her using the
`osadm policy` command:
    [joe]$ osadm policy add-role-to-user view alice
**Note:** `osadm` will act, by default, on whatever project the user has
selected. If you recall earlier, when we logged in as `joe` we ended up in the
`demo` project. We'll see how to switch projects later.
Open a new terminal window as the `alice` user and the login to OpenShift:
    osc login -u alice \
    --certificate-authority=/var/lib/openshift/openshift.local.certificates/ca/cert.crt \
    --server=https://ose3-master.example.com:8443
    Authentication required for https://ose3-master.example.com:8443 (openshift)
    Password:  <redhat>
    Login successful.
    Using project "demo"
`alice` has no projects of her own yet (she is not an administrator on
anything), so she is automatically configured to look at the `demo` project
since she has access to it. She has "view" access, so `osc status` and `osc get
pods` and so forth should show her the same thing as `joe`. However, she cannot
make changes:
    [alice]$ osc get pods
    POD                       IP         CONTAINER(S)      IMAGE(S)
    hello-openshift-1-zdgmt   10.1.2.4   hello-openshift   openshift/hello-openshift
    [alice]$ osc delete pod hello-openshift-1-zdgmt
    Error from server: "/api/v1beta1/pods/hello-openshift-1-zdgmt?namespace=demo" is forbidden because alice cannot delete on pods with name "hello-openshift-1-zdgmt" in demo
Also login as `alice` in the web console and confirm that she can view
the `demo` project.
`joe` could also give `alice` the role of `edit`, which gives her access to all
activities except for project administration.
    [joe]$ osadm policy add-role-to-user edit alice

Now she can delete that pod if she wants, but she can not add access for
another user or upgrade her own access. To allow that, `joe` could give
`alice` the role of `admin`, which gives her the same access as himself.

    [joe]$ osadm policy add-role-to-user admin alice

There is no "owner" of a project, and projects can be created without any
administrator. `alice` or `joe` can remove the `admin` role (or all roles) from
each other, or themselves, at any time without affecting the existing project.

    [joe]$ osadm policy remove-user joe

Check `osadm policy help` for a list of available commands to modify
project permissions. OpenShift RBAC is extremely flexible. The roles
mentioned here are simply defaults - they can be adjusted (per-project
and per-resource if needed), more can be added, groups can be given
access, etc. Check the documentation for more details:

* http://docs.openshift.org/latest/dev_guide/authorization.html
* https://github.com/openshift/origin/blob/master/docs/proposals/policy.md

Of course, there be dragons. The basic roles should suffice for most uses.

### Deleting a Project
Since we are done with this "demo" project, and since the `alice` user is a
project administrator, let's go ahead and delete the project. This should also
end up deleting all the pods, and other resources, too.

As the `alice` user:

    osc delete project demo

If you quickly go to the web console and return to the top page, you'll see a
warning icon that will pop-up a hover tip saying the project is marked for
deletion.
If you switch to the `root` user and issue `osc get project` you will see that
the demo project's status is "Terminating". If you do an `osc get pod -n demo`
you may see the pods, still. It takes about 60 seconds for the project deletion
cleanup routine to finish.

Once the project disappears from `osc get project`, doing `osc get pod -n demo`
should return no results.

Note: As of beta3, a user with the `edit` role can actually delete the project.
[This will be fixed](https://github.com/openshift/origin/issues/1885).

## Preparing for STI: the Registry
One of the really interesting things about OpenShift v3 is that it will build
Docker images from your source code, deploy them, and manage their lifecycle.
OpenShift 3 will provide a Docker registry that administrators may run inside
the OpenShift environment that will manage images "locally". Let's take a moment
to set that up.

`osadm` again comes to our rescue with a handy installer for the
registry. As the `root` user, run the following:

    osadm registry --create \
    --credentials=/var/lib/openshift/openshift.local.certificates/openshift-registry/.kubeconfig \
    --images='registry.access.redhat.com/openshift3_beta/ose-${component}:${version}'

You'll get output like:

    services/docker-registry
    deploymentConfigs/docker-registry

You can use `osc get pods`, `osc get services`, and `osc get deploymentconfig`
to see what happened. This would also be a good time to try out `osc status`
as root:

    osc status

    In project default

    service docker-registry (172.30.17.196:5000 -> 5000)
      docker-registry deploys registry.access.redhat.com/openshift3_beta/ose-docker-registry:v0.4.3.2
        #1 deployed about a minute ago

    service kubernetes (172.30.17.2:443 -> 443)

    service kubernetes-ro (172.30.17.1:80 -> 80)

    service router (172.30.17.129:80 -> 80)
      router deploys registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.4.3.2
        #2 deployed 8 minutes ago
        #1 deployed 7 minutes ago

The project we have been working in when using the `root` user is called
"default". This is a special project that always exists (you can delete it, but
OpenShift will re-create it) and that the administrative user uses by default.
One interesting feature of `osc status` is that it lists recent deployments.
When we created the router and adjusted it, that adjustment resulted in a second
deployment. We will talk more about deployments when we get into builds.

Anyway, ultimately you will have a Docker registry that is being hosted by OpenShift
and that is running on one of your nodes.

To quickly test your Docker registry, you can do the following:
    curl `osc get services | grep registry | awk '{print $4":"$5}' | sed -e 's/\/.*//'`
And you should see:

    "docker-registry server (dev) (v0.9.0)"

If you get "connection reset by peer" you may have to wait a few more moments
after the pod is running for the service proxy to update the endpoints necessary
to fulfill your request. You can check if your service has finished updating its
endpoints with:

    osc describe service docker-registry

And you will eventually see something like:

    Name:                   docker-registry
    Labels:                 docker-registry=default
    Selector:               docker-registry=default
    IP:                     172.30.17.64
    Port:                   <unnamed>       5000/TCP
    Endpoints:              10.1.0.5:5000
    Session Affinity:       None
    No events.

Once there is an endpoint listed, the curl should work.

### Registry Placement By Region (optional)
In the beta environment, as architected, there is no real need for the registry
to land on any particular node. However, for consistency, you might want to keep
OpenShift "infrastructure" components on the master's node. We can use our
previously-defined "infra" region for this purpose.

To do this, edit the created DeploymentConfig definition with `osc edit`:

    osc edit dc docker-registry

As before, specify your NodeSelector within the `podTemplate:` block that
defines the pods to create. It is easiest to just place it right after
that line, like this: (indentation *is* significant in YAML)

    [...]
    template:
      controllerTemplate:
        podTemplate:
          nodeSelector:
            region: infra
          desiredState:
            manifest:
    [...]


Once you save this file and exit, the DeploymentConfig will be updated and
a new registry deployment will soon be created with the new definition.

If you are going to move the registry, do it now or don't do it all. As
dedicated storage volumes did not make the beta3 drop, restarting the registry
pod will result in an empty registry -- all the images will be lost. This will
be a Very.Bad.Thing.

## STI - What Is It?
STI stands for *source-to-image* and is the process where OpenShift will take
your application source code and build a Docker image for it. In the real world,
you would need to have a code repository (where OpenShift can introspect an
appropriate Docker image to build and use to support the code) or a code
repository + a Dockerfile (so that OpenShift can pull or build the Docker image
for you).

### Create a New Project
As the `root` user, we will create a new project to put our first STI example
into. Grab the project definition and create it:

    osadm new-project sinatra --display-name="Sinatra Example" \
    --description="This is your first build on OpenShift 3" \
    --admin=joe

At this point, if you click the OpenShift image on the web console you should be
returned to the project overview page where you will see the new project show
up. Go ahead and click the *Sinatra* project - you'll see why soon.

### Switch Projects
As the `joe` user, let's switch to the `sinatra` project:

    osc project sinatra

You should see:

    Now using project "sinatra" on server "https://ose3-master.example.com:8443".

### A Simple Code Example
Let's see some JSON:
    osc new-app https://github.com/openshift/simple-openshift-sinatra-sti.git -o json
Take a look at the JSON that was generated. You will see some familiar items at
this point, and some new ones, like `BuildConfig`, `ImageStream` and others.
1. OpenShift will then deploy the built Docker image as a Pod with an associated
### CLI versus Console
Did you notice that the json returned from `new-app` defaulted to using a
CentOS builder image?  That is simply a temporary inconvenience until more
builder selection logic is baked in.  If we had wanted to use the RHEL image we
could have run:

    osc new-app openshift/ruby-20-rhel7~https://github.com/openshift/simple-openshift-sinatra-sti.git -o json

There are a few problems with this.  Namely:

* The `~` syntax is weird
* It won't even work until we've imported a `openshift/ruby-20-rhel7` `ImageStream`

Over time `new-app` will get smarter so we'll overlook this for now and simply
show how we can accomplish the same thing with the Console.  However, since the
Console doesn't have the logic for defaulting to CentOS we have to first tell
OpenShift about the `ImageStream`s we want to use.  From there we can show an
example of pointing to code via the web console.  Later examples will use the
CLI tools.

### Adding the Builder ImageStreams
While the `new-app` CLI tool has some built-in logic to help find a compatible
builder ImageStream, the web console currently does not have that capability.
The user will have to first target the code repository, and then select the
appropriate builder image.

Perform the following command as `root` in the `beta3` folder in order to add all
of the `ImageStream`s:

    osc create -f image-streams.json -n openshift

You will see the following:

    imageStreams/ruby-20-rhel7
    imageStreams/nodejs-010-rhel7
    imageStreams/perl-516-rhel7
    imageStreams/python-33-rhel7
    imageStreams/mysql-55-rhel7
    imageStreams/postgresql-92-rhel7
    imageStreams/mongodb-24-rhel7
    imageStreams/eap-openshift
    imageStreams/tomcat7-openshift
    imageStreams/tomcat8-openshift
    imageStreams/ruby-20-centos7
    imageStreams/nodejs-010-centos7
    imageStreams/perl-516-centos7
    imageStreams/python-33-centos7
    imageStreams/wildfly-8-centos

What is the `openshift` project where we added these builders? This is a
special project that can contain various elements that should be available to
all users of the OpenShift environment.

### Wait, What's an ImageStream?
If you think about one of the important things that OpenShift needs to do, it's
to be able to deploy newer versions of user applications into Docker containers
quickly. But an "application" is really two pieces -- the starting image (the
STI builder) and the application code. While it's "obvious" that we need to
update the deployed Docker containers when application code changes, it may not
have been so obvious that we also need to update the deployed container if the
**builder** image changes.

For example, what if a security vulnerability in the Ruby runtime is discovered?
It would be nice if we could automatically know this and take action. If you dig
around in the JSON output above from `new-app` you will see some reference to
"triggers". This is where `ImageStream`s come together.

The `ImageStream` resource is, somewhat unsurprisingly, a definition for a
stream of Docker images that might need to be paid attention to. By defining an
`ImageStream` on "ruby-20-rhel7", for example, and then building an application
against it, we have the ability with OpenShift to "know" when that `ImageStream`
changes and take action based on that change. In our example from the previous
paragraph, if the "ruby-20-rhel7" image changed in the Docker repository defined
by the `ImageStream`, we might automatically trigger a new build of our
application code.

You may notice that some of the streams above have `rhel` in the name and others
have `centos`. An organization will likely choose several supported builders and
databases from Red Hat, but may also create their own builders, DBs, and other
images. This system provides a great deal of flexibility.

Feel free to look around `image-streams.json` for more details.  As you can see,
we have provided definitions for EAP and Tomcat builders as well as other DBs
and etc. Please feel free to experiment with these - we will attempt to provide
sample apps as time progresses.

When finished, let's go move over to the web console to create our
"application".

### Adding Code Via the Web Console
If you go to the web console and then select the "Sinatra Example" project,
you'll see a "Create +" button in the upper right hand corner. Click that
button, and you will see two options. The second option is to create an
application from a template. We will explore that later.

The first option you see is a text area where you can type a URL for source
code. We are going to use the Git repository for the Sinatra application
referenced earlier. Enter this repo in the box:
    https://github.com/openshift/simple-openshift-sinatra-sti
When you hit "Next" you will then be asked which builder image you want to use.
This application uses the Ruby language, so make sure to click
`ruby-20-rhel7:latest`. You'll see a pop-up with some more details asking for
confirmation. Click "Select image..."

The next screen you see lets you begin to customize the information a little
bit. The only default setting we have to change is the name, because it is too
long. Enter something sensible like "*ruby-example*", then scroll to the bottom
and click "Create".

At this point, OpenShift has created several things for you. Use the "Browse"
tab to poke around and find them. You can also use `osc status` as the `joe`
user, too.
If you run (as `joe`):
webhooks, etc), we will have to trigger our build manually in this example.
Before starting our build, the default setup for apps created in this way is not
to have any nodeSelector. So, in order to deploy the built app into the
"primary" region we will need to edit the deploymentConfig. As `joe` on the
terminal:

    osc edit deploymentConfigs/ruby-example

Then, remember to add the nodeSelector for the "primary" region:

    [...]
    template:
      controllerTemplate:
        podTemplate:
          nodeSelector:
            region: primary
          desiredState:
            manifest:
    [...]
To start our build, as `joe`, execute the following:

    osc start-build ruby-example
    ruby-example-1
OpenShift v3 is in a bit of a transition period between authentication
paradigms. Suffice it to say that, for this beta drop, certain actions cannot be
performed by "normal" users, even if it makes sense that they should. Don't
worry, we'll get there. Feel free to try these things as a "normal" user - you
will get a "forbidden" error.
In order to watch the build logs, you actually need to be a cluster
administratior right now. So, as `root`, you can do the following things:

We can check on the status of a build (it will switch to "Running" in a few
moments):
    osc get builds -n sinatra
    NAME             TYPE      STATUS     POD
    ruby-example-1   STI       Running   ruby-example-1
The web console would've updated the *Overview* tab for the *Sinatra* project to
say:

    A build of ruby-example is pending. A new deployment will be
    created automatically once the build completes.
    osc build-logs ruby-example-1 -n sinatra
    simple-openshift-sinatra - routing TCP traffic on 172.30.17.20:8080 to port 8080
is working (as the `joe` user):
    curl `osc get service | grep example | awk '{print $4":"$5}' | sed -e 's/\/.*//'`
The last step will be to add a route to make it publicly accessible. You might
have noticed that adding the application code via the web console resulted in a
route being created. Currently that route doesn't have a corresponding DNS
entry, so it is unusable. The default domain is also not currently configurable,
so it's not very useful at the moment.
services from the service output you looked at above.

**Hint:** It is `ruby-example`.
**Hint:** Do this as `joe`.

**Note:** If you're not using the `example.com` domain, you'll have to edit this
route to match your domain.
    NAME                 HOST/PORT                                   PATH      SERVICE        LABELS
    ruby-example         ruby-example-sinatra.router.default.local             ruby-example   generatedby=OpenShiftWebConsole,name=ruby-example
    ruby-example-route   hello-sinatra.cloudapps.example.com                   ruby-example
You'll note above that there is a route involving "router.default.local". If you
remember, when creating the application from the web console, there was a
section for "route". In the future the router will provide more configuration
options for default domains and etc. Currently, the "default" domain for
applications is "router.default.local", which is most likely unusable in your
environment.

### Implications of Quota Enforcement on Scaling
Quotas have implications one may not immediately realize. As `root` assign a
quota to the `sinatra` project.

    osc create -f quota.json -n sinatra

As `joe` scale your application up to three replicas by setting your Replication
Controller's `replicas` value to 3.

    osc get rc
    CONTROLLER       CONTAINER(S)   IMAGE(S)                                                                                                SELECTOR                                                   REPLICAS
    ruby-example-1   ruby-example   172.30.17.88:5000/sinatra/ruby-example:65c87f9ceea1dbd36e813cec05674a6eeb82b98395a8d6aecc2fb2ec30479aa1 deployment=ruby-example-1,deploymentconfig=ruby-example         1

    osc edit rc ruby-example-1

Alter `replicas`

    spec:
      replicas: 3

Wait a few seconds and you should see your application scaled up to 3 pods.

    osc get pods
    POD                    IP          CONTAINER(S) ... STATUS  CREATED
    ruby-example-3-6n19x   10.1.0.27   ruby-example ... Running 2 minutes
    ruby-example-3-pfga3   10.1.0.26   ruby-example ... Running 18 minutes
    ruby-example-3-tzt0z   10.1.0.28   ruby-example ... Running About a minute

You will also notice that these pods were distributed across our two nodes
"east" and "west". Cool!

Now start another build, wait a moment or two for your build to start.

    osc start-build ruby-example

    osc get builds
    NAME             TYPE      STATUS     POD
    ruby-example-1   STI       Complete   ruby-example-1
    ruby-example-2   STI       New        ruby-example-2

The build never starts, what happened? The quota limits the number of pods in
this project to three and this includes ephemeral pods like STI builders.
Resize your application to just one replica and your new build will
automatically start after a minute or two.
**Note:** Once the build is complete a new replication controller is
created and the old one is no longer used.
## Templates, Instant Apps, and "Quickstarts"
of its JSON and embedded in the source code. Adding resources "after the fact"
will come in a later lab.

    osadm new-project quickstart --display-name="Quickstart" \
    --admin=joe
    osc project quickstart
documentation](http://docs.openshift.org/latest/dev_guide/templates.html):
### Adding the Template
Go ahead and do the following as `root` in the `~/training/beta3` folder:
    osc create -f integrated-template.json -n openshift
What did you just do? The `integrated-template.json` file defined a template. By
"creating" it, you have added it to the `openshift` project.
**Note:** If you're not using the `example.com` domain, you'll have to edit the
route in the template to match your domain. It is hard-coded at this time.
### Create an Instance of the Template
In the web console, logged in as `joe`, find the "Quickstart" project, and
then hit the "Create +" button. We've seen this page before, but now it contains
something new -- an "instant app(lication)". An instant app is a "special" kind
of template (really, it just has the "instant-app" tag). The idea behind an
"instant app" is that, when creating an instance of the template, you will have
a fully functional application. In this example, our "instant" app is just a
simple key-value storage and retrieval webpage.
Click "quickstart-keyvalue-application", and you'll see a modal pop-up that
provides more information about the template.
Click "Select template..."
The next page that you will see is the template "configuration" page. This is
where you can specify certain options for how the application components will be
insantiated.
* It will show you what Docker images are used
* It will let you add label:value pairs that can be used for other things
* It will let you set specific values for any parameters, if you so choose

Leave all of the defaults and simply click "Create".

Once you hit the "Create" button, the services and pods and
replicationcontrollers etc. will be instantiated
The cool thing about the template is that it has a built-in route. The not so
cool thing is that route is not configurable at the moment. But, it's there!
If you click "Browse" and then "Services" you will see that there is a route for
the *frontend* service (or whatever your domain is):

    `integrated.cloudapps.example.com`

The build was started for us immediately after creating an instance of the
template, so you can wait for it to finish. Feel free to check the build logs.

Once the build is complete, you can go on to the next step.
Once the app is built, you should be able to visit the routed URL and
### Placing Your App (Optional)
If you want this app to run in the "primary" region, you'll have to edit the
deployment configuration like you did previously. If you move your database
after you've added data to it, your data will be lost. Do you know why?

    osadm new-project wiring --display-name="Exploring Parameters" \
    --admin=alice
Open a terminal as `alice`:
Then:
    osc project wiring
Remember, your password was probably "redhat".
    cd ~/training/beta3
    osc create -f frontend-config.json
As soon as you create this, all of the resources will be created *and* a build
will be started for you. Let's go ahead and wait until this build completes
before continuing.

The same things hold true regarding nodeSelectors for this example as
in the previous examples -- you will have to modify the deployment configuration
if you want to restrict this app to run in the "primary" region.
Once the new build is finished and the frontend service's endpoint has been
updated, visit your application. The frontend configuration contained a route
for `wiring.cloudapps.example.com`. You should see a note that the database is
values and used them for both the frontend and the backend at the exact same
time. Since we are processing them separately now, some manual intervention is
required.

This template uses the OpenShift MySQL Docker container, which knows to take some
env-vars when it fires up (eg: the MySQL user / password). More information on
the specifics of this container can be found here:

    https://github.com/openshift/mysql

Take a look at the frontend configuration (`frontend-config.json`) and find the
value for `MYSQL_USER`. For example, `userMXG`. Then insert these values into
the template using the `process` command and create the result:

    grep -A 1 MYSQL_* frontend-config.json
                                                "name": "MYSQL_USER",
                                                "key": "MYSQL_USER",
                                                "value": "userMXG"
    --
                                                "name": "MYSQL_PASSWORD",
                                                "key": "MYSQL_PASSWORD",
                                                "value": "slDrggRv"
    --
                                                "name": "MYSQL_DATABASE",
                                                "key": "MYSQL_DATABASE",
                                                "value": "root"

    osc process -f db-template.json \
        -v MYSQL_USER=userMXG,MYSQL_PASSWORD=slDrggRv,MYSQL_DATABASE=root \
        | osc create -f -

`osc process` can be passed values for parameters, which will override
auto-generation.

It may take a little while for the MySQL container to download (if you didn't
pre-fetch it). It's a good idea to verify that the database is running before
continuing.  If you don't happen to have a MySQL client installed you can still
verify MySQL is running with curl:
MySQL doesn't speak HTTP so you will see garbled output like this (however,
you'll know your database is running!):
for it, but OpenShift could not "inject" those values into the frontend
container.
The replication controller is configured to ensure that we always have the
desired number of replicas (instances) running. We can look at how many that
should be:
longer see the database error!
As `alice`, go ahead and find your frontend pod, and then kill it:
    pods/deployment-frontend-1-hook-gbnys
    pods/deployment-frontend-1-hook-ot22m
    pods/frontend-1-b6bgy
up the first time. You also see some deployment hook pods. We will talk about
deployment hooks a bit later.

After a few moments, we can look at the list of pods again:
id as `root`:
The output will look something like:
          kind: ImageStream
          ref: beta3
          builderImage: openshift/ruby-20-rhel7
          image: openshift/ruby-20-rhel7
          name: ruby-20-rhel7
        image: openshift/ruby-20-rhel7
          name: ruby-20-rhel7
ahead and re-point our configuration. Our friend `osc edit` comes to the rescue
again:

    osc edit bc ruby-sample-build
Change the "uri" reference to match the name of your Github
repository. Assuming your github user is `alice`, you would point it
to `git://github.com/alice/ruby-hello-world.git`. Save and exit
the editor.
repository (eg: https://github.com/alice/ruby-hello-world), select the `beta3`
branch, and find the file `main.erb` in the `views` folder.
If you know how to use Git/Github, you can just do this "normally".

### Start a Build with a Webhook
Webhooks are a way to integrate external systems into your OpenShift
environment so that they can fire off OpenShift builds. Generally
speaking, one would make code changes, update the code repository, and
then some process would hit OpenShift's webhook URL in order to start
a build with the new code.

Your GitHub account has the capability to configure a webhook to request
whenever a commit is pushed to a specific branch; however, it would only
be able to make a request against your OpenShift master if that master
is exposed on the Internet, so you will probably need to simulate the
request manually for now.

To find the webhook URL, you can visit the web console, click into the
project, click on *Browse* and then on *Builds*. You'll see two webhook
URLs. Copy the *Generic* one. It should look like:

    https://ose3-master.example.com:8443/osapi/v1beta1/buildConfigHooks/ruby-sample-build/secret101/generic?namespace=wiring

If you look at the `frontend-config.json` file that you created earlier,
you'll notice the same "secret101" entries in triggers. These are
basically passwords so that just anyone on the web can't trigger the
build with knowledge of the name only. You could of course have adjusted
the passwords or had the template generate randomized ones.

This time, in order to run a build for the frontend, we'll use `curl` to hit our
webhook URL.

First, look at the list of builds:

    osc get build

You should see that the first build had completed. Then, `curl`:
And now `get build` again:

    osc get build
    NAME                  TYPE      STATUS     POD
    ruby-sample-build-1   STI       Complete   ruby-sample-build-1
    ruby-sample-build-2   STI       Pending    ruby-sample-build-2

You can see that this could have been part of some CI/CD workflow that
automatically called our webhook once the code was tested.

You can also check the web interface (logged in as `alice`) and see
that the build is running. Once it is complete, point your web browser
at the application:
from the `ImageStream`.
## Customized Build and Run Processes
OpenShift v3 supports customization of both the build and run processes.
Generally speaking, this involves modifying the various STI scripts from the
builder image. When OpenShift builds your code, it checks to see if any of the
scripts in the `.sti/bin` folder of your repository override/supercede the
builder image's scripts. If so, it will execute the repository script instead.

More information on the scripts, their execution during the process, and
customization can be found here:

    http://docs.openshift.org/latest/creating_images/sti.html#sti-scripts
You will find a script called `custom-assemble.sh` in the `beta3` folder. Go to
your Github repository for your application from the previous lab, find the
`beta3` branch, and find the `.sti/bin` folder.
* Paste the contents of `custom-assemble.sh` into the text area.
**Note:** If you know how to Git(hub), you can do this via your shell.

Now do the same thing for the file called `custom-run.sh` in the `beta3`
directory.  The only difference is that this time the file will be called `run`
in your repository's `.sti/bin` directory. There is currently a bug that
requires that both of these files be present in the `.sti/bin` folder:

    https://github.com/openshift/source-to-image/issues/173

Once the files are added, we can now do another build. The only difference in
the "custom" assemble and run scripts will be executed and log some extra
output.  We will see that shortly.
Did You See It?
But where's the output from the custom `run` script? The `assemble` script is
run inside of your builder pod. That's what you see by using `build-logs`. The
`run` script actually is what is executed to "start" your application's pod. In
other words, the `run` script is what starts the Ruby process for an image that
was built based on the `ruby-20-rhel7` STI builder. As `root` run:

    osc log -n wiring \
    `osc get pods -n wiring | \
    grep "^frontend-" | awk '{print $1}'` |\
    grep -i custom

You should see:

    2015-04-27T22:23:24.110630393Z ---> CUSTOM STI RUN COMPLETE

You will be able to do this as the `alice` user once the proxy development is
finished -- for the same reason that you cannot view build logs as regular
users, you also can't view pod logs as regular users.

## Lifecycle Pre and Post Deployment Hooks
Like in OpenShift 2, we have the capability of "hooks" - performing actions both
before and after the **deployment**. In other words, once an STI build is
complete, the resulting Docker image is pushed into the registry. Once the push
is complete, OpenShift detects an `ImageChange` and, if so configured, triggers
a **deployment**.

The *pre*-deployment hook is executed just *before* the new image is deployed.

The *post*-deployment hook is executed just *after* the new image is deployed.

How is this accomplished? OpenShift will actually spin-up an *extra* instance of
your built image, execute your hook script(s), and then shut down. Neat, huh?

Since we already have our `wiring` app pointing at our forked code repository,
let's go ahead and add a database migration file. In the `beta3` folder you will
find a file called `1_sample_table.rb`. Add this file to the `db/migrate` folder
of the `ruby-hello-world` repository that you forked. If you don't add this file
to the right folder, the rest of the steps will fail. You will want to make sure
that you add this to the `beta3` branch of your forked repository, since that is
the branch we are looking for when we do our builds.

### Examining the Deployment Configuration
Since we are talking about **deployments**, let's look at our
`DeploymentConfig`s. As the `alice` user in the `wiring` project:

    osc get dc

You should see something like:

    NAME       TRIGGERS       LATEST VERSION
    database   ConfigChange   1
    frontend   ImageChange    7

Since we are trying to associate a Rails database migration hook with our
application, we are ultimately talking about a deployment of the frontend. If
you edit the frontend's `DeploymentConfig`:

    osc edit dc frontend -ojson

Yes, the default for `osc edit` is to use YAML. For this exercise, JSON will be
easier as it is indentation-insensitive.

You should see a section that looks like the following:

    "strategy": {
        "type": "Recreate",
        "recreateParams": {
            "pre": {
                "failurePolicy": "Abort",
                "execNewPod": {
                    "command": [
                        "/bin/true"
                    ],
                    "env": [
                        {
                            "name": "CUSTOM_VAR1",
                            "value": "custom_value1"
                        }
                    ],
                    "containerName": "ruby-helloworld"
                }
            },
            "post": {
                "failurePolicy": "Ignore",
                "execNewPod": {
                    "command": [
                        "/bin/false"
                    ],
                    "env": [
                        {
                            "name": "CUSTOM_VAR2",
                            "value": "custom_value2"
                        }
                    ],
                    "containerName": "ruby-helloworld"
                }
            }
        }
    },

As you can see, we have both a *pre* and *post* deployment hook defined. They
don't actually do anything useful. But they are good examples.

The pre-deployment hook executes "/bin/true" whose exit code is always 0 --
success. If for some reason this failed (non-zero exit), our policy would be to
`Abort` -- consider the entire deployment a failure and stop.

The post-deployment hook executes "/bin/false" whose exit code is always 1 --
failure. The policy is to `Ignore`, or do nothing. For non-essential tasks that
might rely on an external service, this might be a good policy.

More information on these strategies, the various policies, and other
information can be found in the documentation:

    http://docs.openshift.org/latest/dev_guide/deployments.html

Note that these hooks are not defined by default - OpenShift did not
automatically generate them. If you look at the original JSON for the frontend
(`frontend-template.json`), you'll see that they are already there.

### Modifying the Hooks
A Rails migration is commonly performed when we have added/modified the database
as part of our code change. In the case of a pre- or post-deployment hook, it
would make sense to:

* Attempt to migrate the database
* Abort the new deployment if the migration fails

Otherwise we could end up with our new code deployed but our database schema
would not match. This could be a *Real Bad Thing (TM)*.

Since you should still have the `osc edit` session up, go ahead and delete the
section for the `post`-deployment hook.

In the case of the `ruby-20` builder image, we are actually using RHEL7 and the
Red Hat Software Collections (SCL) to get our Ruby 2.0 support. So, the command
we want to run looks like:

    /usr/bin/scl enable ruby200 ror40 'cd /opt/openshift/src ; bundle exec rake db:migrate'

This command:

* executes inside an SCL "shell"
* enables the Ruby 2.0.0 and Ruby On Rails 4.0 environments
* changes to the `/opt/openshift/src` directory (where our applications' code is
    located)
* executes `bundle exec rake db:migrate`

If you're not familiar with Ruby, Rails, or Bundler, that's OK. Just trust us.
Would we lie to you?

The `command` directive inside the hook's definition tells us which command to
actually execute. It is required that this is an array of individual strings.
Represented in JSON, our desired command above represented as a string array
looks like:

    "command": [
        "/usr/bin/scl",
        "enable",
        "ruby200",
        "ror40",
        "cd /opt/openshift/src ; bundle exec rake db:migrate"
    ]

This is great, but actually manipulating the database requires that we talk
**to** the database. Talking to the database requires a user and a password.

The pre- and post-deployment hook `env`ironments do not automatically inherit
the environment variables normally defined in the pod template. If we want to
make the database environment variables available during our hook, we need to
additionally define them. The current example in our `deploymentConfig` shows
the definition of some environment variables as part of the hooks. It looks very
similar to the `podTemplate` section, too. In fact, you can just copy and paste
the `env` section from the `podTemplate` section into your `pre` section.

So, in the end, you will have something that looks like:

    "strategy": {
        "type": "Recreate",
        "recreateParams": {
            "pre": {
                "failurePolicy": "Abort",
                "execNewPod": {
                    "command": [
                        "/usr/bin/scl",
                        "enable",
                        "ruby200",
                        "ror40",
                        "cd /opt/openshift/src ; bundle exec rake db:migrate"
                    ],
                    "env": [
                        {
                            "name": "ADMIN_USERNAME",
                            "key": "ADMIN_USERNAME",
                            "value": "adminTLY"
                        },
                        {
                            "name": "ADMIN_PASSWORD",
                            "key": "ADMIN_PASSWORD",
                            "value": "PMPuNmFY"
                        },
                        {
                            "name": "MYSQL_USER",
                            "key": "MYSQL_USER",
                            "value": "userFXW"
                        },
                        {
                            "name": "MYSQL_PASSWORD",
                            "key": "MYSQL_PASSWORD",
                            "value": "24JHg7iV"
                        },
                        {
                            "name": "MYSQL_DATABASE",
                            "key": "MYSQL_DATABASE",
                            "value": "root"
                        }
                    ],
                    "containerName": "ruby-helloworld"
                }
            },
        }
    },

Yours might look slightly different, because it is likely OpenShift generated
different passwords for you. Remember, indentation isn't critical in JSON, but
closing brackets and braces are.

When you are done editing the deployment config, save and quit your editor.

### Quickly Clean Up
When we did our previous builds and rollbacks and etc, we ended up with a lot of
stale pods that are not running (`Succeeded`). Currently we do not auto-delete
these pods because we have no log store -- once they are deleted, you can't view
their logs any longer.

For now, we can clean up by doing the following as `alice`:

    osc get pod |\
    grep -E "lifecycle|sti-build" |\
    awk {'print $1'} |\
    xargs -r osc delete pod

This will get rid of all of our old build and lifecycle pods. The lifecycle pods
are the pre- and post-deployment hook pods, and the sti-build pods are the pods
in which our previous builds occurred.

### Build Again
Now that we have modified the deployment configuration and cleaned up a bit, we
need to trigger another deployment. While killing the frontend pod would trigger
another deployment, our current Docker image doesn't have the database migration
file in it. Nothing really useful would happen.

In order to get the database migration file into the Docker image, we actually
need to do another build. Remember, the STI process starts with the builder
image, fetches the source code, executes the (customized) assemble script, and
then pushes the resulting Docker image into the registry. **Then** the
deployment happens.

As `alice`:

    osc start-build ruby-sample-build

### Verify the Migration
Once the build is complete, you should see something like the following output
of `osc get pod` as `alice`:

    POD                                IP          CONTAINER(S)               IMAGE(S)                                                                                                       HOST                                    LABELS                                                                                                                  STATUS      CREATED
    database-1-6lvao                   10.1.0.13   ruby-helloworld-database   registry.access.redhat.com/openshift3_beta/mysql-55-rhel7                                                      ose3-master.example.com/192.168.133.2   deployment=database-1,deploymentconfig=database,name=database,template=application-template-stibuild                    Running     2 hours
    deployment-frontend-9-hook-wlqqx               lifecycle                  172.30.17.24:5000/wiring/origin-ruby-sample:85e3393a2827ae4ce42ea6abf45a08e42d7c0d5f527f6415d35a4d4847392ed1   ose3-master.example.com/192.168.133.2   <none>                                                                                                                  Succeeded   4 minutes
    frontend-9-cb4u9                   10.1.0.56   ruby-helloworld            172.30.17.24:5000/wiring/origin-ruby-sample:85e3393a2827ae4ce42ea6abf45a08e42d7c0d5f527f6415d35a4d4847392ed1   ose3-master.example.com/192.168.133.2   deployment=frontend-9,deploymentconfig=frontend,name=frontend,template=application-template-stibuild                    Running     3 minutes
    ruby-sample-build-6                            sti-build                  openshift3_beta/ose-sti-builder:v0.4.3.2                                                                       ose3-master.example.com/192.168.133.2   build=ruby-sample-build-6,buildconfig=ruby-sample-build,name=ruby-sample-build,template=application-template-stibuild   Succeeded   5 minutes

You'll see that there is a single `hook`/`lifecycle` pod -- this corresponds
with the pod that ran our pre-deployment hook.

Inspect this pod's logs:

    osc log deployment-frontend-9-hook-wlqqx -n wiring

**Note:** You'll have to perform this as `root`.

The output likely shows:

    2015-04-29T22:17:30.928941999Z == 1 SampleTable: migrating
    ===================================================
    2015-04-29T22:17:30.929014043Z -- create_table(:sample_table)
    2015-04-29T22:17:30.929021057Z    -> 0.0995s
    2015-04-29T22:17:30.929024656Z == 1 SampleTable: migrated (0.0999s)
    ==========================================
    2015-04-29T22:17:30.929027404Z

If you have no output, you may have forgotten to actually put the migration file
in your repo. Without that file, the migration does nothing, which produces no
output.

For giggles, you can even talk directly to the database on its service IP/port
using the `mysql` client and the environment variables.

As `alice`, find your database:

    NAME       LABELS                                   SELECTOR        IP            PORT(S)
    database   template=application-template-stibuild   name=database   172.30.17.5   5434/TCP

Then, somewhere inside your OpenShift environment, use the `mysql` client to
connect to this service and dump the table that we created:

    mysql -u userJKL \
      -p 5678efgh \
      -h 172.30.17.208 \
      -P 5434 \
      -e 'show tables; describe sample_table;' \
      root
    +-------------------+
    | Tables_in_root    |
    +-------------------+
    | sample_table      |
    | key_pairs         |
    | schema_migrations |
    +-------------------+
    +-------+--------------+------+-----+---------+----------------+
    | Field | Type         | Null | Key | Default | Extra          |
    +-------+--------------+------+-----+---------+----------------+
    | id    | int(11)      | NO   | PRI | NULL    | auto_increment |
    | name  | varchar(255) | NO   |     | NULL    |                |
    +-------+--------------+------+-----+---------+----------------+

We've taken the content of this subfolder and placed it in the GitHub
`openshift/centos7-wordpress` repository. Let's run `osc new-app` and see what
happens:
    osc new-app https://github.com/openshift/centos7-wordpress.git -o yaml
### Create a Project
    osadm new-project wordpress --display-name="Wordpress" \
    --admin=alice
    osc project wordpress
    osc new-app -l name=wordpress https://github.com/openshift/centos7-wordpress.git

    services/centos7-wordpress
    imageStreams/centos7-wordpress
    buildConfigs/centos7-wordpress
    deploymentConfigs/centos7-wordpress
    Service "centos7-wordpress" created at 172.30.17.91:22 to talk to pods over port 22.
    A build was created - you can run `osc start-build centos7-wordpress` to start it.
    osc start-build centos7-wordpress
us here. Additionally, `osc new-app` currently has a bug in the way services are
detected, so we'll have a service for SSH (thus port 22 above) but not one for
httpd. So we'll add on a service and route for web access.
**Note:** If you're not using the `example.com` domain, you'll have to edit this
route to match your domain.

### Application Resource Labels

You may have wondered about the `-l name=wordpress` in the invocation above. This
applies a label to all of the resources created by `osc new-app` so that they can
be easily distinguished from any other resources in a project. For example, we
can easily delete only the things with this label:

    osc delete all -l name=wordpress

    buildConfigs/centos7-wordpress
    builds/centos7-wordpress-1
    deploymentConfigs/centos7-wordpress
    imageStreams/centos7-wordpress
    pods/centos7-wordpress-1
    pods/centos7-wordpress-1-j64ck
    replicationControllers/centos7-wordpress-1
    services/centos7-wordpress

Notice that the things we created from wordpress-addition.json didn't
have this label, so they didn't get deleted:
    osc get services

    NAME                      LABELS    SELECTOR                             IP             PORT(S)
    wordpress-httpd-service   <none>    deploymentconfig=centos7-wordpress   172.30.17.83   80/TCP
    osc get route
    NAME              HOST/PORT                         PATH      SERVICE                   LABELS
    wordpress-route   wordpress.cloudapps.example.com             wordpress-httpd-service
Labels will be useful for many things, including identification in the web console.

## EAP Example
This example requires internet access because the Maven configuration uses
public repositories.

If you have a Java application whose Maven configuration uses local
repositories, or has no Maven requirements, you could probably substitute that
code repository for the one below.

Note: Please ensure the correct EAP image stream has been added by verifying the *jboss-eap6-openshift* imagestream is available:

    osc get is -n openshift | grep jboss-eap6-openshift

### Create a Project
Using the skills you have learned earlier in the training, create a new project
for the EAP example. Choose a user as the administrator, and make sure to use
that user in the subsequent commands as necessary.

### Instantiate the Template
When we imported the imagestreams into the `openshift` namespace earlier, we
also brought in JBoss EAP and Tomcat STI builder images.

There are currently several application templates that can be used with these
images, except they leverage some features that were not available at the time
beta3 was cut.

We can still use them, but not in the same way we used the "Quickstart" template
arlier. We will have to process them from the CLI and massage them to substitute
some variables.

If you simply execute the following:

    osc process -f https://raw.githubusercontent.com/jboss-openshift/application-templates/ose-beta3/eap/eap6-basic-sti.json

You'll see that there are a number of bash-style variables (`${SOMETHING}`) in
use in this template. Since beta3 doesn't support these, we will have to do some
manual substitution. This template is already configured to use the EAP builder
image.

The following command will:

* set the application name to *helloworld*
* create a route for *helloworld.cloudapps.example.com*
* set Github and Generic trigger secrets to *secret*
* set the correct EAP image release
* set the Git repository URI, reference, and folder (where to get the source
    code)
* pipe this into `osc create` so that the template becomes an actionable
    configuration

    osc process -f https://raw.githubusercontent.com/jboss-openshift/application-templates/ose-beta3/eap/eap6-basic-sti.json \
    | sed -e 's/${APPLICATION_NAME}/helloworld/' \
    -e 's/${APPLICATION_HOSTNAME}/helloworld.cloudapps.example.com/' \
    -e 's/${GITHUB_TRIGGER_SECRET}/secret/' \
    -e 's/${GENERIC_TRIGGER_SECRET}/secret/' \
    -e 's/${EAP_RELEASE}/6.4/' \
    -e 's/${GIT_URI}/https:\/\/github.com\/jboss-developer\/jboss-eap-quickstarts/' \
    -e 's/${GIT_REF}/6.4.x/' -e 's/${GIT_CONTEXT_DIR}/helloworld/' \
### Update the BuildConfig
The template assumes that the imageStream exists in our current project, but
that is not the case. The EAP imageStream exists in the `openshift` namespace.
So we need to edit the resulting `buildConfig` and specify that.

    osc edit bc helloworld -o json

You will need to edit the `strategy` section to look like the following:

    "strategy": {
        "type": "STI",
        "stiStrategy": {
            "tag": "6.4",
            "from": {
                "kind": "ImageStream",
                "name": "jboss-eap6-openshift",
                "namespace": "openshift"
            },
            "clean": true
        }
    },

### Run the EAP Build
Once done, save and exit, which will update the `buildConfig`. Then, start the
build as `joe`:

    osc start-build helloworld
You can watch the build if you choose, or just look at the web console and wait
for it to finish. If you do watch the build, you might notice some Maven errors.
These are non-critical and will not affect the success or failure of the build.
### Visit Your Application
We specified a route when the template was processed, so you should be able to
visit your app at:

    helloworld.cloudapps.example.com/jboss-helloworld

The reason that it is "/jboss-helloworld" and not just "/" is because the
helloworld application does not use a "ROOT.war". If you don't understand this,
it's because Java is confusing.
## Conclusion
This concludes the Beta 3 training. Look for more example applications to come!
just want a quick and dirty way to set up DNS, you can install dnsmasq on one of
your nodes. Do **not** install DNSMasq on your master. OpenShift now has an
internal DNS service provided by Go's "SkyDNS" that is used for internal service
communication, which will be explored more in beta4.
* Your `cloudapps` domain points to the correct node ip in `dnsmasq.conf`
* The first `nameserver` in `/etc/resolv.conf` on the node running dnsmasq should be 127.0.0.1 and the second nameserver should be your corporate or upstream DNS resolver (eg: Google DNS @ 8.8.8.8); alternatively put upstream resolver as `server=8.8.8.8` in `/etc/dnsmasq.conf`
* the other nodes' and master's `/etc/resolv.conf` points to the IP address of the node
  running DNSMasq as the first nameserver
* That you also open port 53 (UDP) to allow DNS queries to hit the node


    
# APPENDIX - LDAP Authentication
OpenShift currently supports several authentication methods for obtaining API
tokens.  While OpenID or one of the supported Oauth providers are preferred,
support for services such as LDAP is possible today using either the [Basic Auth
Remote](http://docs.openshift.org/latest/admin_guide/configuring_authentication.html#BasicAuthPasswordIdentityProvider)
identity provider or the [Request
Header](http://docs.openshift.org/latest/admin_guide/configuring_authentication.html#RequestHeaderIdentityProvider)
Identity provider.  This example while demonstrate the ease of running a
`BasicAuthPasswordIdentityProvider` on OpenShift.
For full documentation on the other authentication options please refer to the
[Official
Documentation](http://docs.openshift.org/latest/admin_guide/configuring_authentication.html)
### Prerequirements:

* A working Router with a wildcard DNS entry pointed to it
* A working Registry

### Setting up an example LDAP server:

For purposes of this training it is possible to use a preexisting LDAP server
or the example ldap server that comes preconfigured with the users referenced
in this document.  The decision does not need to be made up front.  It is
possible to change the ldap server that is used at any time.

For convenience the example LDAP server can be deployed on OpenShift as
follows:

    osc create -f openldap-example.json

That will create a pod from an OpenLDAP image hosted externally on the Docker
Hub.  You can find the source for it [here](beta3/images/openldap-example/).

To test the example LDAP service you can run the following:

    yum -y install openldap-clients
    ldapsearch -D 'cn=Manager,dc=example,dc=com' -b "dc=example,dc=com" \
               -s sub "(objectclass=*)" -w redhat \
               -h `osc get services | grep openldap-example-service | awk '{print $4}'`

You should see ldif output that shows the example.com users.

### Creating the Basic Auth service

While the example OpenLDAP service is itself mostly a toy, the Basic Auth
service created below can easily be made highly available using OpenShift
features.  It's a normal web service that happens to speak the [API required by
the
master](http://docs.openshift.org/latest/admin_guide/configuring_authentication.html#BasicAuthPasswordIdentityProvider)
and talk to an LDAP server.  Since it's stateless simply increasing the
replicas in the replication controller is all that is needed to make the
application highly available.

To make this as easy as possible for the beta training a helper script has been
provided to create a Route, Service, Build Config and Deployment Config.  The
Basic Auth service will be configured to use TLS all the way to the pod by
means of the [Router's SNI
capabilities](http://docs.openshift.org/latest/architecture/core_objects/routing.html#passthrough-termination).
Since TLS is used this helper script will also generated the required
certificates using OpenShift default CA.

    ./basicauthurl.sh -h

No arguments are required but the help output will show you the defaults:

    --route    basicauthurl.example.com
    --git-repo git://github.com/brenton/basicauthurl-example.git

Once you run the helper script it will output the configuration changes
required for `/etc/openshift/master.yaml` as well as create
`basicauthurl.json`.  You can now feed that to `osc`:

    osc create -f basicauthurl.json

At this point everything is in place to start the build which will trigger the
deployment.

    osc start-build basicauthurl-build

When the build finished you can run the following command to test that the
Service is responding correctly:

    curl -v -u joe:redhat --cacert /var/lib/openshift/openshift.local.certificates/ca/cert.crt \
        --resolve basicauthurl.example.com:443:`osc get services | grep basicauthurl | awk '{print $4}'` \
        https://basicauthurl.example.com/validate

In that case in order for SNI to work correctly we had to trick curl with the `--resolve` flag.  If wildcard DNS is set up in your environment to point to the router then the following should test the service end to end:

    curl -u joe:redhat --cacert /var/lib/openshift/openshift.local.certificates/ca/cert.crt \
        https://basicauthurl.example.com/validate

If you've made the required changes to `/etc/openshift/mmaster.yaml` and
restarted `openshift-master` then you should now be able to log it with the
example users `joe` and `alice` with the password `redhat`.

### Using an LDAP server external to OpenShift

For more advanced usage it's best to refer to the
[README](https://github.com/openshift/sti-basicauthurl) for now.  All
mod_authnz_ldap directives are available.

### Upcoming changes

We've recently worked with Kubernetes upstream to add API support for Secrets.
Before GA the need for STI builds in this authentication approach may go away.
What this would mean is that admins would run a script to import an Apache
configuration in to a Secret and the Pod could use this on start up.  In this
case the Build Config would go away and only a Deployment Config would be
needed.

# APPENDIX - Import/Export of Docker Images (Disconnected Use)
Docker supports import/save of Images via tarball. These instructions are
general and may not be 100% accurate for the current release. You can do
something like the following on your connected machine:

    docker pull registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-deployer:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-sti-builder:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-builder:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-pod:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/ose-docker-registry:v0.4.3.2
    docker pull registry.access.redhat.com/openshift3_beta/sti-basicauthurl:latest
    docker pull registry.access.redhat.com/openshift3_beta/ruby-20-rhel7
    docker pull registry.access.redhat.com/openshift3_beta/mysql-55-rhel7
    docker save -o beta3-images.tar \
    registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.4.3.2 \
    registry.access.redhat.com/openshift3_beta/ose-deployer:v0.4.3.2 \
    registry.access.redhat.com/openshift3_beta/ose-sti-builder:v0.4.3.2 \
    registry.access.redhat.com/openshift3_beta/ose-docker-builder:v0.4.3.2 \
    registry.access.redhat.com/openshift3_beta/ose-pod:v0.4.3.2 \
    registry.access.redhat.com/openshift3_beta/ose-docker-registry:v0.4.3.2 \
    registry.access.redhat.com/openshift3_beta/sti-basicauthurl:latest \
    registry.access.redhat.com/openshift3_beta/ruby-20-rhel7 \
    registry.access.redhat.com/openshift3_beta/mysql-55-rhel7 \
    for resource in build buildconfig images imagestream deploymentconfig \
Deleting a project with `osc delete project` should delete all of its resources,
but you may need help finding things in the default project (where
infrastructure items are). Deleting the default project is not recommended.


An experimental diagnostics command is in progress for OpenShift v3, to hopefully
be included in the openshift binary for the next release. For now, you can download
the one for beta3 under [Luke Meyer's release page](https://github.com/sosiouxme/origin/releases).
Running this may save you some time by pointing you in the right direction
for common issues. This is very much still under development however.

Common problems

        F0310 14:59:59.219087   30319 get.go:164] request
        Proto:HTTP/1.1 ProtoMajor:1 ProtoMinor:1 Header:map[] Body:<nil> ContentLength:0 TransferEncoding:[]
        Close:false Host:ose3-master.example.com:8443 Form:map[] PostForm:map[]
        MultipartForm:<nil> Trailer:map[] RemoteAddr: RequestURI: TLS:<nil>}]
    In most cases if admin (certificate) auth is still working this means the token is invalid.  Soon there will be more polish in the osc tooling to handle this edge case automatically but for now the simplist thing to do is to recreate the client config.
        # If a stale token exists it will prevent the beta3 login command from working
        rm ~/.config/openshift/.config
        osc login \
        --certificate-authority=/var/lib/openshift/openshift.local.certificates/ca/cert.crt \
    This generally means you do not have a client config file at all, as it should
    supply the certificate authority for validating the master. You could also
    have the wrong CA in your client config. You should probably regenerate
    your client config as in the previous suggestion.

# APPENDIX - Infrastructure Log Aggregation
Given the distributed nature of OpenShift you may find it beneficial to
aggregate logs from your OpenShift infastructure services. By default, openshift
services log to the systemd journal and rsyslog persists those log messages to
`/var/log/messages`. We''ll reconfigure rsyslog to write these entries to
`/var/log/openshift` and configure the master host to accept log data from the
other hosts.

## Enable Remote Logging on Master
Uncomment the following lines in your master's `/etc/rsyslog.conf` to enable
remote logging services.

    $ModLoad imtcp
    $InputTCPServerRun 514

Restart rsyslog

    systemctl restart rsyslog



## Enable logging to /var/log/openshift
On your master update the filters in `/etc/rsyslog.conf` to divert openshift logs to `/var/log/openshift`

    # Log openshift processes to /var/log/openshift
    :programname, contains, "openshift"                     /var/log/openshift

    # Log anything (except mail) of level info or higher.
    # Don't log private authentication messages!
    # Don't log openshift processes to /var/log/messages either
    :programname, contains, "openshift" ~
    *.info;mail.none;authpriv.none;cron.none                /var/log/messages

Restart rsyslog

    systemctl restart rsyslog

## Configure nodes to send openshift logs to your master
On your other hosts send openshift logs to your master by adding this line to
`/etc/rsyslog.conf`

    :programname, contains, "openshift" @@ose3-master.example.com

Restart rsyslog

    systemctl restart rsyslog

Now all your openshift related logs will end up in `/var/log/openshift` on your
master.

## Optionally Log Each Node to a unique directory
You can also configure rsyslog to store logs in a different location
based on the source host. On your master, add these lines immediately prior to
`$InputTCPServerRun 514`

    $template TmplMsg, "/var/log/remote/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log"
    $RuleSet remote1
    authpriv.*   ?TmplAuth
    *.info;mail.none;authpriv.none;cron.none   ?TmplMsg
    $RuleSet RSYSLOG_DefaultRuleset   #End the rule set by switching back to the default rule set
    $InputTCPServerBindRuleset remote1  #Define a new input and bind it to the "remote1" rule set

Restart rsyslog

    systemctl restart rsyslog


Now logs from remote hosts will go to `/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log`

See these documentation sources for additional rsyslog configuration information

    https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-basic_configuration_of_rsyslog.html
    http://www.rsyslog.com/doc/v7-stable/configuration/filters.html

# APPENDIX - JBoss Tools for Eclipse
Support for OpenShift development using Eclipse is provided through the JBoss Tools plugin.  The plugin is available
from the Jboss Tools nightly build of the Eclipse Mars.

Development is ongoing but current features include:

- Connecting to an OpenShift server using Oauth
    - Connections to multiple servers using multiple user names
- OpenShift Explorer
    - Browsing user projects
    - Browsing project resources
- Display of resource properties

## Installation
1. Install the Mars release of Eclipse from the [Eclipse Download site](http://www.eclipse.org/downloads/)
1. Add the update site
  1. Click from the toolbar 'Help > Install New Sofware'
  1. Click the 'Add' button and a dialog appears
  1. Enter a value for the name
  1. Enter 'http://download.jboss.org/jbosstools/updates/nightly/mars/' for the location.  **Note:** Alternative updates are available from
     the [JBoss Tools Downloads](http://tools.jboss.org/downloads/jbosstools/mars/index.html).  The various releases and code
     freeze dates are listed on the [JBoss JIRA site](https://issues.jboss.org/browse/JBIDE/?selectedTab=com.atlassian.jira.jira-projects-plugin:versions-panel)
  1. Click 'OK' to add the update site
1. Type 'OpenShift' in the text input box to filter the choices
1. Check 'JBoss OpenShift v3 Tools' and click 'Next'
1. Click 'Next' again, accept the license agreement, and click 'Finish'

After installation, open the OpenShift explorer view by clicking from the toolbar 'Window > Show View > Other' and typing 'OpenShift'
in the dialog box that appears.

## Connecting to the Server
1. Click 'New Connection Wizard' and a dialog appears
1. Select a v3 connection type
1. Uncheck default server
1. Enter the URL to the OpenShift server instance
1. Enter the username and password for the connection

A successful connection will allow you to expand the OpenShift explorer tree and browse the projects associated with the account
and the resources associated with each project.

# APPENDIX - Working with HTTP Proxies

In many production environments direct access to the web is not allowed.  In
these situations there is typically an HTTP(S) proxy available.  Configuring
OpenShift builds and deployments to use these proxies is as simple as setting
standard environment variables.  The trick is knowing where to place them.

## Importing ImageStreams

Since the importer is on the Master we need to make the configuration change
there.  The easiest way to do that is to add environment variables `NO_PROXY`,
`HTTP_PROXY`, and `HTTPS_PROXY` to `/etc/sysconfig/openshift-master` then restart
your master.

~~~
HTTP_PROXY=http://USERNAME:PASSWORD@10.0.1.1:8080/
HTTPS_PROXY=https://USERNAME:PASSWORD@10.0.0.1:8080/
NO_PROXY=master.example.com
~~~

It's important that the Master doesn't use the proxy to access itself so make
sure it's listed in the `NO_PROXY` value.

Now restart the Service:
~~~
systemctl restart openshift-master
~~~

If you had previously imported ImageStreams without the proxy configuration to can re-run the process as follows:

~~~
osc delete imagestreams -n openshift --all
osc create -f image-streams.json -n openshift
~~~

## STI Builds

Let's take the sinatra example.  That build uses fetches gems from
rubygems.org.  The first thing we'll want to do is fork that codebase and
create a file called `.sti/environment`.  The contents of the file are simple
shell variables.  Most libraries will look for `NO_PROXY`, `HTTP_PROXY`, and
`HTTPS_PROXY` variables and react accordingly.

    NO_PROXY=mycompany.com
    HTTP_PROXY=http://USER:PASSWORD@IPADDR:PORT
    HTTPS_PROXY=https://USER:PASSWORD@IPADDR:PORT

## Setting Environment Variables in Pods

It's not only at build time that proxies are required.  Many applications will
need them too.  In previous examples we used environment variables in
`DeploymentConfig`s to pass in database connection information.  The same can
be done for configuring a `Pod`'s proxy at runtime:

    {
      "apiVersion": "v1beta1",
      "kind": "DeploymentConfig",
      "metadata": {
        "name": "frontend"
      },
      "template": {
        "controllerTemplate": {
          "podTemplate": {
            "desiredState": {
              "manifest": {
                "containers": [
                  {
                    "env": [
                      {
                        "name": "HTTP_PROXY",
                        "value": "http://USER:PASSWORD@IPADDR:PORT"
                      },
    ...


## Git Repository Access

In most of the beta examples code has been hosted on GitHub.  This is strictly
for convenience and in the near future documentation will be published to show
how best to integrate with GitLab as well as corporate git servers.  For now if
you wish to use GitHub behind a proxy you can set an environment variable on
the `stiStrategy`:

    {
      "stiStrategy": {
        ...
        "env": [
          {
            "Name": "HTTP_PROXY",
            "Value": "http://USER:PASSWORD@IPADDR:PORT"
          }
        ]
      }
    }

It's worth noting that if the variable is set on the `stiStrategy` it's not
necessary to use the `.sti/environment` file.

## Proxying Docker Pull

This is yet another case where it may be necessary to tunnel traffic through a
proxy.  In this case you can edit `/etc/sysconfig/docker` and add the variables
in shell format:

    NO_PROXY=mycompany.com
    HTTP_PROXY=http://USER:PASSWORD@IPADDR:PORT
    HTTPS_PROXY=https://USER:PASSWORD@IPADDR:PORT

## Future Considerations

We're working to have a single place that administrators can set proxies for
all network traffic.

# APPENDIX - Installing in IaaS Clouds
This appendix contains two "versions" of installation instructions. One is for
"generic" clouds, where the installer does not provision any resources on the
actual cloud (eg: it does not stand up VMs or configure security groups).
Another is specifically for AWS, which can take your API credentials and
configure the entire AWS environment, too.

## Generic Cloud Install

**An Example Hosts File (/etc/ansible/hosts):**

    [OSEv3:children]
    masters
    nodes

    [OSEv3:vars]
    deployment_type=enterprise

    # The default user for the image used
    ansible_ssh_user=ec2-user

    # host group for masters
    # The entries should be either the publicly accessible dns name for the host
    # or the publicly accessible IP address of the host.
    [masters]
    ec2-52-6-179-239.compute-1.amazonaws.com

    # host group for nodes
    [nodes]
    ec2-52-6-179-239.compute-1.amazonaws.com #The master
    ... <additional node hosts go here> ...

**Testing the Auto-detected Values:**
Run the openshift_facts playbook:

    cd ~/openshift-ansible
    ansible-playbook playbooks/byo/openshift_facts.yml

The output will be similar to:

    ok: [10.3.9.45] => {
        "result": {
            "ansible_facts": {
                "openshift": {
                    "common": {
                        "hostname": "ip-172-31-8-89.ec2.internal",
                        "ip": "172.31.8.89",
                        "public_hostname": "ec2-52-6-179-239.compute-1.amazonaws.com",
                        "public_ip": "52.6.179.239",
                        "use_openshift_sdn": true
                    },
                    "provider": {
                      ... <snip> ...
                    }
                }
            },
            "changed": false,
            "invocation": {
                "module_args": "",
                "module_name": "openshift_facts"
            }
        }
    }
    ...

Next, we'll need to override the detected defaults if they are not what we expect them to be

* hostname
  * Should resolve to the internal ip from the instances themselves.
  * openshift_hostname will override.
* ip
  * Should be the internal ip of the instance.
  * openshift_ip will override.
* public hostname
  * Should resolve to the external ip from hosts outside of the cloud
  * provider openshift_public_hostname will override.
* public_ip
  * Should be the externally accessible ip associated with the instance
  * openshift_public_ip will override

To override the the defaults, you can set the variables in your inventory. For
example, if using AWS and managing dns externally, you can override the host
public hostname as follows:

    [masters]
    ec2-52-6-179-239.compute-1.amazonaws.com openshift_public_hostname=ose3-master.public.example.com

Running ansible:

    ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml

## Automated AWS Install With Ansible

**Requirements:**
- ansible-1.8.x
- python-boto

**Assumptions Made:**
- The user's ec2 credentials have the following permissions:
  - Create instances
  - Create EBS volumes
  - Create and modify security groups
    - The following security groups will be created:
      - openshift-v3-training-master
      - openshift-v3-training-node
  - Create and update route53 record sets
- The ec2 region selected is using ec2 classic or has a default vpc and subnets configured.
  - When using a vpc, the default subnets are expected to be configured for auto-assigning a public ip as well.
- If providing a different ami id using the EC2_AMI_ID, it is a cloud-init enabled RHEL-7 image.

**Setup (Modifying the Values Appropriately):**

    export AWS_ACCESS_KEY_ID=MY_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=MY_SECRET_ACCESS_KEY
    export EC2_REGION=us-east-1
    export EC2_AMI_ID=ami-12663b7a
    export EC2_KEYPAIR=MY_KEYPAIR_NAME
    export RHN_USERNAME=MY_RHN_USERNAME
    export RHN_PASSWORD=MY_RHN_PASSWORD
    export ROUTE_53_WILDCARD_ZONE=cloudapps.example.com
    export ROUTE_53_HOST_ZONE=example.com

**Clone the openshift-ansible repo and configure helpful symlinks:**
    ansible-playbook clone_and_setup_repo.yml

**Configuring the Hosts:**

    ansible-playbook -i inventory/aws/hosts openshift_setup.yml

**Accessing the Hosts:**
Each host will be created with an 'openshift' user that has passwordless sudo configured.

# APPENDIX - Linux, Mac, and Windows clients

The OpenShift client `osc` is available for Linux, Mac OSX, and Windows. You
can use these clients to perform all tasks in this documentation that make use
of the `osc` command.

## Downloading The Clients

Visit [Download Red Hat OpenShift Enterprise Beta](https://access.redhat.com/downloads/content/289/ver=/rhel---7/0.4.3.2/x86_64/product-downloads)
to download the Beta3 clients. You will need to sign into Customer Portal using
an account that includes the OpenShift Enterprise High Touch Beta entitlements.

**Note**: Certain versions of Internet Explorer will save the Windows
client without the .exe extension. Please rename the file to `osc.exe`.

## Log In To Your OpenShift Environment

You will need to log into your environment using `osc login` as you have
elsewhere. If you have access to the CA certificate you can pass it to osc with
the --certificate-authority flag or otherwise import the CA into your host's
certificate authority. If you do not import or specify the CA you will be
prompted to accept an untrusted certificate which is not recommended.

The CA is created on your master in `/var/lib/openshift/openshift.local.certificates/ca/cert.crt`

    C:\Users\test\Downloads> osc --certificate-authority="cert.crt"
    OpenShift server [[https://localhost:8443]]: https://ose3-master.example.com:8443
    Authentication required for https://ose3-master.example.com:8443 (openshift)
    Username: joe
    Password:
    Login successful.

    Using project "sinatra"

On Mac OSX and Linux you will need to make the file executable

    chmod +x osc

In the future users will be able to download clients directly from the OpenShift
console rather than needing to visit Customer Portal.
