module Cloudster
  #==CloudFront resource
  #Output values : domain_name
  class CloudFront
    include Cloudster::Output

    # Initialize CloudFront
    #
    # ==== Notes
    # options parameter must include values for :name
    #
    # ==== Examples
    #   cloud_front = Cloudster::CloudFront.new(:name => 'CloudFront')
    #
    # ==== Parameters
    # * options<~Hash> -
    #     * :name: String containing the name of CloudFront resource
    def initialize(options = {})
      require_options(options, [:name])
      @name = options[:name]
      @enabled = options[:enabled] || true
      @default_root_object = options[:default_root_object] || 'index.html'
      @aliases = options[:aliases] || []
    end

    # Merges the required CloudFormation template for adding an CloudFront to an s3 instance
    #
    #
    # ==== Examples
    #   cloud_front = Cloudster::CloudFront.new(:name => 'CloudFrontDistribution')
    #   s3 = Cloudster::S3.new(
    #    :name => 'S3Resource',
    #    :access_control => 'PublicRead'
    #   )
    #
    #   cloud_front.add_to s3
    #
    # ==== Parameters
    # * instance of s3
    def add_to(s3)
      s3_template = s3.template
      @instance_name = s3.name
      cloud_front_template = template
      s3.template.inner_merge(cloud_front_template)
    end

    private
      def template
        template = { "Resources" => {
            @name => {
                "Type" => "AWS::CloudFront::Distribution",
                "Properties" => {
                  "DistributionConfig"=> {
                    "Origins"=>[{
                      "DomainName"=> {"Fn::GetAtt" => [@instance_name, "DomainName"]},
                      "Id"=>@instance_name,
                      "S3OriginConfig"=> {}
                    }],
                    "DefaultRootObject" => @default_root_object,
                    "DefaultCacheBehavior" => {
                      "TargetOriginId" => @instance_name,
                      "ForwardedValues" => {
                        "QueryString" => "false"
                      },
                      "ViewerProtocolPolicy" => "allow-all"
                    },
                    "Aliases"=> @aliases,
                    "Enabled"=> @enabled.to_s
                  }
                }
            }
          }
        }
        outputs = {
          @name => {
            'domain_name' => {'Fn::GetAtt' => [@name, 'DomainName']},
            'distribution_id' => { "Ref" => @name }
          }
        }
        template['Outputs'] = output_template(outputs)
        return template

      end

  end
end
