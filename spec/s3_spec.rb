require 'spec_helper'

describe Cloudster::S3 do
  describe 'initialize' do
    it "should raise argument error if no argument is provided" do
      expect { Cloudster::S3.new() }.to raise_error(ArgumentError, 'Missing required argument: name')
    end
    it "should not raise argument error if all arguments are provided" do
      expect { Cloudster::S3.new(:name => 'mybucket') }.to_not raise_error
    end
  end

  describe '#template' do
    it "should return a ruby hash for the resource cloudformation template with only mandatory fields" do
      s3 = Cloudster::S3.new(:name => 'bucket_name')
      s3.template.should == {
        'Resources' => {'bucket_name' => {'Type' => 'AWS::S3::Bucket', 'Properties' => {}}},
        "Outputs" => {"bucket_name"=>{"Value"=>{"Fn::Join"=>[",", [{"Fn::Join"=>[":", ["bucket_name", {"Ref"=>"bucket_name"}]]}, {"Fn::Join"=>[":", ["dns_name", {"Fn::GetAtt"=>["bucket_name", "DomainName"]}]]}, {"Fn::Join"=>[":", ["website_url", {"Fn::GetAtt"=>["bucket_name", "WebsiteURL"]}]]}]]}}}
      }
    end
    it "should return a ruby hash for the resource cloudformation template" do
      s3 = Cloudster::S3.new(:name => 'bucket_name', :access_control => "PublicRead", :website_configuration => {"index_document" => "index.html", "error_document" => "error.html"} )
      s3.template.should == {
        'Resources' => {'bucket_name' => {'Type' => 'AWS::S3::Bucket', 'Properties' => {"AccessControl" => "PublicRead", "WebsiteConfiguration" => { "IndexDocument" => "index.html", "ErrorDocument" => "error.html" } }}},
        "Outputs" => {"bucket_name"=>{"Value"=>{"Fn::Join"=>[",", [{"Fn::Join"=>[":", ["bucket_name", {"Ref"=>"bucket_name"}]]}, {"Fn::Join"=>[":", ["dns_name", {"Fn::GetAtt"=>["bucket_name", "DomainName"]}]]}, {"Fn::Join"=>[":", ["website_url", {"Fn::GetAtt"=>["bucket_name", "WebsiteURL"]}]]}]]}}}
      }
    end
  end

  describe '.template' do
    it "should raise argument error if no argument is provided" do
      expect { Cloudster::S3.template() }.to raise_error(ArgumentError, 'Missing required argument: name')
    end
    it "should return a ruby hash for the resource cloudformation template" do
      hash = Cloudster::S3.template(:name => 'bucket_name', :access_control => "PublicRead", :website_configuration => {"index_document" => "index.html", "error_document" => "error.html"} )
      hash.should == {
        'Resources' => {'bucket_name' => {'Type' => 'AWS::S3::Bucket', 'Properties' => {"AccessControl" => "PublicRead", "WebsiteConfiguration" => { "IndexDocument" => "index.html", "ErrorDocument" => "error.html" } }}},
        "Outputs" => {"bucket_name"=>{"Value"=>{"Fn::Join"=>[",", [{"Fn::Join"=>[":", ["bucket_name", {"Ref"=>"bucket_name"}]]}, {"Fn::Join"=>[":", ["dns_name", {"Fn::GetAtt"=>["bucket_name", "DomainName"]}]]}, {"Fn::Join"=>[":", ["website_url", {"Fn::GetAtt"=>["bucket_name", "WebsiteURL"]}]]}]]}}}
      }
    end
  end

end
