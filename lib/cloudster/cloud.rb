module Cloudster
  #Cloud objects have many resources. This class can generate the cloudformation template and provision the stack.
  class Cloud

    # Initialize a Cloud instance
    #
    # ==== Notes
    # options parameter must include values for :access_key_id and
    # :secret_access_key in order to create a connection
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :access_key_id : A string containing the AWS access key ID.
    #   * :secret_access_key : A string containing the AWS secret access key.
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    def initialize(options = {})
      require_options(options, [:access_key_id, :secret_access_key])
      access_key_id = options[:access_key_id]
      secret_access_key = options[:secret_access_key]
      @cloud_formation = Fog::AWS::CloudFormation.new(:aws_access_key_id => access_key_id, :aws_secret_access_key => secret_access_key)
    end

    # Generates CloudFormation Template for the stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #
    #   cloud.template(:resources => [<AWS RESOURCES ARRAY>], :description => 'This is the description for the stack template')
    #
    # ==== Notes
    # options parameter must include values for :resources
    #
    # ==== Parameters
    # * options<~Hash> - 
    #   * :resources : An array of Cloudster resource instances.  Defaults to {}.
    #   * :description : A string which will be used as the Description of the CloudFormation template.
    #
    # ==== Returns
    # * JSON cloud formation template 
    def template(options = {})
      require_options(options, [:resources])
      resources = options[:resources]
      description = options[:description] || 'This stack is created by Cloudster'
      resource_template = {}
      resources.each do |resource|
        resource_template.merge!(resource.template['Resources'])
      end

      cloud_template = {'AWSTemplateFormatVersion' => '2010-09-09',
                  'Description' => description,
                  'Resources' => resource_template
      }
      return cloud_template.to_json
    end

    # Triggers the stack creation
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #
    #   cloud.provision(:resources => [<AWS RESOURCES ARRRAY>],
    #     :stack_name => 'Shitty Stack',
    #     :description => 'This is the description for the stack template')
    #
    # ==== Notes
    # options parameter must include values for :resources and :stack_name
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :resources : An array of Cloudster resource instances.  Defaults to {}.
    #   * :stack_name : A string which will be used to name the CloudFormation stack.
    #   * :description : A string which will be used as the Description of the CloudFormation template.
    #
    # ==== Returns
    # * response<~Excon::Response>:
    #   * body<~Hash>:
    #     * 'StackId'<~String> - Id of the new stack
    def provision(options = {})
      require_options(options, [:resources, :stack_name])
      return @cloud_formation.create_stack(options[:stack_name], 'TemplateBody' => template(:resources => options[:resources], 
                                                                                            :description => options[:description]))
    end

    # Get events related to a stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #   cloud.events(:stack_name => 'ShittyStack')
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :stack_name : A string which will contain the name of the stack for which the events will be fetched.
    #
    # ==== Returns
    # * response<~Excon::Response>:
    #   * body<~Hash>:
    def self.events(options = {})
      return @cloud_formation.describe_stack_events(options[:stack_name])
    end

  end
end
