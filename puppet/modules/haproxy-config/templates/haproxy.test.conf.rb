global
    maxconn 4096

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http-in
    bind *:80

    default_backend prod
    
    acl staging_env hdr(environment) -i staging
    use_backend staging if staging_env

    acl prod_env hdr(environment) -i prod
    use_backend prod if prod_env


backend prod
    balance roundrobin
    option http-keep-alive
    {{ range getvs "/lens-prod/port" }}
    server prod <%= @ipaddress_ens3%>:8001 {{ . }} check
    {{ end }}
    {{ range getvs "/lens-stage/port" }}
    server staging <%= @ipaddress_ens3 %>:8001 check backup
    {{ end }}

backend staging 
    balance roundrobin
    option http-keep-alive
    {{ range getvs "/lens-stage/port" }}
    server staging <%= @ipaddress_ens3%>:8081 {{ . }} check
    {{ end }}
    {{ range getvs "/lens-prod/port" }}
    server prod <%= @ipaddress_ens3 %>:8091 check backup
    {{ end }}

listen admin
    bind *:6008
    stats enable
