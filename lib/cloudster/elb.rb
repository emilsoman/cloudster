module Cloudster
  #==Elb resource
  class Elb

    # Initialize an Elb instance
    #
    # ==== Notes
    # options parameter must include values for :name, :instance_names
    #
    # ==== Examples
    #   elb = Cloudster::Elb.new(
    #    :name => 'LoadBalancer',
    #    :instance_names => ['AppServer1','AppServer2'],
    #    :listeners => [{:port => 80, :instance_port => 8080, :protocol => 'HTTP'}]
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #     * :name: String containing the name for the Elb resource
    #     * :instance_names: Array containing the names of the Ec2 resources which will be added under the ELB
    #     * :listeners: Array of listener hashes. Each listener must be registered for a specific port, and you can not have more than one listener for a given port. Default : {:port => 80, :instance_port => 80, :protocol => 'HTTP'}
    def initialize(options = {})
      require_options(options, [:name, :instance_names])
      @name = options[:name]
      @instance_names = options[:instance_names]
      @listeners = options[:listeners] || [{:port => 80, :instance_port => 80, :protocol => 'HTTP'}]
    end

    # Returns a Ruby hash version of the Cloud Formation template for the resource instance
    #
    # ==== Examples
    #   elb = Cloudster::Elb.new(
    #    :name => 'LoadBalancer',
    #    :instance_names => ['AppServer1','AppServer2']
    #   )
    #   elb.template
    #
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template for the resource instance
    def template
      Elb.template({:name =>@name, :instance_names => @instance_names, :listeners => @listeners})
    end

    # Class method that returns a Ruby hash version of the Cloud Formation template
    #
    # ==== Examples
    #   template = Cloudster::Elb.template(
    #    :name => 'LoadBalances',
    #    :instance_names => ['AppServer1', 'AppServer2'],
    #    :listeners => [{:port => 80, :instance_port => 80, :protocol => 'HTTP'}]
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #   *Keys: 
    #     * :name: String containing the name for the Elb resource
    #     * :instance_names: Array containing the names of the Ec2 resources which will be added under the ELB
    #     * :listeners: Array of listener hashes. Each listener must be registered for a specific port, and you can not have more than one listener for a given port. Default : {:port => 80, :instance_port => 80, :protocol => 'HTTP'}
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template
    def self.template(options = {})
      require_options(options, [:name, :instance_names])
      properties = {"AvailabilityZones" => { "Fn::GetAZs" => "" },
        "Listeners" => get_listeners_for_template(options[:listeners]),
        "HealthCheck" => {
          "Target" => { "Fn::Join" => [ "", ["HTTP:", "80", "/"]]},
          "HealthyThreshold" => "3",
          "UnhealthyThreshold" => "5",
          "Interval" => "30",
          "Timeout" => "5"
        }
      }
      properties.merge!({"Instances" => get_instance_name_list_for_template(options[:instance_names])})
      template = {'Resources' => { 
                        options[:name] => { 
                          'Type' => 'AWS::ElasticLoadBalancing::LoadBalancer',
                          'Properties' => properties
                       }
                  }
      }
      return template 
    end

    private
      #Gets the instance names in a format expected by the Template for ELB
      def self.get_instance_name_list_for_template(instance_names)
        instance_list = []
        instance_names.each do |instance_name|
          instance_list << {'Ref' => instance_name}
        end
        return instance_list
      end

      #Get listeners array for template
      def self.get_listeners_for_template(listeners)
        default_listener = [{:port => 80, :instance_port => 80, :protocol => 'HTTP'}]
        listeners = default_listener if listeners.nil?
        listener_array = []
        listeners.each do |listener|
          listener_array << { "LoadBalancerPort" => "#{listener[:port]}",
            "InstancePort" => "#{listener[:instance_port]}",
            "Protocol" => "#{listener[:protocol]}"
          }
        end
        return listener_array
      end

  end
end
