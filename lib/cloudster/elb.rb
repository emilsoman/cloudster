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
    #    :instance_names => ['AppServer1','AppServer2']
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #     * :name: String containing the name for the Elb resource
    #     * :instance_names: Array containing the names of the Ec2 resources which will be added under the ELB
    def initialize(options = {})
      require_options(options, [:name, :instance_names])
      @name = options[:name]
      @instance_names = options[:instance_names]
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
      Elb.template({:name =>@name, :instance_names => @instance_names})
    end

    # Class method that returns a Ruby hash version of the Cloud Formation template
    #
    # ==== Examples
    #   template = Cloudster::Elb.template(
    #    :name => 'LoadBalances',
    #    :instance_names => ['AppServer1', 'AppServer2']
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #   *Keys: 
    #     * :name: String containing the name for the Elb resource
    #     * :instance_names: Array containing the names of the Ec2 resources which will be added under the ELB
    #
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template
    def self.template(options = {})
      require_options(options, [:name, :instance_names])
      properties = {"AvailabilityZones" => { "Fn::GetAZs" => "" },
        "Listeners" => [{ "LoadBalancerPort" => "80",
          "InstancePort" => "80",
          "Protocol" => "HTTP"
        }],
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

  end
end
