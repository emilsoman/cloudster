module Cloudster
  #==ElasticIp resource
  class ElasticIp

    # Initialize an ElasticIp
    #
    # ==== Notes
    # options parameter must include values for :name
    #
    # ==== Examples
    #   elastic_ip = Cloudster::ElasticIp.new(:name => 'ElasticIp')
    #
    # ==== Parameters
    # * options<~Hash> -
    #     * :name: String containing the name of ElastiCache resource
    def initialize(options = {})
      require_options(options, [:name])
      @name = options[:name]
    end

    # Merges the required CloudFormation template for adding an ElasticIp to an EC2 instance
    #
    #
    # ==== Examples
    #   elastic_ip = Cloudster::ElasticIp.new(:name => 'AppServerEIp')
    #   ec2 = Cloudster::Ec2.new(
    #    :name => 'AppServer',
    #    :key_name => 'mykey',
    #    :image_id => 'ami_image_id',
    #    :instance_type => 't1.micro'
    #   )
    #
    #   elastic_ip.add_to ec2
    #
    # ==== Parameters
    # * instance of EC2
    def add_to(ec2)
      ec2_template = ec2.template
      @instance_name = ec2.name
      elastic_ip_template = template
      ec2.template.deep_merge(elastic_ip_template)
    end

    private
      def template
        return "Resources" => {
          @name => {
            "Type" => "AWS::EC2::EIP",
              "Properties" => {
                "InstanceId" => {
                  "Ref" => @instance_name
                }
              }
          }
        }
      end

  end
end
