#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for rails-passenger."
node[:app][:provider] = "app_passenger"

case node[:platform]
when "ubuntu"
  node[:app][:packages] = [
    "libopenssl-ruby",
    "libcurl4-openssl-dev",
    "apache2-mpm-prefork",
    "apache2-prefork-dev",
    "libapr1-dev",
    "libcurl4-openssl-dev"
   ]
  node[:app][:user] = "www-data"
  node[:app][:group] = "www-data"
when "centos","redhat"
  node[:app][:packages] = [
    "zlib-devel",
    "openssl-devel",
    "readline-devel",
    "curl-devel",
    "httpd-devel",
    "apr-devel",
    "apr-util-devel",
    "readline-devel"
   ]
  node[:app][:user] = "apache"
  node[:app][:group] = "apache"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Determine the gem environment from what is installed
gemenv = Chef::ShellOut.new("/usr/bin/gem env")
gemenv.run_command
gemenv.error!

# Setting passenger binary directory
gemenv.stdout =~ /EXECUTABLE DIRECTORY: (.*)$/
node[:app_passenger][:passenger_bin_dir] = $1

# Path to Ruby gem directory
gemenv.stdout =~ /INSTALLATION DIRECTORY: (.*)$/
node[:app_passenger][:ruby_gem_base_dir] = $1

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
node[:app][:root] = node[:app][:destination] + "/public"

# We do not care about version number here.
# need only the type of database adaptor
node[:app][:db_adapter] = node[:db][:provider_type].match(/^db_([a-z]+)/)[1]

rightscale_marker :end
