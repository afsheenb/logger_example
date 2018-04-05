global
    maxconn 32768

defaults
    mode http
    timeout connect 10000ms
    timeout client 6000000ms
    timeout server 6000000ms

frontend http-in
    bind *:80

    default_backend prod
    
    acl dev_env hdr(environment) -i dev
    acl staging_env hdr(environment) -i staging
    
    use_backend dev if dev_env 
    use_backend staging if staging_env


backend prod
    balance roundrobin
    option http-keep-alive
    server prod <%= @ipaddress_ens3 %>:8001 maxconn 32

backend dev 
    balance roundrobin
    option http-keep-alive
    server dev <%= @ipaddress_ens3 %>:8081 maxconn 32

backend staging 
    balance roundrobin
    option http-keep-alive
    server staging <%= @ipaddress_ens3 %>:8091 maxconn 32

listen admin
    bind 127.0.0.1:8008
    stats enable
