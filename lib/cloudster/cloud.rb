module Cloudster
  #Cloud objects have many resources. This class can generate the cloudformation template and provision the stack.
  class Cloud

    # Initialize a Cloud instance
    #
    # ==== Notes
    # options parameter must include values for :resources
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :resources => [
    #       #Cloudster resource instances ..
    #     ]
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - :resources : An array of Cloudster resource instances.  Defaults to {}.
    def initialize(options = {})
      require_options(options, [:resources])
      @resources = options[:resources]
    end

    # Generates CloudFormation Template for the stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :resources => [
    #       #Cloudster resource instances ..
    #     ]
    #   )
    #   cloud.template(:description => 'This is the description for the stack template')
    #
    # ==== Parameters
    # * options<~Hash> - :description : A string which will be used as the Description of the CloudFormation template.
    #
    # ==== Returns
    # * JSON cloud formation template 
    def template(options = {})
      description = options[:description] || 'This stack is created by Cloudster'
      resource_template = {}
      @resources.each do |resource|
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
    #    :resources => [
    #       #Cloudster resource instances ..
    #     ]
    #   )
    #   cloud.template(:description => 'This is the description for the stack template')
    #
    # ==== Notes
    # options parameter must include values for :stack_name for naming the stack , :access_key_id and
    # :secret_access_key in order to create a connection
    #
    # ==== Parameters
    # * options<~Hash> - :description : A string which will be used as the Description of the CloudFormation template.
    #
    # ==== Returns
    # * response<~Excon::Response>:
    #   * body<~Hash>:
    #     * 'StackId'<~String> - Id of the new stack
    def provision(options = {})
      require_options(options, [:stack_name, :access_key_id, :secret_access_key])
      cloud_formation = Fog::AWS::CloudFormation.new(:aws_access_key_id => options[:access_key_id], :aws_secret_access_key => options[:secret_access_key])
      return cloud_formation.create_stack(options[:stack_name], 'TemplateBody' => template)
    end

  end
end
