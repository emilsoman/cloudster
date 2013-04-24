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
      chef_client = Cloudster::ChefClient.new(:validation_key => 'somekey', :server_url => 'testurl', :node_name => 'uniquename', :interval => 30)
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
                      "{\n",
                      "  exit 1\n",
                      "}\n",
                      "apt-get -y install python-setuptools\n",
                      "easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz\n",
                      "cfn-init -v --region ", {"Ref"=>"AWS::Region"}, " -s ", {"Ref"=>"AWS::StackId"},
                      " -r AppServer", " || error_exit 'Failed to run cfn-init'\n",
                      "export PATH=$PATH:/var/lib/gems/1.8/bin\n",
                      "mkdir /etc/chef\n",
                      "cat << EOF > /etc/chef/solo.rb\n",
                      "file_cache_path \"/tmp/chef-solo\"\n",
                      "cookbook_path \"/tmp/chef-solo/cookbooks\"\n",
                      "node_name \"uniquename\"\n",
                      "EOF\n",
                      "cat << EOF > /etc/chef/chef.json\n",
                      "{\n",
                      "\"chef_client\": {\n",
                      "  \"server_url\": \"testurl\",\n",
                      "  \"validation_client_name\": \"chef-validator\",\n",
                      "  \"interval\": \"30\"\n",
                      "},\n",
                      "\"run_list\": [\"recipe[chef-client::config]\", \"recipe[chef-client]\"]\n",
                      "}\n",
                      "EOF\n",
                      "echo \"somekey\" > /etc/chef/validation.pem\n",
                      "# Bootstrap chef\n",
                      "chef-solo -c /etc/chef/solo.rb -j /etc/chef/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz  > /tmp/chef_solo.log 2>&1 || error_exit 'Failed to bootstrap chef client'\n"

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
          },
          "Outputs" => {
            "AppServer"=>{
              "Value"=>{
                "Fn::Join"=>[",", 
                  [
                    {"Fn::Join"=>["|", ["availablity_zone", {"Fn::GetAtt"=>["AppServer", "AvailabilityZone"]}]]},
                    {"Fn::Join"=>["|", ["private_dns_name", {"Fn::GetAtt"=>["AppServer", "PrivateDnsName"]}]]},
                    {"Fn::Join"=>["|", ["public_dns_name", {"Fn::GetAtt"=>["AppServer", "PublicDnsName"]}]]},
                    {"Fn::Join"=>["|", ["private_ip", {"Fn::GetAtt"=>["AppServer", "PrivateIp"]}]]},
                    {"Fn::Join"=>["|", ["public_ip", {"Fn::GetAtt"=>["AppServer", "PublicIp"]}]]},
		     {"Fn::Join"=>["|", ["instance_id", {"Ref"=> "AppServer"}]]}
                  ]
                ]
              }
            }
          }
        }
    end
  end
end
