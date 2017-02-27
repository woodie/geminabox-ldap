# geminabox-ldap
Gem "in a box" with LDAP/AD authentication &amp; branding for Docker


### Quick Demo

To quickly run geminabox-ldap (without persistence):

    docker run -d -p 2222:9292 woodie/geminabox-ldap

To upload a gem, authenticate as `tesla` with password `password`.

### Production Usage

You will want to use Nginx and setup a CNAME. For testing, add the hostname `rubygems.example.com` to your `/etc/hosts` file.

Run the nginx-proxy proxy:

    docker run -d -p 80:80 --restart unless-stopped \
    -v /var/run/docker.sock:/tmp/docker.sock:ro woodie/nginx-proxy

Pass configuration information by environment file (see examples below):

    docker run -d -p 2222:9292 --restart unless-stopped --env-file our.env \
    -v /var/lib/geminabox-data:/app/data:rw woodie/geminabox-ldap

Make sure `/var/lib/geminabox-data` is backed up on the host.


### Configuration

Any environment variables that should be passed to the container can go in `our.env`  file.
The `VIRTUAL_HOST` is used by the Nginx, the `HEADER_IMAGE` will replace the generic image,
and the `AUTH_BACKDOOR` provides an upload token for users that have already authenticated.

    VIRTUAL_HOST=rubygems.example.com
    HEADER_IMAGE=http://bit.ly/2lJIYsJ
    AUTH_BACKDOOR=allow

    # The default configuration uses a sample LDAP server.
    # Use `LDAP_MEMBER` to restrict gem uploads to that group.
    LDAP_ATTRIBUTE=uid
    LDAP_BASE=DC=example,DC=com
    LDAP_MEMBER=OU=scientists
    LDAP_HOST=ldap.forumsys.com

    # For LDAP autentication, we must be able to construct
    # a user's DN from `LDAP_BRANCH` and `LDAP_BASE`.
    LDAP_ATTRIBUTE=uid
    LDAP_BASE=DC=zflexsoftware,DC=com
    LDAP_BRANCH=OU=users,OU=developers
    LDAP_MEMBER=CN=devgroup1
    LDAP_HOST=www.zflexldap.com

    # For Active Directory, user DN need not include login.
    # AD uses `sAMAccountname` and `LDAP_BASE` to bind.
    LDAP_ATTRIBUTE=sAMAccountname
    LDAP_BASE=DC=example,DC=com
    LDAP_MEMBER=CN=DEVELOPERS
    LDAP_HOST=example.com


### Documentation

The FAQ is intended to be generic, provide best practices. Corrections and suggestions are welcome.
