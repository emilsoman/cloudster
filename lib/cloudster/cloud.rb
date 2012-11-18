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
      @access_key_id = options[:access_key_id]
      @secret_access_key = options[:secret_access_key]
      @cloud_formation = Fog::AWS::CloudFormation.new(:aws_access_key_id => @access_key_id, :aws_secret_access_key => @secret_access_key)
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

    # Updates already created stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #
    #   cloud.update(:resources => [<AWS RESOURCES ARRRAY>],
    #     :stack_name => 'Shitty Stack',
    #     :description => 'This is the description for the stack template')
    #
    # ==== Notes
    # options parameter must include values for :resources and :stack_name
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :resources : An array of Cloudster resource instances.  Defaults to {}.
    #   * :stack_name : A string which is the name of the CloudFormation stack which will be updated.
    #   * :description : A string which will be used as the Description of the CloudFormation template.
    #
    # ==== Returns
    # * response<~Excon::Response>:
    #   * body<~Hash>:
    #     * 'StackId'<~String> - Id of the new stack
    def update(options = {})
      require_options(options, [:resources, :stack_name])
      return @cloud_formation.update_stack(options[:stack_name], 'TemplateBody' => template(:resources => options[:resources], 
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
    def events(options = {})
      return @cloud_formation.describe_stack_events(options[:stack_name])
    end

    # Deletes a stack and the attached resources
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #   cloud.delete(:stack_name => 'ShittyStack')
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :stack_name : A string which will contain the name of the stack for which will be deleted
    #
    # ==== Returns
    # * response<~Excon::Response>:
    #   * body<~Hash>:
    def delete(options = {})
      require_options(options, [:stack_name])
      return @cloud_formation.delete_stack(options[:stack_name])
    end

    # Returns all RDS(database) endpoints in a stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #   cloud.get_database_endpoints(:stack_name => 'ShittyStack')
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :stack_name : A string which will contain the name of the stack
    #
    # ==== Returns
    # * Array of hashes, example: [{:address => 'simcoprod01.cu7u2t4uz396.us-east-1.rds.amazonaws.com', :port => '3306'}]
    def get_database_endpoints(options = {})
      rds_physical_ids = get_rds_resource_ids(resources(options))
      return [] if rds_physical_ids.empty?
      rds = Fog::AWS::RDS.new(:aws_access_key_id => @access_key_id, :aws_secret_access_key => @secret_access_key)
      endpoints = []
      rds_physical_ids.each do |rds_physical_id|
        endpoint = rds.describe_db_instances(rds_physical_id).body["DescribeDBInstancesResult"]["DBInstances"][0]["Endpoint"] rescue nil
        endpoints << {:address => endpoint["Address"], :port => endpoint["Port"]} unless endpoint.nil?
      end
      return endpoints
    end

    # Returns an array containing a list of Resources in a stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #   cloud.resources(:stack_name => 'RDSStack')
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :stack_name : A string which will contain the name of the stack
    #
    # ==== Returns
    # * Array of hashes, example: [{"Timestamp"=>2012-11-16 14:31:55 UTC, "ResourceStatus"=>"CREATE_COMPLETE", "StackId"=>"arn:aws::asd", "LogicalResourceId"=>"TestDB", "StackName"=>"RDSStack", "PhysicalResourceId"=>"rtad", "ResourceType"=>"AWS::RDS::DBInstance"}]
    def resources(options = {})
      require_options(options, [:stack_name])
      return @cloud_formation.describe_stack_resources('StackName' => options[:stack_name]).body["StackResources"] rescue []
    end

    # Describes the attributes of a Stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #   cloud.describe(:stack_name => 'RDSStack')
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :stack_name : A string which will contain the name of the stack
    #
    # ==== Returns
    # * Hash containing description of the stack
    def describe(options = {})
      require_options(options, [:stack_name])
      return @cloud_formation.describe_stacks('StackName' => options[:stack_name]).body["Stacks"][0] rescue nil
    end

    # Returns the status of the stack
    #
    # ==== Examples
    #   cloud = Cloudster::Cloud.new(
    #    :access_key_id => 'aws_access_key_id'
    #    :secret_access_key => 'aws_secret_access_key',
    #   )
    #   cloud.status(:stack_name => 'RDSStack')
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :stack_name : A string which will contain the name of the stack
    #
    # ==== Returns
    # * One of these strings :
    #   * CREATE_IN_PROGRESS
    #   * CREATE_FAILED
    #   * CREATE_COMPLETE
    #   * ROLLBACK_IN_PROGRESS
    #   * ROLLBACK_FAILED
    #   * ROLLBACK_COMPLETE
    #   * DELETE_IN_PROGRESS
    #   * DELETE_FAILED
    def status(options = {})
      require_options(options, [:stack_name])
      description = describe(options)
      return description["StackStatus"] rescue nil
    end

    private
      #Returns an array containing the Physical Resource Id's of RDS resources
      def get_rds_resource_ids(resources)
        rds_physical_ids = []
        resources.each do |resource|
          rds_physical_ids << resource["PhysicalResourceId"] if resource["ResourceType"] == "AWS::RDS::DBInstance"
        end
        return rds_physical_ids
      end

  end
end
