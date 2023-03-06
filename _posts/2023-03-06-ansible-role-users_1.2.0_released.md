---
layout: post
title: "Ansible role: users 1.2.0 released"
date: 2023-03-06 19:30:00 +0200
comments: true
categories: [ ansible ]
excerpt_separator: <!--more-->
---

<a href="{{ '/images/ansible-role-users/playbook.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/ansible-role-users/playbook.png' | remove_first:'/' | absolute_url }}" class="right" width="680" height="385" alt="playbook" /> </a>

The Ansible role stafwag.users is available at: [https://github.com/stafwag/ansible-role-users](https://github.com/stafwag/ansible-role-users)

This release implements a shell parameters to define shell for an user. See the [github issue for](https://github.com/stafwag/ansible-role-users/issues/1) more details.


# ChangeLog

shell parameter 

* shell parameter added

***Have fun!***

<!--more-->
# Ansible Role: users

An ansible role to manage user and user files - files in the home directory -.

## Requirements

None

## Role Variables

### OS related variables

The following variables are set by the role.

* **root_group**: The operating system root group. root by default. wheel on BSD systems.
* **sudo_group**: The operating system sudo group. wheel by default. sudo on Debian systems.

### Playbook related variables

* **users**:
  Array of users to manage
  * **name**: name of the user.
  * **group**: primary group. if ***state*** is set to present the user primary group will be created. if ***state*** is set to absent the primary group will be removed.
  * **uid**: uid.
  * **gid**: gid.
  * **groups**: additional groups.
  * **append**:  no (default) | yes.
If yes, add the user to the groups specified in groups. If no, user will only be added to the groups specified in groups, removing them from all other groups.
  * **state**:  absent | present (default)
  * **comment**: user comment (GECOS)
  * **home**: Optionally set the user's home directory.
  * **password**: Optionally set the user's password to this crypted value.
  * **password_lock**: no|yes lock password (ansible 2.6+)
  * **ssh_authorized_keys**: Array of the user ssh authorized keys
    * **key**: The ssh public key
    * **state**: absent | present (default) Whether the given key (with the given key_options) should or should not be in the file.
    * **exclusive**: no (default)| yes. Whether to remove all other non-specified keys from the authorized_keys file.
    * **key_options**: A string of ssh key options to be prepended to the key in the authorized_keys file.
  * **user_files**: array of the user files to manage.
    * **path**: path in the user home directoy. The home directory will be detected by getent_passwd
    * **content**: file content
    * **state**: absent | present (default)
    * **backup**: no (default) | yes. create a backup file.
    * **dir_create**: false (default) | true. 
    * **dir_recurse**: no (default) | yes create the directory recursively.
    * **mode**: Default: '0600'. The permissions of the resulting file.
    * **dir_mode**: Default: '0700'. The permissions of the resulting directory.
    * **owner**: Name of the owner that should own the file/directory, as would be fed to chown.
    * **owner**: Name of the group that should own the file/directory, as would be fed to chown.
  * **user_lineinfiles**: Array of user lineinfile.
    * **path**: path in the user home directoy. The home directory will be detected by getent_passwd
    * **regexp**: The regular expression to look for in every line of the file.
    * **line**: The line to insert/replace into the file.
    * **state**: absent | present (default)
    * **backup**: no (default) | yes Create a backup
    * **mode**: Default: 600. The permissions of the resulting file.
    * **dir_mode**: Default: 700. The permissions of the resulting directory.
    * **owner**: Name of the owner that should own the file/directory, as would be fed to chown.
    * **owner**: Name of the group that should own the file/directory, as would be fed to chown.
    * **create**: Default: no. Create file if not exists

## Dependencies

None

## Example Playbooks

### Create user with authorized key

```
- name: add user & ssh_authorized_key
  hosts: testhosts
  become: true
  vars:
    users:
      - name: test0001
        group: test0001
        password: "{{ hashed_password }}"
        state: "present"
        ssh_authorized_keys:
          - key: "{{lookup('file', '~/.ssh/id_rsa.pub') }}"
            key_options: "no-agent-forwarding"
  roles:
    - stafwag.users
```

### Add user to the sudo group

```
- name: add user to the sudo group
  hosts: testhosts
  become: true
  vars:
    users:
      - name: test0001
        groups: "{{ sudo_group }}"
        append: true
  roles:
    - stafwag.users
```

### Create .ssh/config.d/intern_config and include it in .ssh/config

```
- name: setup tyr ssh_config
  become: true
  hosts: tyr
  vars:
    users:
      - name: staf
        user_files:
          - name: ssh config
            path: .ssh/config
            dir_create: true
            state: present
          - name: ssh config.d/intern_config
            path: .ssh/config.d/intern_config
            content: "{{ lookup('file','files/intern_ssh_config') }}"
            dir_create: true
        user_lineinfiles:
          - name: include intern_config
            path: .ssh/config
            state: present
            regexp: "^include config.d/intern_config"
            line: "include config.d/intern_config"
  roles:
    - stafwag.users
```

## License

MIT/BSD

## Author Information

Created by Staf Wagemakers, email: staf@wagemakers.be, website: http://www.wagemakers.be.
# Ansible Role: users

An ansible role to manage user and user files - files in the home directory -.

## Requirements

None

## Role Variables

### OS related variables

The following variables are set by the role.

* **root_group**: The operating system root group. root by default. wheel on BSD systems.
* **sudo_group**: The operating system sudo group. wheel by default. sudo on Debian systems.

### Playbook related variables

* **users**:
  Array of users to manage
  * **name**: name of the user.
  * **group**: primary group. if ***state*** is set to present the user primary group will be created. if ***state*** is set to absent the primary group will be removed.
  * **uid**: uid.
  * **gid**: gid.
  * **groups**: additional groups.
  * **append**:  no (default) | yes.
If yes, add the user to the groups specified in groups. If no, user will only be added to the groups specified in groups, removing them from all other groups.
  * **state**:  absent | present (default)
  * **comment**: user comment (GECOS)
  * **home**: Optionally set the user's home directory.
  * **password**: Optionally set the user's password to this crypted value.
  * **password_lock**: no|yes lock password (ansible 2.6+)
  * **shell**: Optionally, the user shell
  * **ssh_authorized_keys**: Array of the user ssh authorized keys
    * **key**: The ssh public key
    * **state**: absent | present (default) Whether the given key (with the given key_options) should or should not be in the file.
    * **exclusive**: no (default)| yes. Whether to remove all other non-specified keys from the authorized_keys file.
    * **key_options**: A string of ssh key options to be prepended to the key in the authorized_keys file.
  * **user_files**: array of the user files to manage.
    * **path**: path in the user home directoy. The home directory will be detected by getent_passwd
    * **content**: file content
    * **state**: absent | present (default)
    * **backup**: no (default) | yes. create a backup file.
    * **dir_create**: false (default) | true. 
    * **dir_recurse**: no (default) | yes create the directory recursively.
    * **mode**: Default: '0600'. The permissions of the resulting file.
    * **dir_mode**: Default: '0700'. The permissions of the resulting directory.
    * **owner**: Name of the owner that should own the file/directory, as would be fed to chown.
    * **owner**: Name of the group that should own the file/directory, as would be fed to chown.
  * **user_lineinfiles**: Array of user lineinfile.
    * **path**: path in the user home directoy. The home directory will be detected by getent_passwd
    * **regexp**: The regular expression to look for in every line of the file.
    * **line**: The line to insert/replace into the file.
    * **state**: absent | present (default)
    * **backup**: no (default) | yes Create a backup
    * **mode**: Default: 600. The permissions of the resulting file.
    * **dir_mode**: Default: 700. The permissions of the resulting directory.
    * **owner**: Name of the owner that should own the file/directory, as would be fed to chown.
    * **owner**: Name of the group that should own the file/directory, as would be fed to chown.
    * **create**: Default: no. Create file if not exists

## Dependencies

None

## Example Playbooks

### Create user with authorized key

```
- name: add user & ssh_authorized_key
  hosts: testhosts
  become: true
  vars:
    users:
      - name: test0001
        group: test0001
        password: "{{ hashed_password }}"
        state: "present"
        ssh_authorized_keys:
          - key: "{{lookup('file', '~/.ssh/id_rsa.pub') }}"
            key_options: "no-agent-forwarding"
  roles:
    - stafwag.users
```

### Add user to the sudo group

```
- name: add user to the sudo group
  hosts: testhosts
  become: true
  vars:
    users:
      - name: test0001
        groups: "{{ sudo_group }}"
        append: true
  roles:
    - stafwag.users
```

### Create .ssh/config.d/intern_config and include it in .ssh/config

```
- name: setup tyr ssh_config
  become: true
  hosts: tyr
  vars:
    users:
      - name: staf
        user_files:
          - name: ssh config
            path: .ssh/config
            dir_create: true
            state: present
          - name: ssh config.d/intern_config
            path: .ssh/config.d/intern_config
            content: "{{ lookup('file','files/intern_ssh_config') }}"
            dir_create: true
        user_lineinfiles:
          - name: include intern_config
            path: .ssh/config
            state: present
            regexp: "^include config.d/intern_config"
            line: "include config.d/intern_config"
  roles:
    - stafwag.users
```

## License

MIT/BSD

## Author Information

Created by Staf Wagemakers, email: staf@wagemakers.be, website: http://www.wagemakers.be.
