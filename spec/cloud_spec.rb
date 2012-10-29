require 'spec_helper'

describe Cloudster::Cloud do
  describe 'initialize' do
    it "should raise argument error if resources not provided" do
      expect { Cloudster::Cloud.new() }.to raise_error(ArgumentError, 'Missing required argument: resources')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::Cloud.new(:resources => []) }.to_not raise_error(ArgumentError, 'Missing required argument: name')
    end
  end
  describe '#template' do
    it "should return a ruby hash for the stack cloudformation template" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      ec2_1 = Cloudster::Ec2.new(:key_name => 'testkey1', :image_id => 'image_id1', name: 'name1')
      cloud = Cloudster::Cloud.new(:resources => [ec2, ec2_1])
      cloud.template(:description => 'test template').should == {"AWSTemplateFormatVersion"=>"2010-09-09", "Description"=>"test template", "Resources"=>{"name"=>{"Type"=>"AWS::EC2::Instance", "Properties"=>{"KeyName"=>"testkey", "ImageId"=>"image_id"}}, "name1"=>{"Type"=>"AWS::EC2::Instance", "Properties"=>{"KeyName"=>"testkey1", "ImageId"=>"image_id1"}}}}.to_json
    end
  end

  describe '#provision' do
    it "should raise argument error if resources not provided" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      cloud = Cloudster::Cloud.new(:resources => [ec2])
      expect { cloud.provision() }.to raise_error(ArgumentError, 'Missing required argument: stack_name,access_key_id,secret_access_key' )
    end
    it "should create an instance of cloud formation and trigger stack creation" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      cloud = Cloudster::Cloud.new(:resources => [ec2])
      cloud_formation = double('CloudFormation')
      cloud_formation.should_receive('create_stack').with('stack_name', 'TemplateBody' => cloud.template)
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'access_key_id', :aws_secret_access_key => 'secret_access_key').and_return cloud_formation
      cloud.provision(:stack_name => 'stack_name', :access_key_id => 'access_key_id',  :secret_access_key => 'secret_access_key')
    end
  end
end
