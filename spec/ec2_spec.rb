require 'spec_helper'

describe Cloudster::Ec2 do
  describe 'initialize' do
    it "should raise argument error if name is not provided" do
      expect { Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id') }.to raise_error(ArgumentError, 'Missing required argument: name')
    end
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::Ec2.new() }.to raise_error(ArgumentError, 'Missing required argument: name,key_name,image_id')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'name', :instance_type => 't1.micro') }.to_not raise_error
    end
  end
  describe '#template' do
    it "should return a ruby hash for the resource cloudformation template" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'name', :instance_type => 't1.micro', :security_groups => ["testSecurityGroup1", "testSecurityGroup2"] )
      ec2.template.should == {'Resources' => {'name' => {'Type' => 'AWS::EC2::Instance', 'Properties' => {"KeyName" => 'testkey', "ImageId" => 'image_id', "InstanceType" => 't1.micro', "SecurityGroups" => ["testSecurityGroup1", "testSecurityGroup2"]} }}}
      puts ec2.template.to_json
    end
  end
  describe '.template' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::Ec2.template() }.to raise_error(ArgumentError, 'Missing required argument: name,key_name,image_id')
    end
    it "should return a ruby hash for the resource cloudformation template" do
      hash = Cloudster::Ec2.template(:key_name => 'testkey', :image_id => 'image_id', :name => 'name', :instance_type => 't1.micro', :security_groups => ["testSecurityGroup1"])
      hash.should == {'Resources' => {'name' => {'Type' => 'AWS::EC2::Instance', 'Properties' => {"KeyName" => 'testkey', "ImageId" => 'image_id', "InstanceType" => 't1.micro', "SecurityGroups" => ["testSecurityGroup1"]} }}}
    end
  end
end
