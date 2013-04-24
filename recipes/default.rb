#
# Cookbook Name:: docker
# Recipe:: default
#
# Copyright 2013, Troy Howard
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w{ lxc debootstrap wget bsdtar git pkg-config libsqlite3-dev }.each do |name|
  package name
end

["linux-image-#{node['kernel']['release']}", "linux-headers-#{node['kernel']['release']}"].each do |name|
  package name
end

# If aufs isn't available, do our best to install the correct 
# linux-image-extra package. This is somewhat messy because the
# naming of these packages is very inconsistent across kernel
# versions
extra_package = %x(apt-cache search linux-image-extra-`uname -r | grep --only-matching -e [0-9]\.[0-9]\.[0-9]-[0-9]*` | cut -d " " -f 1).strip
package extra_package do
  not_if "modprobe -l | grep aufs"
end

include_recipe("modules::default")
modules "aufs" do
  action :save
end

execute "fetch go" do
  creates "/usr/local/go/bin/go"
  command "wget -O - #{node['docker']['go_url']} | /bin/tar xz -C /usr/local"
end

execute "fetch docker" do
  command "wget -O - #{node['docker']['docker_url']} | /bin/tar xz -C /tmp"
end

template "/etc/init/dockerd.conf" do
  source "dockerd.conf"
  mode "0600"
  owner "root"
  group "root"
end

template "/home/vagrant/.profile" do
  source "profile"
  mode "0644"
  owner "vagrant"
  group "vagrant"
  only_if { File.exists?("/home/vagrant") }
end

execute "copy docker bin" do
  command "/usr/bin/sudo /bin/cp -f /tmp/docker-master/docker /usr/local/bin/"
end

service "dockerd" do
  provider Chef::Provider::Service::Upstart  
  supports :status => true, :restart => true, :reload => true
  action [ :start ]
end
