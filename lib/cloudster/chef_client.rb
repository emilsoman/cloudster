module Cloudster
  #==UserData for Chef Client bootstrap
  class ChefClient

    # Initialize an ChefClient configuration
    #
    # ==== Notes
    # options parameter must include values for :instance_name, :validation_key, :server_url and :node_name
    #
    # ==== Examples
    #   chef_client = Cloudster::ChefClient.new(
    #    :instance_name => 'AppServer',
    #    :validation_key => 'asd3e33880889098asdnmnnasd8900890a8sdmasdjna9s880808asdnmnasd90-a',
    #    :server_url => 'http://10.50.60.70:4000',
    #    :node_name => 'project.environment.appserver_1'
    #   )
    #
    # ==== Parameters
    # * options<~Hash> - 
    #     * :instance_name: String containing the name of EC2 element on which chef-client is to be bootstrapped. Mandatory field
    #     * :validation_key: String containing the key used for validating this client with the server. This can be taken from the chef-server validation.pem file. Mandatory field
    #     * :server_url: String containing the fully qualified domain name of the chef-server. Mandatory field
    #     * :node_name: String containing the name for the chef node. It has to be unique across all nodes in the particular chef client-server ecosystem. Mandatory field
    def initialize(options = {})
      require_options(options, [:validation_key, :server_url, :node_name])
      @validation_key = options[:validation_key]
      @server_url = options[:server_url]
      @node_name = options[:node_name]
    end

    # Merges the required CloudFormation template for installing the Chef Client to the template of the EC2 instance
    #
    #
    # ==== Examples
    #   chef_client = Cloudster::ChefClient.new(
    #    :instance_name => 'AppServer',
    #    :validation_key => 'asd3e33880889098asdnmnnasd8900890a8sdmasdjna9s880808asdnmnasd90-a',
    #    :server_url => 'http://10.50.60.70:4000',
    #    :node_name => 'project.environment.appserver_1'
    #   )
    #   ec2 = Cloudster::Ec2.new(
    #    :name => 'AppServer',
    #    :key_name => 'mykey',
    #    :image_id => 'ami_image_id',
    #    :instance_type => 't1.micro'
    #   )
    #
    #   chef_client.add_to ec2
    #
    # ==== Parameters
    # * instance of EC2
    def add_to(ec2)
      ec2_template = ec2.template
      @instance_name = ec2.name 
      chef_client_template = template
      ec2.template.deep_merge(chef_client_template)
    end

    private
      
      def template
        return "Resources" => {
          @instance_name => {
            "Metadata" => {
              "AWS::CloudFormation::Init" => {
                "config" => {
                  "packages" => {
                    "rubygems" => {
                      "chef" => [],
                      "ohai" => []
                     },
                    "apt" => {
                       "ruby"            => [],
                       "ruby-dev"        => [],
                       "libopenssl-ruby" => [],
                       "rdoc"            => [],
                       "ri"              => [],
                       "irb"             => [],
                       "build-essential" => [],
                       "wget"            => [],
                       "ssl-cert"        => [],
                       "rubygems"        => []
                    }
                  }
                }
              }
            },
            "Properties"=> {
              "UserData" => { "Fn::Base64" => { "Fn::Join" => ["", [
                "#!/bin/bash -v\n",
                "function error_exit\n",
                "{\n",
                "  exit 1\n",
                "}\n",

                "mkdir /etc/chef\n",
                "cat << EOF > /etc/chef/solo.rb\n",
                "file_cache_path \"/tmp/chef-solo\"\n",
                "cookbook_path \"/tmp/chef-solo/cookbooks\"\n",
                "EOF\n",
                "cat << EOF > /etc/chef/chef.json\n",
                "{\n",
                "\"chef_server\": {\n",
                "  \"server_url\": \"http://localhost:4000\",\n",
                "  \"webui_enabled\": true,\n",
                "  \"node_name\": \"#{@node_name}\"\n",
                "},\n",
                "\"run_list\": [\"recipe[chef-client::config]\", \"recipe[chef-client]\"]\n",
                "}\n",
                "EOF\n",

                "# Bootstrap chef\n",
                "chef-solo -c /etc/chef/solo.rb -j /etc/chef/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz  > /tmp/chef_solo.log 2>&1 || error_exit 'Failed to bootstrap chef client'\n",

                "# Fixup the server URL in client.rb\n",
                "echo \"#{@validation_key}\" > /etc/chef/validation.pem 2>&1 || error_exit 'Failed to get Chef Server validation key'\n",
                "sed -i 's|http://localhost:4000|", @server_url , "|g' /etc/chef/client.rb\n",
                "chef-client -i 20 > /tmp/chef_client.log 2>&1 || error_exit 'Failed to initialize host via chef client' \n"
            ]]}}
            }
          }
        }
      end

  end
end
