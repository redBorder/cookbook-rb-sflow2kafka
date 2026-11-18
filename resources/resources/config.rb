# Cookbook:: rb-sflow2kafka
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/redborder-sflow2kafka'
attribute :sensors, kind_of: Hash, default: {}
attribute :kafka_hosts, kind_of: Array, default: ['127.0.0.1']
attribute :kafka_topic, kind_of: String, default: 'rb_flow'
attribute :kafka_broker_port, kind_of: Integer, default: 9092
attribute :sflow2kafka_ip, kind_of: String
# memory assigned to the service in KB (node['redborder']['memory_services'])
attribute :memory, kind_of: Integer
