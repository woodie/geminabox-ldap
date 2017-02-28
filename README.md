# geminabox-ldap
Gem "in a box" with LDAP/AD authentication &amp; branding on Docker


### A Quick Demo

To upload a gem, authenticate as `tesla` with password `password`.

    docker run -d -p 2222:9292 woodie/geminabox-ldap

### Production Usage

Make sure `/var/lib/geminabox-data` is backed up on the host.
Pass configuration information by environment file (see examples below):

    docker run -d -p 2222:9292 --restart unless-stopped --env-file our.env \
    -v /var/lib/geminabox-data:/app/data:rw woodie/geminabox-ldap

### Nginx Proxy

Use Nginx and setup a CNAME. For testing, add the hostname `rubygems.example.com` to your `/etc/hosts` file.

    docker run -d -p 80:80 --restart unless-stopped \
    -v /var/run/docker.sock:/tmp/docker.sock:ro woodie/nginx-proxy

### General Configuration

Environment variables that should be passed to the container can go in `our.env`  file.
The `RACK_ENV` variable tell rack to behave in production mode (especially regarding errors).
The `VIRTUAL_HOST` is used by the Nginx, the `HEADER_IMAGE` will replace the generic image,
and the `AUTH_BACKDOOR` provides an upload token for users that have already authenticated.

    # General configuration
    RACK_ENV=production
    VIRTUAL_HOST=rubygems.example.com
    HEADER_IMAGE=http://bit.ly/2lJIYsJ
    AUTH_BACKDOOR=allow

### LDAP/AD Configuration

For LDAP autentication, we don't (currently) provide an option to bind with `BASE_DN`, 
instead we construct a user's DN from `LDAP_BRANCH` and `LDAP_BASE` and bind as that user.
Use `LDAP_MEMBER` to restrict gem uploads to a specific group. For Active Directory,
user login uses `sAMAccountname` and `LDAP_BASE` to bind.

    # Sample LDAP configurtion
    LDAP_ATTRIBUTE=uid
    LDAP_BASE=DC=example,DC=com
    LDAP_MEMBER=OU=scientists
    LDAP_HOST=ldap.forumsys.com

    # SAMPLE LDAP configurtion with branch
    LDAP_ATTRIBUTE=uid
    LDAP_BASE=DC=zflexsoftware,DC=com
    LDAP_BRANCH=OU=users,OU=developers
    LDAP_MEMBER=CN=devgroup1
    LDAP_HOST=www.zflexldap.com

    # Sample AD configurtion
    LDAP_ATTRIBUTE=sAMAccountname
    LDAP_BASE=DC=example,DC=com
    LDAP_MEMBER=CN=DEVELOPERS
    LDAP_HOST=example.com

### Documentation

The FAQ is intended to be generic, provide best practices. Corrections and suggestions are welcome.
