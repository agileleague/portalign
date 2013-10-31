portalign
=========
By Micah Wedemeyer of [The Agile League](http://agileleague.com)


Summary
=======
A tool to automatically add and remove your current IP address to Amazon EC2 security groups.

Description
===========

It's good policy to keep your security groups as restrictive as
possible. But, as is often the case with security, convenience suffers
as you get more secure. portalign is a tool that allows you to maintain
restrictive policies in your security groups while also giving
convenient access.

With portalign, you can easily update a security group to add your
current IP address to the list of allowed IPs for a port (usually 22).
So, instead of complicated port knocking schemes or ssh tunnelling 
through other allowed EC2 nodes, you can ssh directly in to your machine
normally.

When you're done working on the node, portalign can restore the policy back to extreme strictness. Enable the port, do your work, disable the port. Easy and secure.

Quick Start
===========

* gem install portalign
* create a .portalign.yml file in your current project with your AWS
  credentials and the security group.
* portalign
* ssh me@myserver (do what you need to on the server)
* portalign -d (to remove the authorization when you're done)


Installation
============

* gem install portalign

Configuration
=============

The preferred configuration method is using a .portalign.yml file. It
will look for one in $HOME/.portalign.yml and $PWD/.portalign.yml  Any
settings found in the current directory will override those in the $HOME
directory. So, if you have multiple projects with different security
groups, you can set your AWS credentials in one file (in $HOME) and put
the various security groups in configuration files in each project.

Example File:

    access_key_id: "acb1234"
    secret_access_key: "1234abc"
    region: "us-west-1"
    security_groups:
    - "mygroup"
    - "othergroup"
    ports:
    - 22
    - 8080
    - 10000

Note: As you're probably aware, your AWS credentials are the keys to the kingdom. It's a good idea to restrict and protect the .portalign.yml file as you would a private key. chmod 600 is a good start.

Configuration Options
---------------------
* access_key_id - AWS access key
* secret_access_key - AWS secret access key
* security_groups - A list of EC2 security groups (by name, not id)
* ports - A list of ports to open (defaults to 22)
* protocol - The protocol (tcp, udp, icmp), defaults to tcp

Usage
=====
To add your current IP to the security group

    portalign

To add 0.0.0.0/0 (wide open, allow any IP) to the security group

    portalign -w

To remove your current IP (and 0.0.0.0/0) from the security group

    portalign -d
    
You can also specify many configuration options on the command line. Those specified on the command line will override anything from a config file.

    portalign --access-key-id=abc123 --secret-access-key=123abc --ports=22,80 --security-groups=mygroup,othergroup

License
-------
See LICENSE.md for details.