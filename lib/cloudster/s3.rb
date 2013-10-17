module Cloudster
  #S3 Resource
  #Output values : bucket_name, dns_name, website_url
  class S3
    extend Cloudster::Output

    attr_accessor :name, :template
    # Initialize a s3 bucket
    #
    # ==== Notes
    # options parameter must include values for the :name
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :name : String representing the resource name (Required)
    #   * :access_control : String consisting of one of the predefined permission values: Private | PublicRead | PublicReadWrite | AuthenticatedRead | BucketOwnerRead | BucketOwnerFullControl
    #   * :website_configuration : A hash containing the name of the index document and name of the error document. ( Example: {:index_document => "index.html", :error_document => "error.html"} )
    #
    # ==== Examples
    #   bucket = Cloudster::S3.new(
    #    :name => 'ResourceName',
    #    :access_control => 'PublicRead'
    #   )

    def initialize(options = {})
      require_options(options, [:name])
      @name = options[:name]
      @access_control = options[:access_control]
      @website_configuration = options[:website_configuration]
    end

    # Returns a Ruby hash version of the Cloud Formation template for the s3 resource
    #
    # ==== Examples
    #   s3 = Cloudster::S3.new(
    #    :name => 'S3Resource'
    #   )
    #   s3.template
    #
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template for the s3 resource
    def template
      @template ||= S3.template({
        :name => @name,
        :access_control => @access_control,
        :website_configuration => @website_configuration
      })
    end

    # Class method that returns a Ruby hash version of the Cloud Formation template
    #
    # ==== Examples
    #   template = Cloudster::S3.template(
    #     :name => 'S3Resource'
    #   )
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :name : String representing the resource name (Required)
    #   * :access_control : String consisting of one of the predefined permission value. ( Example: PublicRead )
    #   * :website_configuration : A hash containing the name of the index document and name of the error document. ( Example: {:index_document => "index.html", :error_document => "error.html"} )
    #
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template for S3
    def self.template(options = {})
      require_options(options, [:name])
      properties = {}
      properties.merge!({"AccessControl" => options[:access_control]}) unless options[:access_control].nil?
      unless options[:website_configuration].nil?
        properties.merge!({"WebsiteConfiguration" => {"IndexDocument" => options[:website_configuration][:index_document], "ErrorDocument" => options[:website_configuration][:error_document]}})
      end
      template = {
        'Resources' => {
          options[:name] => {
            'Type' => 'AWS::S3::Bucket',
            'Properties' => properties
          }
        }
      }
      outputs = {
        options[:name] => {
          'bucket_name' => { 'Ref' => options[:name] },
          'dns_name' => {'Fn::GetAtt' => [options[:name], 'DomainName']},
          'website_url' => {'Fn::GetAtt' => [options[:name], 'WebsiteURL']}
        }
      }
      template['Outputs'] = output_template(outputs)
      return template
    end
  end
end
