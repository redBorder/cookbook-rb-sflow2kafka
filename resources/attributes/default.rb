# Flags
default['redborder-sflow2kafka']['registered'] = false

# x2kafka sflow listener
default['redborder-sflow2kafka']['port'] = 6343
# keepalived checks /health on this port: keep it in sync with the health_port of redborder-sflow2kafka
# in cookbook-rb-manager and with the ports opened by cookbook-rb-firewall
default['redborder-sflow2kafka']['stats_port'] = 7984
