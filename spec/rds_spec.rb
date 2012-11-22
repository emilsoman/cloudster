require 'spec_helper'

describe Cloudster::Rds do
  describe 'initialize' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::Rds.new() }.to raise_error(ArgumentError, 'Missing required argument: name,storage_size')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::Rds.new(:name => 'MySqlDB', :storage_size => '10') }.to_not raise_error
    end
  end
  describe '#template' do
    it "should return a ruby hash for the resource cloudformation template" do
      rds = Cloudster::Rds.new(:name => 'MySqlDB', :storage_size => '10', :multi_az => true) 
      template = {'Resources' => { 
                    'MySqlDB' => {
                      "Type" => "AWS::RDS::DBInstance",
                      "Properties" => {
                        "Engine" => 'MySQL',
                        "MasterUsername" => 'root',
                        "MasterUserPassword" => 'root',
                        "DBInstanceClass" => 'db.t1.micro',
                        "AllocatedStorage" => '10',
                        "MultiAZ" => true
                      }
                    }
                  }
      }
      rds.template.should == template 
    end
  end
  describe '.template' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::Rds.template() }.to raise_error(ArgumentError, 'Missing required argument: name,storage_size')
    end
    it "should return a ruby hash for the resource cloudformation template" do
      hash = Cloudster::Rds.template(:name => 'MySqlDB', :storage_size => '10')
      template = {'Resources' => { 
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
                    }
                  }
      }
      hash.should == template 
    end
  end
end
