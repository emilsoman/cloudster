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
      bucket = bucket = Cloudster::S3.new(:name => 'S3ResourceName',:access_control => 'PublicRead')
      cloud_front = Cloudster::CloudFront.new(:name => 'CloudFront')
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
                  "S3Origin" => {
                    "DNSName"=>{"Fn::GetAtt"=>["S3ResourceName", "DomainName"]}
                  },
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
                    {"Fn::Join"=>[":", ["bucket_name", {"Ref"=>"S3ResourceName"}]]},
                    {"Fn::Join"=>[":", ["dns_name", {"Fn::GetAtt"=>["S3ResourceName", "DomainName"]}]]},
                    {"Fn::Join"=>[":", ["website_url", {"Fn::GetAtt"=>["S3ResourceName", "WebsiteURL"]}]]}
                  ]
                ]
              }
            }
          }
        }
    end
  end
end
