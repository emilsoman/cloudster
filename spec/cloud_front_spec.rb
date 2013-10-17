require 'spec_helper'

describe Cloudster::ChefClient do
  describe 'initialize' do
    it "should raise argument error if no argument is not provided" do
      expect { Cloudster::CloudFront.new() }.to raise_error(ArgumentError, 'Missing required argument: name')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::CloudFront.new(:name => 'CloudFront') }.to_not raise_error
    end
  end
  describe '#add_to' do
    it "should add elastic ip configuration to ec2 template" do
      bucket = Cloudster::S3.new(:name => 'S3ResourceName',:access_control => 'PublicRead')
      cloud_front = Cloudster::CloudFront.new(:name => 'CloudFront',
                                              :default_root_object => 'index.html',
                                              :aliases => ['mysite.example.com', 'yoursite.example.com'],
                                              :enabled => true)
      cloud_front.add_to bucket
      bucket.template.should ==
        {
          "Resources"=>{
            "S3ResourceName"=>{
              "Type"=>"AWS::S3::Bucket",
              "Properties"=>{
                "AccessControl"=>"PublicRead"
              }
            },
            "CloudFront"=>{
              "Type"=>"AWS::CloudFront::Distribution",
              "Properties"=>{
                "DistributionConfig"=> {
                  "Origins"=>[{
                    "DomainName"=> {"Fn::GetAtt" => ["S3ResourceName", "DomainName"]},
                    "Id"=>"S3ResourceName",
                    "S3OriginConfig"=> {}
                  }],
                  "DefaultRootObject"=>"index.html",
                  "DefaultCacheBehavior" => {
                    "TargetOriginId" => "S3ResourceName",
                    "ForwardedValues" => {
                      "QueryString" => "false"
                    },
                    "ViewerProtocolPolicy" => "allow-all"
                  },
                  "Aliases"=>["mysite.example.com", "yoursite.example.com"],
                  "Enabled"=>"true"
                }
              }
            },
          },
          "Outputs" => {
            "S3ResourceName"=>{
              "Value"=>{
                "Fn::Join"=>[",",
                  [
                    {"Fn::Join"=>["|", ["bucket_name", {"Ref"=>"S3ResourceName"}]]},
                    {"Fn::Join"=>["|", ["dns_name", {"Fn::GetAtt"=>["S3ResourceName", "DomainName"]}]]},
                    {"Fn::Join"=>["|", ["website_url", {"Fn::GetAtt"=>["S3ResourceName", "WebsiteURL"]}]]}
                  ]
                ]
              }
            },
            "CloudFront"=>{
              "Value"=>{
                "Fn::Join"=>[",",
                  [
                    {"Fn::Join"=>["|", ["domain_name", {"Fn::GetAtt"=>["CloudFront", "DomainName"]}]]},
                    {"Fn::Join"=>["|", ["distribution_id", {"Ref"=>"CloudFront"}]]}
                  ]
                ]
              }
            }
          }
        }
    end
  end
end
