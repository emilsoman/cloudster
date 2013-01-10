require 'spec_helper'

describe Cloudster::Output do
  class Resource;end
  Resource.extend(Cloudster::Output)

  describe "output_template" do
    it "should return the cloudformation template for the Outputs" do
      resource_name = "S3ResourceName"
      outputs = {
        resource_name => {
          'bucket_name' => {"Ref" => resource_name },
          'dns_name' => {'Fn::GetAtt' => [resource_name, 'DomainName']}
        }
      }
      class Resource;end
      Resource.extend(Cloudster::Output)
      Resource.output_template(outputs).should include({
        resource_name => {
          "Value" => {
            "Fn::Join" => [ ",",[
              {"Fn::Join" => ["|", ['bucket_name', {"Ref" => resource_name } ] ]},
              {"Fn::Join" => ["|", ['dns_name', {'Fn::GetAtt' => [resource_name, 'DomainName']} ] ]}
            ]]
          }
        }
      })
    end
  end

  describe "parse_outputs" do
    it "should return a hash of outputs" do
      outputs = "bucket_name|teststack3-testbucket1,dns_name|teststack3-testbucket1.s3.amazonaws.com,website_url|http://teststack3-testbucket1.s3-website-us-east-1.amazonaws.com"
      class Resource;end
      Resource.extend(Cloudster::Output)
      Resource.parse_outputs(outputs).should == {
        "bucket_name" => "teststack3-testbucket1",
        "dns_name" => "teststack3-testbucket1.s3.amazonaws.com",
        "website_url" => "http://teststack3-testbucket1.s3-website-us-east-1.amazonaws.com"
      }
    end
  end

end
