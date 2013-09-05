module Cloudster
  #==UserData for Chef Client bootstrap
  class ChefClient

    # Initialize an ChefClient configuration
    #
    # ==== Notes
    # options parameter must include values for :validation_key, :server_url and :node_name
    #
    # ==== Examples
    #   chef_client = Cloudster::ChefClient.new(
    #    :validation_key => 'asd3e33880889098asdnmnnasd8900890a8sdmasdjna9s880808asdnmnasd90-a',
    #    :server_url => 'http://10.50.60.70:4000',
    #    :node_name => 'project.environment.appserver_1',
    #    :validation_client_name => 'chef-validator',
    #    :interval => 1800
    #   )
    #
    # ==== Parameters
    # * options<~Hash> -
    #     * :validation_key: String containing the key used for validating this client with the server. This can be taken from the chef-server validation.pem file. Mandatory field
    #     * :server_url: String containing the fully qualified domain name of the chef-server. Mandatory field
    #     * :node_name: String containing the name for the chef node. It has to be unique across all nodes in the particular chef client-server ecosystem. Mandatory field
    #     * :interval: Integer containing the interval(in seconds) between chef-client runs. Default value : 1800 seconds
    #     * :validation_client_name: String containing the name of the validation client. "ORGNAME-validator" if using hosted chef server. Default: 'chef-validator'
    def initialize(options = {})
      require_options(options, [:validation_key, :server_url, :node_name])
      @validation_key = options[:validation_key]
      @server_url = options[:server_url]
      @node_name = options[:node_name]
      @interval = options[:interval] || 1800
      @validation_client_name = options[:validation_client_name] || 'chef-validator'
    end

    # Merges the required CloudFormation template for installing the Chef Client to the template of the EC2 instance
    #
    #
    # ==== Examples
    #   chef_client = Cloudster::ChefClient.new(
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
      ec2.template.inner_merge(chef_client_template)
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

                #Install aws sfn scripts to run cfn-init
                "apt-get -y install python-setuptools\n",
                "easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz\n",
                "cfn-init -v --region ", { "Ref" => "AWS::Region" },
                " -s ", { "Ref" => "AWS::StackId" }, " -r #{@instance_name}",
                " || error_exit 'Failed to run cfn-init'\n",

                # Fixup path and links for the bootstrap script
                "export PATH=$PATH:/var/lib/gems/1.8/bin\n",

                #Bootstrap chef client
                "mkdir /etc/chef\n",
                "cat << EOF > /etc/chef/solo.rb\n",
                "file_cache_path \"/tmp/chef-solo\"\n",
                "cookbook_path \"/tmp/chef-solo/cookbooks\"\n",
                "node_name \"#{@node_name}\"\n",
                "EOF\n",
                "cat << EOF > /etc/chef/chef.json\n",
                "{\n",
                "\"chef_client\": {\n",
                "  \"server_url\": \"#{@server_url}\",\n",
                "  \"validation_client_name\": \"#{@validation_client_name}\",\n",
                "  \"interval\": \"#{@interval}\"\n",
                "},\n",
                "\"run_list\": [\"recipe[chef-client::config]\", \"recipe[chef-client]\"]\n",
                "}\n",
                "EOF\n",
                "echo \"#{@validation_key}\" > /etc/chef/validation.pem\n",
                "# Bootstrap chef\n",
                "chef-solo -c /etc/chef/solo.rb -j /etc/chef/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz  > /tmp/chef_solo.log 2>&1 || error_exit 'Failed to bootstrap chef client'\n"
            ]]}}
            }
          }
        }
      end

  end
end
