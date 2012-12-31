require 'spec_helper'

describe Cloudster::ChefClient do
  describe 'initialize' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::ElasticIp.new() }.to raise_error(ArgumentError, 'Missing required argument: name')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::ElasticIp.new(:name => 'ElasticIp') }.to_not raise_error
    end
  end
  describe '#add_to' do
    it "should add elastic ip configuration to ec2 template" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'AppServer', :instance_type => 't1.micro' )
      elastic_ip = Cloudster::ElasticIp.new(:name => 'ElasticIp')
      elastic_ip.add_to ec2
      ec2.template.should ==
        {
          "Resources"=>{
            "AppServer"=>{
              "Type"=>"AWS::EC2::Instance",
              "Properties"=>{
                "KeyName"=>"testkey",
                "ImageId"=>"image_id",
                "InstanceType"=>"t1.micro",
              }
            },
            "ElasticIp"=>{
              "Type"=>"AWS::EC2::EIP",
              "Properties"=>{
                "InstanceId"=> {
                  "Ref" => "AppServer"
                }
              }
            }
          }
        }
    end
  end
end
