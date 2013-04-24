require 'spec_helper'

describe Cloudster::Cloud do
  describe 'initialize' do
    it "should raise argument error if resources not provided" do
      expect { Cloudster::Cloud.new() }.to raise_error(ArgumentError, 'Missing required argument: access_key_id,secret_access_key')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test', :region => 'us-east-1') }.to_not raise_error
    end
  end
  describe '#template' do
    it "should return a ruby hash for the stack cloudformation template" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'Ec2Instance1')
      ec2_1 = Cloudster::Ec2.new(:key_name => 'testkey1', :image_id => 'image_id1', :name => 'Ec2Instance2')
      rds = Cloudster::Rds.new(:name => 'MySqlDB', :storage_size => '10') 
      elb = Cloudster::Elb.new(:name => 'ELB', :instance_names => ['Ec2Instance1','Ec2Instance2'])
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud.template(:resources => [ec2, ec2_1, rds, elb], :description => 'test template').should == {"AWSTemplateFormatVersion"=>"2010-09-09", 
        "Description"=>"test template",
        "Resources"=>{
          "Ec2Instance1"=>{
            "Type"=>"AWS::EC2::Instance",
            "Properties"=>{
              "KeyName"=>"testkey",
              "ImageId"=>"image_id"}
            },
           "Ec2Instance2"=>{
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
                "AllocatedStorage" => '10',
                "MultiAZ" => false
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
               "Instances" => [{ "Ref" => "Ec2Instance1"}, {"Ref" => "Ec2Instance2"}]}
            }
          },
          "Outputs" => {
            "Ec2Instance1"=> {
              "Value" => {
                "Fn::Join" => ["," ,
                  [
                    {"Fn::Join" => ["|", ["availablity_zone", {'Fn::GetAtt' => ['Ec2Instance1', 'AvailabilityZone']}]]},
                    {"Fn::Join" => ["|", ["private_dns_name", {'Fn::GetAtt' => ['Ec2Instance1', 'PrivateDnsName']}]]},
                    {"Fn::Join" => ["|", ["public_dns_name", {'Fn::GetAtt' => ['Ec2Instance1', 'PublicDnsName']}]]},
                    {"Fn::Join" => ["|", ["private_ip", {'Fn::GetAtt' => ['Ec2Instance1', 'PrivateIp']}]]},
                    {"Fn::Join" => ["|", ["public_ip", {'Fn::GetAtt' => ['Ec2Instance1', 'PublicIp']}]]},
		     {"Fn::Join"=>["|", ["instance_id", {"Ref"=> "Ec2Instance1"}]]}
                  ]
                ]
              }
            },
            "Ec2Instance2"=> {
              "Value" => {
                "Fn::Join" => ["," ,
                  [
                    {"Fn::Join" => ["|", ["availablity_zone", {'Fn::GetAtt' => ['Ec2Instance2', 'AvailabilityZone']}]]},
                    {"Fn::Join" => ["|", ["private_dns_name", {'Fn::GetAtt' => ['Ec2Instance2', 'PrivateDnsName']}]]},
                    {"Fn::Join" => ["|", ["public_dns_name", {'Fn::GetAtt' => ['Ec2Instance2', 'PublicDnsName']}]]},
                    {"Fn::Join" => ["|", ["private_ip", {'Fn::GetAtt' => ['Ec2Instance2', 'PrivateIp']}]]},
                    {"Fn::Join" => ["|", ["public_ip", {'Fn::GetAtt' => ['Ec2Instance2', 'PublicIp']}]]},
		     {"Fn::Join"=>["|", ["instance_id", {"Ref"=> "Ec2Instance2"}]]}
                  ]
                ]
              }
            },
            "MySqlDB"=> {
              "Value" => {
                "Fn::Join" => ["," ,
                  [
                    {"Fn::Join" => ["|", ["endpoint_address", {'Fn::GetAtt' => ['MySqlDB', 'Endpoint.Address']}]]},
                    {"Fn::Join" => ["|", ["endpoint_port", {'Fn::GetAtt' => ['MySqlDB', 'Endpoint.Port']}]]}
                  ]
                ]
              }
            },
            "ELB"=> {
              "Value" => {
                "Fn::Join" => ["," ,
                  [
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name", {'Fn::GetAtt' => ['ELB', 'CanonicalHostedZoneName']}]]},
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name_id", {'Fn::GetAtt' => ['ELB', 'CanonicalHostedZoneNameID']}]]},
                    {"Fn::Join" => ["|", ["dns_name", {'Fn::GetAtt' => ['ELB', 'DNSName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_name", {'Fn::GetAtt' => ['ELB', 'SourceSecurityGroup.GroupName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_owner", {'Fn::GetAtt' => ['ELB', 'SourceSecurityGroup.OwnerAlias']}]]}
                  ]
                ]
              }
            }
          }
      }.to_json
    end
  end

  describe '#provision' do
    it "should raise argument error if resources not provided" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'Ec2Instance1')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      expect { cloud.provision(:description => 'test') }.to raise_error(ArgumentError, 'Missing required argument: resources,stack_name' )
    end
    it "should trigger stack creation" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test', :region => nil).and_return cloud_formation
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'Ec2Instance1')
      elb = Cloudster::Elb.new(:name => 'ELB', :instance_names => ['Ec2Instance1','Ec2Instance2'])
      rds = Cloudster::Rds.new(:name => 'MySqlDB', :storage_size => '10')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('create_stack').with('stack_name', 'TemplateBody' => cloud.template(:resources => [ec2, elb, rds], :description => 'testDescription'))
      cloud.provision(:resources => [ec2, elb, rds], :stack_name => 'stack_name', :description => 'testDescription')
    end
  end

  describe '#update' do
    it "should raise argument error if resources not provided" do
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'Ec2Instance1')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      expect { cloud.update(:description => 'test') }.to raise_error(ArgumentError, 'Missing required argument: resources,stack_name' )
    end
    it "should trigger stack update" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test', :region => nil).and_return cloud_formation
      ec2 = Cloudster::Ec2.new(:key_name => 'testkey', :image_id => 'image_id', :name => 'Ec2Instance1')
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('update_stack').with('stack_name', 'TemplateBody' => cloud.template(:resources => [ec2], :description => 'testDescription'))
      cloud.update(:resources => [ec2], :stack_name => 'stack_name', :description => 'testDescription')
    end
  end

  describe '#events' do
    it "should trigger 'describe stack events' request" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test', :region => nil).and_return cloud_formation
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
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test', :region => nil).and_return cloud_formation
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud_formation.should_receive('delete_stack').with('stack_name')
      cloud.delete(:stack_name => 'stack_name')
    end
  end

  describe '#outputs' do
    it "should raise argument error if resources not provided" do
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      expect { cloud.outputs() }.to raise_error(ArgumentError, 'Missing required argument: stack_name')
    end
    it "should trigger 'describe stack' request" do
      cloud_formation = double('CloudFormation')
      Fog::AWS::CloudFormation.should_receive(:new).with(:aws_access_key_id => 'test', :aws_secret_access_key => 'test', :region => nil).and_return cloud_formation
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      cloud.should_receive(:describe).with(:stack_name => 'stack_name').and_return ({
        "Outputs"=>[{
          "OutputValue"=>"bucket_name|teststack3-testbucket1,dns_name|teststack3-testbucket1.s3.amazonaws.com,website_url|http://teststack3-testbucket1.s3-website-us-east-1.amazonaws.com",
          "OutputKey"=>"TestBucket1"
        },{
          "OutputValue"=>"bucket_name|teststack3-testbucket2,dns_name|teststack3-testbucket2.s3.amazonaws.com,website_url|http://teststack3-testbucket2.s3-website-us-east-1.amazonaws.com",
          "OutputKey"=>"TestBucket2"
        }]
      })
      output_hash = cloud.outputs(:stack_name => 'stack_name')
      output_hash.should == ({
        "TestBucket1" => {
            "bucket_name" => "teststack3-testbucket1",
            "dns_name" => "teststack3-testbucket1.s3.amazonaws.com",
            "website_url" => "http://teststack3-testbucket1.s3-website-us-east-1.amazonaws.com"
        },
        "TestBucket2" => {
            "bucket_name" => "teststack3-testbucket2",
            "dns_name" => "teststack3-testbucket2.s3.amazonaws.com",
            "website_url" => "http://teststack3-testbucket2.s3-website-us-east-1.amazonaws.com"
        }
      })
    end
  end

  describe "#is_s3_bucket_name_available?" do
    it "should return true if bucket is available" do
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      s3 = double('S3')
      s3.should_receive(:get_bucket).and_raise(Excon::Errors.status_error({:expects => 200}, {:status => 404}))
      Fog::Storage::AWS.should_receive(:new).and_return(s3)
      cloud.is_s3_bucket_name_available?('test-bucket-name').should be_true
    end

    it "should return false if bucket access is forbidden" do
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      s3 = double('S3')
      s3.should_receive(:get_bucket).and_raise(Excon::Errors.status_error({:expects => 200}, {:status => 403}))
      Fog::Storage::AWS.should_receive(:new).and_return(s3)
      cloud.is_s3_bucket_name_available?('test-bucket-name').should be_false
    end

    it "should return false if bucket is already owned by user" do
      cloud = Cloudster::Cloud.new(:access_key_id => 'test', :secret_access_key => 'test')
      s3 = double('S3')
      s3.should_receive(:get_bucket).and_return({:status => 200})
      Fog::Storage::AWS.should_receive(:new).and_return(s3)
      cloud.is_s3_bucket_name_available?('test-bucket-name').should be_false
    end
  end

end
