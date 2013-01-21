require 'spec_helper'

describe Cloudster::Elb do
  describe 'initialize' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::Elb.new() }.to raise_error(ArgumentError, 'Missing required argument: name,instance_names')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::Elb.new(:name => 'LoadBalancer', :instance_names => ['AppServer', 'AppServer2']) }.to_not raise_error
    end
  end
  describe '#template with default listener' do
    it "should return a ruby hash for the resource cloudformation template with default listener" do
      elb = Cloudster::Elb.new(:name => 'LoadBalancer', :instance_names => ['AppServer', 'AppServer2']) 
      elb.template.should == {
        "Resources" => {
          "LoadBalancer"=>{
            "Type"=>"AWS::ElasticLoadBalancing::LoadBalancer",
            "Properties"=>{
              "AvailabilityZones"=>{
                "Fn::GetAZs"=>""
              },
              "Listeners"=>[
                {
                  "LoadBalancerPort"=>"80",
                  "InstancePort"=>"80",
                  "Protocol"=>"HTTP"
                }
              ],
              "HealthCheck"=>{
                "Target"=>{
                  "Fn::Join"=>["", ["HTTP:", "80", "/"]]
                },
                "HealthyThreshold"=>"3",
                "UnhealthyThreshold"=>"5",
                "Interval"=>"30",
                "Timeout"=>"5"
              },
              "Instances"=>[{"Ref"=>"AppServer"}, {"Ref"=>"AppServer2"}]
            }
          }
        },
        "Outputs" => {
          "LoadBalancer"=>{
            "Value"=>{
              "Fn::Join"=>[",",
                [
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name", {'Fn::GetAtt' => ['LoadBalancer', 'CanonicalHostedZoneName']}]]},
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name_id", {'Fn::GetAtt' => ['LoadBalancer', 'CanonicalHostedZoneNameID']}]]},
                    {"Fn::Join" => ["|", ["dns_name", {'Fn::GetAtt' => ['LoadBalancer', 'DNSName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_name", {'Fn::GetAtt' => ['LoadBalancer', 'SourceSecurityGroup.GroupName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_owner", {'Fn::GetAtt' => ['LoadBalancer', 'SourceSecurityGroup.OwnerAlias']}]]}
                ]
              ]
            }
          }
        }
      }
    end
  end
  describe '#template with custom listener' do
    it "should return a ruby hash for the resource cloudformation template with the custom listener" do
      elb = Cloudster::Elb.new(:name => 'LoadBalancer', :instance_names => ['AppServer', 'AppServer2'], :listeners => [{:port => 80, :instance_port => 3333, :protocol => 'HTTP'}])
      elb.template.should == {
        "Resources" => {
          "LoadBalancer"=>{
            "Type"=>"AWS::ElasticLoadBalancing::LoadBalancer",
            "Properties"=>{
              "AvailabilityZones"=>{
                "Fn::GetAZs"=>""
              },
              "Listeners"=>[
                {
                  "LoadBalancerPort"=>"80",
                  "InstancePort"=>"3333",
                  "Protocol"=>"HTTP"
                }
              ],
              "HealthCheck"=>{
                "Target"=>{
                  "Fn::Join"=>["", ["HTTP:", "80", "/"]]
                },
                "HealthyThreshold"=>"3",
                "UnhealthyThreshold"=>"5",
                "Interval"=>"30",
                "Timeout"=>"5"
              },
              "Instances"=>[{"Ref"=>"AppServer"}, {"Ref"=>"AppServer2"}]
            }
          }
        },
        "Outputs" => {
          "LoadBalancer"=>{
            "Value"=>{
              "Fn::Join"=>[",",
                [
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name", {'Fn::GetAtt' => ['LoadBalancer', 'CanonicalHostedZoneName']}]]},
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name_id", {'Fn::GetAtt' => ['LoadBalancer', 'CanonicalHostedZoneNameID']}]]},
                    {"Fn::Join" => ["|", ["dns_name", {'Fn::GetAtt' => ['LoadBalancer', 'DNSName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_name", {'Fn::GetAtt' => ['LoadBalancer', 'SourceSecurityGroup.GroupName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_owner", {'Fn::GetAtt' => ['LoadBalancer', 'SourceSecurityGroup.OwnerAlias']}]]}
                ]
              ]
            }
          }
        }
      }
    end
  end
  describe '.template' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::Elb.template() }.to raise_error(ArgumentError, 'Missing required argument: name,instance_names')
    end
    it "should return a ruby hash for the resource cloudformation template" do
      hash = Cloudster::Elb.template(:name => 'LoadBalancer', :instance_names => ['AppServer', 'AppServer2'])
      hash.should == {
        "Resources" => {
          "LoadBalancer"=>{
            "Type"=>"AWS::ElasticLoadBalancing::LoadBalancer",
            "Properties"=>{
              "AvailabilityZones"=>{
                "Fn::GetAZs"=>""
              },
              "Listeners"=>[
                {
                  "LoadBalancerPort"=>"80",
                  "InstancePort"=>"80",
                  "Protocol"=>"HTTP"
                }
              ],
              "HealthCheck"=>{
                "Target"=>{
                  "Fn::Join"=>["", ["HTTP:", "80", "/"]]
                },
                "HealthyThreshold"=>"3",
                "UnhealthyThreshold"=>"5",
                "Interval"=>"30",
                "Timeout"=>"5"
              },
              "Instances"=>[{"Ref"=>"AppServer"}, {"Ref"=>"AppServer2"}]
            }
          }
        },
        "Outputs" => {
          "LoadBalancer"=>{
            "Value"=>{
              "Fn::Join"=>[",",
                [
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name", {'Fn::GetAtt' => ['LoadBalancer', 'CanonicalHostedZoneName']}]]},
                    {"Fn::Join" => ["|", ["canonical_hosted_zone_name_id", {'Fn::GetAtt' => ['LoadBalancer', 'CanonicalHostedZoneNameID']}]]},
                    {"Fn::Join" => ["|", ["dns_name", {'Fn::GetAtt' => ['LoadBalancer', 'DNSName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_name", {'Fn::GetAtt' => ['LoadBalancer', 'SourceSecurityGroup.GroupName']}]]},
                    {"Fn::Join" => ["|", ["source_security_group_owner", {'Fn::GetAtt' => ['LoadBalancer', 'SourceSecurityGroup.OwnerAlias']}]]}
                ]
              ]
            }
          }
        }
      }
    end
  end
end
