### ansible-role

Conjur OSS demo that uses an Ansible role to establish host machine identities with host factory tokens First demonstrated at AnsibleFest 2017. This repo copied from https://github.com/jvanderhoof/Ansiblefest-2017 with additional demo scripts added by JHunt.

This project includes all the elements required to run the demo.

### Demo flow
1) setup 4 terminal/shell windows and one browser window:
   - Conjur shell - to startup conjur in
   - CLI shell - to run a Conjur CLI client shell container
   - Script shell - to run demo scripts in
   - File shell - to show Conjur policy and Ansible role/task files
   - Browser window - to show deployed application
2) in Conjur shell, run demo.sh to startup conjur, minimize it when it's ready
3) in CLI shell, run ./cli-shell.sh, type cd to go to home directory, ls to verify the demo directory is mounted correctly
4) in Script shell, run ./1_load_policies.sh to start loading policies, don't wait for it to finish
5) in File shell
   - run conts-list.sh to show running staging and production hosts.
   - describe how we're going to use Ansible and Conjur to deploy a web application, where each host is authenticated and authorized for access to only the secrets each needs, using principles of least privilege.
   - cd to policy, cat users.yml. 
     - Describe groups, users and role grants to create group hierarchy.
     - Emphasize RBAC & least privilege.
     - Describe how privilege increases from top to bottom, because lower groups inherit privileges from higher.
     - Point out how so far there's no actual privileges granted.
   - cat policy.yml
     - Describe how this creates root policies for staging and production envs, w/ different admin owner groups.
     - Describe how we can now apply application policies to setup consistent security structure across each env.
   - cd to apps, cat myapp.yml
     - Describe how this file defines the security structure for one of potentially many apps.
     - It should be managed as an application artifact, just like database schema definitions.
     - It gets applied to each root environment policy to create consistent, cookie-cutter security structure.
     - Describe variables, groups, privilege grants, highlight the privilege grant to the layer.
     - Describe how the layer will have the name of the policy by default, how it represents a group of hosts.
     - Describe the host factory redemption process, how that will establish individual machine identities for each host.
     - Point out how the layer is a member of secrets_user, therefore can only read/execute secrets.
   - cat myapp_grants.yml
     - Discuss how these grants enable different groups to update secrets in each environment. Mention RBAC & least privilege again.
   - cd ..
6) in Script shell, scroll through policy load output to show how each of the policies was loaded.
7) in CLI shell, run user_list.sh, host_list.sh and vars_list.sh and how there are no values yet for secrets.
8) in Script shell, run 2_set_secrets.sh, don't wait for it to finish
9) in File shell, cd to ansible, ls to show contents, cd to roles, ls to show ansible-role-conjur dir
10) pushd into ansible/playbooks
   - Describe how the idea behind ansible roles is to allow you to define what a server is supposed to do, instead of having to specify the exact steps needed to get a server to act a certain way. In this case we want a general approach to establishing machine identities across hosts in different environments.
   - cat myapp.yml and show how the role is invoked with the HF token to establish machine identity then tasks invoked to restart the app server
   - Optionally, to go deeper in the role implementation:
      - pushd into ../roles/ansible-role-conjur/configure-conjur-identity/tasks
      - pwd to show path, how we're now deep in the ansible role implementation
      - cat identity.yml, walk through quickly and describe how ansible uses this to redeem HF tokens to create host identities
      - popd back to playbooks
11) popd back to the demo directory
12) run ./vars-list.sh again to show how the vars now have values.
13) Now we have what we need to deploy to staging, run "./deploy.sh staging" in the Script window
14) Narrate execution to show how Ansible is establishing indentity for two staging servers and deploying the app.
15) use conts-list.sh to get the port of a staging container, browse to localhost:\<port\> to see deployed application, compare password displayed to password displayed by ./vars-list.sh in the CLI shell.
16) pick one of the ports for a production server, show how it's not deployed in the Browser window
17) run "./deploy.sh production" in Script window, refresh browser to show deployed app, compare database password w/ one in CLI shell.
18) Review talking points of demo:
    - We used Ansible and open source Conjur to secure an Ansible role deployment workflow with machine identities.
    - Secrets are now encrypted and all access to them authenticated and authorized, with identities established dynamically.
    - Conjur policies are "security as code" where an application's security structure can be managed as source code and consistently established across multiple environments, using automation tools like Ansible.

### Requirements
The following are required to run this demo
* Docker 17.03.1
* Ansible 2.3.2.0 (Installed via Pip)
* Python 2.7.13
* jq 1.5.2

It's been tested on OSX. It should work on other operating systems, but I have not tested it.

### Setup

To begin, clone this repository and step into the folder.  

#### Start the Cluster

To begin, fire up the cluster, which includes Conjur, Postgres, CLI, 2 Staging Containers, and 4 production servers:

```sh
$ ./demo.sh
```

To exit, `ctr-c`

#### Load Policy

Load the full policy, users, and groups from the `/policy` folder:

```sh
$ ./1_load_policies.sh
```

#### Set Secrets

Load values into our variables:

```sh
$ ./2_set_secrets.sh
```

#### Ansible

There is a single `deploy.sh` file responsible for deploying to the Staging or Production environment.

This script does the following:

1. Generate a Host Factory token for that particular environment
2. Uses [cyberark/ansible-role-conjur]() role to:
  * Provide identity to the remote instance
  * Add them to the correct layer based on the provided Host Factory token.
3. Retrieve secrets using the identity of that machine.

To perform the above steps on the staging environment:
```sh
$ ./deploy.sh staging
```


To perform the above steps on the production environment:
```sh
$ ./deploy.sh production
```

#### Scaling Production Nodes

To demonstrate the simplicity of scaling up using Host Factory tokens, scale production nodes from 4 to 20:

```sh
$ docker-compose scale myapp_production=20
```

Next, in the `ansible/inventory` file, change the line: `ansiblefest_myapp_production_[1:4]` to `ansiblefest_myapp_production_[1:20]` and save the file.

Then, re-run the production configuration:

```sh
$ ./deploy.sh production
```

#### View Application Containers

Docker Compose handles the port mapping, binding each container to localhost. To pull the app on a browser, you'll need to pass the docker-compose assigned port.  You can get this port by viewing the running containers:

```sh
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                            NAMES
37881ae9a161        ansiblefest_foo_production   "sleep infinity"         35 minutes ago      Up 35 minutes       0.0.0.0:32833->4567/tcp          ansiblefest_foo_production_4
f666344b3335        ansiblefest_foo_production   "sleep infinity"         35 minutes ago      Up 35 minutes       0.0.0.0:32832->4567/tcp          ansiblefest_foo_production_2
281feaaf7801        ansiblefest_foo_production   "sleep infinity"         35 minutes ago      Up 35 minutes       0.0.0.0:32831->4567/tcp          ansiblefest_foo_production_3
28491d3b7004        ansiblefest_foo_staging      "sleep infinity"         35 minutes ago      Up 35 minutes       0.0.0.0:32830->4567/tcp          ansiblefest_foo_staging_2
bc56fd64848e        cyberark/conjur              "conjurctl server ..."   35 minutes ago      Up 35 minutes       80/tcp, 0.0.0.0:3000->3000/tcp   ansiblefest_conjur_1
1745b25df6a0        postgres:9.3                 "docker-entrypoint..."   35 minutes ago      Up 35 minutes       5432/tcp                         ansiblefest_pg_1
cd22a04ed277        ansiblefest_foo_production   "sleep infinity"         35 minutes ago      Up 35 minutes       0.0.0.0:32829->4567/tcp          ansiblefest_foo_production_1
08136c4ea9e5        ansiblefest_foo_staging      "sleep infinity"         35 minutes ago      Up 35 minutes       0.0.0.0:32828->4567/tcp          ansiblefest_foo_staging_1
```

For the above example, the first container (`37881ae9a161`), can be viewed on port `32833`: `0.0.0.0:32833->4567/tcp`. This container is accessible via:

http://localhost:32833
