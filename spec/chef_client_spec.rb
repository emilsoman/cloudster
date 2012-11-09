require 'spec_helper'

describe Cloudster::ChefClient do
  describe 'initialize' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::ChefClient.new() }.to raise_error(ArgumentError, 'Missing required argument: validation_key,server_url,node_name')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::ChefClient.new(:validation_key => 'somekey', :server_url => 'testurl', :node_name => 'uniquename') }.to_not raise_error
    end
  end
  describe '#add_to' do
    it "should add chef client configuration to ec2 template" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'AppServer', :instance_type => 't1.micro' )
      chef_client = Cloudster::ChefClient.new(:validation_key => 'somekey', :server_url => 'testurl', :node_name => 'uniquename')
      chef_client.add_to ec2
      ec2.template.should == 
        {
          "Resources"=>{
            "AppServer"=>{
              "Type"=>"AWS::EC2::Instance",
              "Properties"=>{
                "KeyName"=>"testkey",
                "ImageId"=>"image_id",
                "InstanceType"=>"t1.micro",
                "UserData"=>{
                  "Fn::Base64"=>{
                    "Fn::Join"=>["", [
                      "#!/bin/bash -v\n", 
                      "function error_exit\n", 
                      "{\n", "  exit 1\n", "}\n",
                      "mkdir /etc/chef\n",
                      "cat << EOF > /etc/chef/solo.rb\n",
                      "file_cache_path \"/tmp/chef-solo\"\n",
                      "cookbook_path \"/tmp/chef-solo/cookbooks\"\n",
                      "EOF\n", "cat << EOF > /etc/chef/chef.json\n",
                      "{\n", "\"chef_server\": {\n",
                      "  \"server_url\": \"http://localhost:4000\",\n",
                      "  \"webui_enabled\": true,\n",
                      "  \"node_name\": \"uniquename\"\n",
                      "},\n",
                      "\"run_list\": [\"recipe[chef-client::config]\", \"recipe[chef-client]\"]\n",
                      "}\n",
                      "EOF\n",
                      "# Bootstrap chef\n",
                      "chef-solo -c /etc/chef/solo.rb -j /etc/chef/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz  > /tmp/chef_solo.log 2>&1 || error_exit 'Failed to bootstrap chef client'\n",
                      "# Fixup the server URL in client.rb\n",
                      "echo \"somekey\" > /etc/chef/validation.pem 2>&1 || error_exit 'Failed to get Chef Server validation key'\n",
                      "sed -i 's|http://localhost:4000|", "testurl", "|g' /etc/chef/client.rb\n",
                      "chef-client -i 20 > /tmp/chef_client.log 2>&1 || error_exit 'Failed to initialize host via chef client' \n"
                    ]]
                  }
                }
              },
              "Metadata"=>{
                "AWS::CloudFormation::Init"=>{
                  "config"=>{
                    "packages"=>{
                      "rubygems"=>{
                        "chef"=>[],
                        "ohai"=>[]
                      },
                      "apt"=>{
                        "ruby"=>[],
                        "ruby-dev"=>[],
                        "libopenssl-ruby"=>[],
                        "rdoc"=>[],
                        "ri"=>[],
                        "irb"=>[],
                        "build-essential"=>[],
                        "wget"=>[],
                        "ssl-cert"=>[],
                        "rubygems"=>[]
                      }
                    }
                  }
                }
              }
            }
          }
        }
    end
  end
end
