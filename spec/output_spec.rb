require 'spec_helper'

describe Cloudster::Output do
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
      Resource.output_template(outputs).should == {
        resource_name => {
          "Value" => {
            "Fn::Join" => [ ",",[
              {"Fn::Join" => [":", ['bucket_name', {"Ref" => resource_name } ] ]},
              {"Fn::Join" => [":", ['dns_name', {'Fn::GetAtt' => [resource_name, 'DomainName']} ] ]}
            ]]
          }
        }
      }
    end
  end
end
