# Cookbook:: rb-sflow2kafka
# Provider:: config

include Sflow2kafka::Helper

action :add do
  begin
    config_dir = new_resource.config_dir
    sensors = new_resource.sensors
    settings = {
      bind: new_resource.sflow2kafka_ip || '0.0.0.0',
      brokers: new_resource.kafka_hosts.map { |host| "#{host}:#{new_resource.kafka_broker_port}" },
      topic: new_resource.kafka_topic,
      memory: new_resource.memory,
    }

    # redborder-sflow2kafka ships the redborder-sflow2kafka unit running x2kafka
    dnf_package 'redborder-sflow2kafka' do
      action :upgrade
    end

    # restart redborder-sflow2kafka when a new x2kafka is installed
    dnf_package 'x2kafka' do
      action :upgrade
      notifies :restart, 'service[redborder-sflow2kafka]', :delayed unless node['redborder']['leader_configuring']
    end

    directory config_dir do
      owner 'root'
      group 'root'
      mode '0755'
    end

    template "#{config_dir}/config.json" do
      source 'sflow2kafka_config.json.erb'
      cookbook 'rb-sflow2kafka'
      owner 'root'
      group 'root'
      mode '0644'
      retries 2
      variables(config: x2kafka_config(sensors, settings))
      notifies :restart, 'service[redborder-sflow2kafka]', :delayed unless node['redborder']['leader_configuring']
    end

    service 'redborder-sflow2kafka' do
      service_name 'redborder-sflow2kafka'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true, stop: true
      if node['redborder']['leader_configuring']
        action [:enable]
      else
        action [:enable, :start]
      end
    end

    Chef::Log.info('rb-sflow2kafka cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'redborder-sflow2kafka' do
      service_name 'redborder-sflow2kafka'
      ignore_failure true
      supports status: true, enable: true, stop: true
      action [:stop, :disable]
    end

    directory new_resource.config_dir do
      recursive true
      action :delete
    end

    # x2kafka is left installed, other services (http2k, redborder-netflow2kafka) run it too
    dnf_package 'redborder-sflow2kafka' do
      action :remove
    end

    Chef::Log.info('rb-sflow2kafka cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['sflow2kafka']['registered']
      query = {}
      query['ID'] = "sflow2kafka-#{node['hostname']}"
      query['Name'] = 'sflow2kafka'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = node['sflow2kafka']['port'].to_s
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['sflow2kafka']['registered'] = true
      Chef::Log.info('sflow2kafka service has been registered in consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['sflow2kafka']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/sflow2kafka-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['sflow2kafka']['registered'] = false
      Chef::Log.info('sflow2kafka service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
