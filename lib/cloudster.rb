##
#This file requires all dependencies
require 'json'
require 'fog'
require 'cloudster/options_manager'
require 'cloudster/deep_merge'
include OptionsManager
require 'cloudster/ec2'
require 'cloudster/elb'
require 'cloudster/rds'
require 'cloudster/cloud'
require 'cloudster/chef_client'
