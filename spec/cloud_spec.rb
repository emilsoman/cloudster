require 'spec_helper'

describe Cloudster::Cloud do
  describe 'initialize' do
    it "should raise argument error if resources not provided" do
      expect { Cloudster::Cloud.new() }.to raise_error(ArgumentError, 'Missing required argument: access_key_id,secret_access_key')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test') }.to_not raise_error
    end
  end
  describe '#template' do
    it "should return a ruby hash for the stack cloudformation template" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      ec2_1 = Cloudster::Ec2.new(:key_name => 'testkey1', :image_id => 'image_id1', name: 'name1')
      rds = Cloudster::Rds.new(:name => 'MySqlDB', :storage_size => '10') 
      elb = Cloudster::Elb.new(:name => 'ELB', :instance_names => ['name','name1'])
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud.template(:resources => [ec2, ec2_1, rds, elb], :description => 'test template').should == {"AWSTemplateFormatVersion"=>"2010-09-09", 
        "Description"=>"test template",
        "Resources"=>{
          "name"=>{
            "Type"=>"AWS::EC2::Instance",
            "Properties"=>{
              "KeyName"=>"testkey",
              "ImageId"=>"image_id"}
            },
           "name1"=>{
             "Type"=>"AWS::EC2::Instance",
             "Properties"=>{
                "KeyName"=>"testkey1", 
                "ImageId"=>"image_id1"
                 }
            },
            'MySqlDB' => {
              "Type" => "AWS::RDS::DBInstance",
              "Properties" => {
                "Engine" => 'MySQL',
                "MasterUsername" => 'root',
                "MasterUserPassword" => 'root',
                "DBInstanceClass" => 'db.t1.micro',
                "AllocatedStorage" => '10'
              }
            },
           "ELB" => {
              "Type" => "AWS::ElasticLoadBalancing::LoadBalancer",
              "Properties" => {
                "AvailabilityZones" => {
                  "Fn::GetAZs" => ""
                 },
                "Listeners" => [{
                  "LoadBalancerPort" => "80",
                  "InstancePort" => "80",
                  "Protocol" => "HTTP"
                 }],
               "HealthCheck" => {
                 "Target" => {
                   "Fn::Join" => ["",["HTTP:","80","/"]]
                  },
                 "HealthyThreshold" => "3",
                 "UnhealthyThreshold" => "5",
                 "Interval" => "30", "Timeout" => "5" 
               },
               "Instances" => [{ "Ref" => "name"}, {"Ref" => "name1"}]}
            }
          }
      }.to_json
    end
  end

  describe '#provision' do
    it "should raise argument error if resources not provided" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      expect { cloud.provision(:description => 'test') }.to raise_error(ArgumentError, 'Missing required argument: resources,stack_name' )
    end
    it "should trigger stack creation" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test').and_return cloud_formation
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      elb = Cloudster::Elb.new(:name => 'ELB', :instance_names => ['name','name1'])
      rds = Cloudster::Rds.new(:name => 'MySqlDB', :storage_size => '10') 
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('create_stack').with('stack_name', 'TemplateBody' => cloud.template(:resources => [ec2, elb, rds], :description => 'testDescription'))
      cloud.provision(:resources => [ec2, elb, rds], :stack_name => 'stack_name', :description => 'testDescription')
    end
  end

  describe '#update' do
    it "should raise argument error if resources not provided" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      expect { cloud.update(:description => 'test') }.to raise_error(ArgumentError, 'Missing required argument: resources,stack_name' )
    end
    it "should trigger stack update" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test').and_return cloud_formation
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', name: 'name')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('update_stack').with('stack_name', 'TemplateBody' => cloud.template(:resources => [ec2], :description => 'testDescription'))
      cloud.update(:resources => [ec2], :stack_name => 'stack_name', :description => 'testDescription')
    end
  end

  describe '#events' do
    it "should trigger 'describe stack events' request" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test').and_return cloud_formation
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('describe_stack_events').with('stack_name')
      cloud.events(:stack_name => 'stack_name')
    end
  end

  describe '#delete' do
    it "should raise argument error if resources not provided" do
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      expect { cloud.delete() }.to raise_error(ArgumentError, 'Missing required argument: stack_name')
    end
    it "should trigger 'delete stack' request" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test').and_return cloud_formation
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('delete_stack').with('stack_name')
      cloud.delete(:stack_name => 'stack_name')
    end
  end
end
