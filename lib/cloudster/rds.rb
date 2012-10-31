module Cloudster
  #==Rds resource
  class Rds

    # Initialize an Rds instance
    #
    # ==== Notes
    # options parameter must include values for :name, :storage_size
    #
    # ==== Examples
    #   rds = Cloudster::Rds.new(
    #    :name => 'MySqlDB',
    #    :instance_class => 'db.t1.micro',
    #    :storage_class => '100',
    #    :username => 'admin',
    #    :password => 'admin123',
    #    :engine => 'MySQL'
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #   *Keys: 
    #     * :name: String containing the name for the Rds resource. Mandatory option.
    #     * :instance_class: String containing the name of the compute and memory capacity class of the DB instance. Default: 'db.t1.micro'
    #     * :storage_size: String containing the allocated storage size specified in gigabytes. Mandatory option.
    #     * :username: String containing the master username for the DB instance. Default: 'root'
    #     * :password: String containing the master password for the DB instance. Default: 'root'
    #     * :engine: String containing the name of the database engine to be used for this DB instance. Default: 'MySQL'
    #     Valid values : MySQL | oracle-se1 | oracle-se | oracle-ee | sqlserver-ee | sqlserver-se | sqlserver-ex | sqlserver-web
    def initialize(options = {})
      require_options(options, [:name, :storage_size])
      options[:username] ||= 'root'
      options[:password] ||= 'root'
      options[:engine] ||= 'MySQL'
      options[:instance_class] ||= 'db.t1.micro'
      @name = options[:name]
      @storage_size = options[:storage_size]
      @username = options[:username]
      @password = options[:password]
      @engine = options[:engine]
      @instance_class = options[:instance_class]
    end

    # Returns a Ruby hash version of the Cloud Formation template for the resource instance
    #
    # ==== Examples
    #   rds = Cloudster::Rds.new(
    #    :name => 'MySqlDB',
    #    :instance_class => 'db.t1.micro',
    #    :storage_class => '100',
    #    :username => 'admin',
    #    :password => 'admin123',
    #    :engine => 'MySQL'
    #   )
    #   rds.template
    #
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template for the resource instance
    def template
      Rds.template({:name =>@name, :instance_class => @instance_class, :storage_size => @storage_size, :username => @username, :password => @password, :engine => @engine})
    end

    # Class method that returns a Ruby hash version of the Cloud Formation template
    #
    # ==== Notes
    # options parameter must include values for :name, :storage_size
    #
    # ==== Examples
    #   template = Cloudster::Rds.template(
    #    :name => 'MySqlDB',
    #    :instance_class => 'db.t1.micro',
    #    :storage_class => '100',
    #    :username => 'admin',
    #    :password => 'admin123',
    #    :engine => 'MySQL'
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #   *Keys: 
    #     * :name: String containing the name for the Rds resource. Mandatory option.
    #     * :instance_class: String containing the name of the compute and memory capacity class of the DB instance. Default: 'db.t1.micro'
    #     * :storage_size: String containing the allocated storage size specified in gigabytes. Mandatory option.
    #     * :username: String containing the master username for the DB instance. Default: 'root'
    #     * :password: String containing the master password for the DB instance. Default: 'root'
    #     * :engine: String containing the name of the database engine to be used for this DB instance. Default: 'MySQL'
    #     Valid values : MySQL | oracle-se1 | oracle-se | oracle-ee | sqlserver-ee | sqlserver-se | sqlserver-ex | sqlserver-web
    #
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template
    def self.template(options = {})
      require_options(options, [:name, :storage_size])
      options[:username] ||= 'root'
      options[:password] ||= 'root'
      options[:engine] ||= 'MySQL'
      options[:instance_class] ||= 'db.t1.micro'
      template = {'Resources' => { 
                    options[:name] => {
                      "Type" => "AWS::RDS::DBInstance",
                      "Properties" => {
                        "Engine" => options[:engine],
                        "MasterUsername" => options[:username],
                        "MasterUserPassword" => options[:password],
                        "DBInstanceClass" => options[:instance_class],
                        "AllocatedStorage" => options[:storage_size]
                      }
                    }
                  }
      }
      return template 
    end

  end
end
