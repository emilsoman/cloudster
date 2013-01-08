##
#This file requires all dependencies
require 'json'
require 'fog'
require 'cloudster/output'
require 'cloudster/options_manager'
require 'cloudster/deep_merge'
include OptionsManager
require 'cloudster/ec2'
require 'cloudster/elb'
require 'cloudster/rds'
require 'cloudster/s3'
require 'cloudster/elasticache'
require 'cloudster/cloud'
require 'cloudster/chef_client'
require 'cloudster/elastic_ip'
require 'cloudster/cloud_front'
