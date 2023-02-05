# Puppet Demo Guide

This repo has the files needed to follow along with the Puppet demo. Instructions have been provided here for your convenience so you can better follow along or review at a later time.

## Demo 1: Setting up a Puppet Server and Agent to host a website.

#### Step 0 (pre-reqs):
First, we're going to need a subnet and a security group with inbound access to ports 22 (SSH), 443 (HTTPS), and 8140. If you don't already have these, make them before getting started.

A full list of potentially utilized ports is available at https://www.puppet.com/docs/pe/2019.8/system_configuration.html.

#### Step 1:
Next, we're going to launch the primary server instance. 

For this, let's use the **t3.small** size with the AWS Linux 2 AMI, making sure to use a key pair. Request a spot instance if possible.

Additionally, use the following user data when launching the instance:
```
#!/bin/bash
sudo yum update -y
sudo rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
sudo yum install puppetserver -y
```

### Step 2:
Once the instance is launched, connect to it via SSH. To verify that the user data installed puppetserver correctly, use the following command:
```
systemctl status puppetserver
```

If everything went well, you should get a report of the status of the puppetserver service, like so:
![image](https://user-images.githubusercontent.com/121134907/216831455-d5135488-fe6c-46b5-bc80-392ac9e88f7b.png)

### Step 3:
Now that we've installed the puppetserver service, we're going to need to change some settings so that the puppetserver knows it's the server.
```
sudo su
puppet config set server use_hostname_of_server_here
puppet config set ca_server use_hostname_of_server_here
```

### Step 4:
Now that we've updated the server's settings, let's start up the puppet server service:
```
systemctl start puppetserver
```

If we wanted to have puppetserver run on startup, then we would additionally run:
```
systemctl enable puppetserver
```

### Step 5:
WITHOUT closing your ssh connection to the primary server, let's launch our agent.

Choose a **t3.micro** size with the AWS Linux 2 AMI, making sure to use a key pair. Request a spot instance if possible.

Additionally, use the following user data when launching the instance:
```
#!/bin/bash
sudo yum update -y
sudo rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
sudo yum install puppet-agent -y
```

### Step 6:
In a new command line window/tab, ssh into your new agent instance. To verify that the agent service is installed, you can run the following command:
```
systemctl status puppet
```

Next, we'll need to run some config:
```
source /etc/profile.d/puppet-agent.sh
sudo su
puppet config set server use_hostname_of_server_here
puppet config set ca_server use_hostname_of_server_here
puppet config set runinterval 180
puppet resource service puppet ensure=running enable=true
```

### Step 7:
Now that we have an agent and server, we can have them connect via HTTPS. However, in order for this to work, we'll need the agent to request an SSL cert from the primary server.

To do this, run the following from the agent:
```
puppet ssl bootstrap
```

This will send a request, but we still need to sign it. So, jumping over to the SSH tab with the primary server, we run the following to check for any waiting cert requests:
```
/opt/puppetlabs/bin/puppetserver ca list
```

Once we have the name of the incoming cert request, we can sign it by running the following:
```
/opt/puppetlabs/bin/puppetserver ca sign --certname name_of_cert
```

If everything goes well, you'll see the agent side exit successfully after it tries the signing again.

### Step 8:
Now that everything is hooked up together, let's actually do something interesting. and configure our agent to host a website.

Back on the primary server, we'll need to install the apache module:
```
/opt/puppetlabs/bin/puppet module install puppetlabs-apache
```

### Step 9:
Once we have the relevant module installed, we can add in a configuration file into the production manifests branch of the hierarchy:
```
curl https://raw.githubusercontent.com/sringleskillstorm/puppet-demo/main/version_demo.pp > /etc/puppetlabs/code/environments/production/manifests/site.pp
```

To test that this worked, we can visit the agent at its public address. Note that this may take a few minutes to actually change since the run interval is 3 min. If you want to speed this up, run the following from the agent:

```
puppet agent -t
```

### Step 10:
Let's prove the self healing part of Puppet. Let's mess up our website and then see if Puppet fixes it in the given time frame.

Using your code editor of choice, change the file at /var/www/html/index.html. Alternatively, delete the file altogther with the rm command.

After the run interval, your code will be back to the GitHub version.

Similarly, if we change the config file to use the v2 website file on GitHub, we'll get the V2 version.

## Demo 2: Using the AWS module
If you're coming right from Demo 1, you may terminate your agent instance.

### Step 1:
If you are coming right from Demo 1, stop the puppetserver service on your primary server by running the following:

```
systemctl stop puppetserver
```

Then, download the necessary AWS module and retries gems. Note that the retries gems take awhile (~10 min.).
```
/opt/puppetlabs/puppet/bin/gem install aws-sdk retries
/opt/puppetlabs/bin/puppet module install puppetlabs-aws
```

Once these are done installing, you may restart your puppetserver service.
```
systemctl start puppetserver
```

Alternatively, if you doing this demo on its own, set up a primary puppet server without running the service, install the retries gems and AWS module, and then start the puppetserver service.

### Step 2:
After the installations are done, we're going to change our manifest file to use AWS infrastructure:
```
curl https://raw.githubusercontent.com/sringleskillstorm/puppet-demo/main/aws_infrastructure_demo.pp > /etc/puppetlabs/code/environments/production/manifests/site.pp
```

