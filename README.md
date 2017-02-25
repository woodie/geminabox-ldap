# geminabox-ldap
Gem "in a box" with LDAP/AD authentication &amp; branding for Docker


### Usage

To quickly run geminabox-ldap:

    docker run -d -p 2222:9292 woodie/geminabox-ldap

To upload a gem, authenticate as `tesla` with password `password`.

If you want to use Nginx, setup a CNAME (or add a hostname like rubygems.example.com) to your `/etc/hosts` file.

Run the nginx-proxy proxy:

    docker run -d -p 80:80 --restart unless-stopped -v /var/run/docker.sock:/tmp/docker.sock:ro woodie/nginx-proxy

Pass configuration information by environment file (see examples below):

    docker run -d -p 2222:9292 --env-file our.env --restart unless-stopped -v /var/lib/geminabox-data:/app/data:rw woodie/geminabox-ldap


### Configuration

Any environment variables that should be passed to the container can go in this file.
The `VIRTUAL_HOST` is used by the Nginx, the `HEADER_IMAGE` will replace the generic image,
and the `BACKDOOR` provides an upload token for users that have already authenticated.

```shell
VIRTUAL_HOST=rubygems.example.com
HEADER_IMAGE=http://bit.ly/2lJIYsJ
BACKDOOR=allow
```

The default configuration uses a sample LDAP server. Use `LDAP_MEMBER` to restrict gem uploads to that group.

```shell
LDAP_ATTRIBUTE=uid
LDAP_BASE=DC=example,DC=com
LDAP_MEMBER=OU=scientists
LDAP_HOST=ldap.forumsys.com
```

For LDAP autentication, we must be able to construct a user's DN from `LDAP_BRANCH` and `LDAP_BASE`.

```shell
LDAP_ATTRIBUTE=uid
LDAP_BASE=DC=zflexsoftware,DC=com
LDAP_BRANCH=OU=users,OU=developers
LDAP_MEMBER=CN=devgroup1
LDAP_HOST=www.zflexldap.com
```

For Active Directory, we bind using `sAMAccountname` and `LDAP_BASE` to bind.

```shell
LDAP_ATTRIBUTE=sAMAccountname
LDAP_BASE=DC=example,DC=com
LDAP_MEMBER=CN=DEVELOPERS
LDAP_HOST=example.com
```


### Documentation

The FAQ is intended to be generic, provide best practices. Corrections and suggestions are welcome.
