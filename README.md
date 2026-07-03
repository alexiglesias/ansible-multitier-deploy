# Project 04 - Config Management: Ansible over Vagrant VMs

100% local. No cloud account, no Terraform needed (that's Project 08).

## Prerequisites

- VirtualBox installed
- Vagrant installed
- Ansible installed on your **host** machine (`pip install ansible --break-system-packages`
  or `brew install ansible` / `apt install ansible`)
- The `community.mysql` collection: `ansible-galaxy collection install community.mysql`

## Step 1 - Bring up the 3 VMs

```bash
vagrant up
```

This reads the `Vagrantfile` and creates `web01` (192.168.56.11), `app01` (192.168.56.12)
and `db01` (192.168.56.13) on a private VirtualBox network.

## Step 2 - ansible.cfg

Already in place at the project root. It points Ansible at `./inventory/hosts`,
disables host key checking (fine for throwaway local VMs), sets `remote_user = vagrant`,
and turns on `become` (sudo) by default so you don't need `-b` on every command.

## Step 3 - Inventory

`inventory/hosts` defines three groups - `[websrvgrp]`, `[appsrvgrp]`, `[dbsrvgrp]` -
each pointing at the matching VM's IP and Vagrant-generated SSH key.

> Note: Vagrant only creates `.vagrant/machines/<name>/virtualbox/private_key` **after**
> `vagrant up` has run for that VM, so do Step 1 before Step 4.

## Step 4 - Verify connectivity

```bash
ansible all -m ping
```

You should get a `SUCCESS` pong from `web01`, `app01`, and `db01`. If you get a
permission or key error, double-check the `ansible_ssh_private_key_file` paths in
`inventory/hosts` match where Vagrant actually put the keys (`vagrant ssh-config`
will show you).

## Step 5 - Roles

Already written under `roles/`:

- `roles/mysql` - installs MySQL, sets the root password, creates the `accounts`
  database and an app user, opens it to remote connections.
- `roles/tomcat` - installs OpenJDK 17, downloads & extracts Tomcat 10, creates a
  dedicated `tomcat` system user, and runs it as a systemd service.
- `roles/nginx` - installs Nginx and configures it as a reverse proxy to `app01:8080`.

## Step 6 - site.yml

`site.yml` is the entry point: it applies the `mysql` role to `dbsrvgrp`, `tomcat` to
`appsrvgrp`, and `nginx` to `websrvgrp`, in that order.

```bash
ansible-playbook site.yml
```

The first run will take a few minutes (downloading packages + Tomcat).

## Step 7 - Idempotency check

```bash
ansible-playbook site.yml
```

Run it a **second** time. Every task should report `ok` (green) - nothing should show
as `changed` (yellow), because the desired state is already in place. This is the core
promise of configuration management: re-running is always safe.

If something does show `changed` on the second run, that's usually a sign a task isn't
properly idempotent (e.g. a `command`/`shell` task instead of a proper Ansible module) -
a good thing to debug as part of learning Ansible.

## Step 8 - Encrypt the secrets with Ansible Vault

Right now `vars/secrets.yml` is plaintext - fine for testing, not fine to commit to Git.

```bash
ansible-vault encrypt vars/secrets.yml
```

You'll be asked to set a vault password. From then on, run the playbook with:

```bash
ansible-playbook site.yml --ask-vault-pass
```

(or store the password in a file and use `--vault-password-file path/to/file`,
keeping that file itself out of Git via `.gitignore`).

To edit the encrypted file later: `ansible-vault edit vars/secrets.yml`.

## Deliverable checklist

- [x] `inventory/` + `ansible.cfg`
- [x] `roles/nginx`, `roles/tomcat`, `roles/mysql` - tasks, handlers, templates
- [x] `site.yml` deploying the full stack from zero
- [ ] Push this repo to Git/GitHub **after** vault-encrypting `vars/secrets.yml`

## Optional next step

Once `nginx` is up, visit `http://192.168.56.11` from your host browser - you should
see Nginx's proxy hit Tomcat's default landing page on `app01`. To deploy an actual
WAR file, set `war_file_path` (e.g. as an extra var: `-e war_file_path=/path/to/app.war`)
and re-run the playbook.
