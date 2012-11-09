# Cloudster [![Build Status](https://travis-ci.org/emilsoman/cloudster.png)](https://travis-ci.org/emilsoman/cloudster) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/emilsoman/cloudster) [![Dependency Status](https://gemnasium.com/emilsoman/cloudster.png)](https://gemnasium.com/emilsoman/cloudster)

Cloudster exposes simple helper methods to provision your AWS cloud.
Cloudster uses the AWS APIs to provision stacks on Amazon Cloud.

##Installation

    gem install cloudster

## Usage

Create AWS resources as shown here:

    app_server = Cloudster::Ec2.new(:name => 'AppServer',
      :key_name => 'mykey',
      :image_id => 'ami_image_id',
      :instance_type => 't1.micro'
    )

    chef_client = Cloudster::ChefClient.new(
     :validation_key => 'asd3e33880889098asdnmnnasd8900890a8sdmasdjna9s880808asdnmnasd90-a',
     :server_url => 'http://10.50.60.70:4000',
     :node_name => 'project.environment.appserver_1'
    )

    chef_client.add_to(app_server)

    app_server_2 = Cloudster::Ec2.new(:name => 'AppServer2',
      :key_name => 'mykey',
      :image_id => 'ami_image_id'
    )

    #Add your app servers to the ElasticLoadBalancer
    load_balancer = Cloudster::Elb.new(:name => 'LoadBalancer',
      :instance_names => ['AppServer', 'AppServer2']
    )

    database = Cloudster::Rds.new(
        :name => 'MySqlDB',
        :instance_class => 'db.t1.micro',
        :storage_class => '100',
        :username => 'admin',
        :password => 'admin123',
        :engine => 'MySQL'
    )

Make a cloud :

    cloud = Cloudster::Cloud.new(:access_key_id => 'accesskeyid', :secret_access_key => 'topsecretaccesskey')

- Get the CloudFormation template for a resource in Ruby Hash :
    
        app_server.template
- Get the CloudFormation template for the stack :
    
        cloud.template(:resources => [app_server, app_server_2, load_balancer, database], :description => 'Description of the stack')
    
- Provision the stack :

        cloud.provision(:resources => [app_server, app_server_2, load_balancer, database], :stack_name => 'TestStack', :description => 'Description of the stack')

- Update the stack :

        cloud.update(:resources => [app_server, app_server_2], :stack_name => 'TestStack', :description => 'Description of the stack')

- Delete the stack and it's attached resources :

        cloud.delete(:stack_name => 'TestStack')

- Describe the events of a stack using :

        cloud.events(:stack_name => 'TestStack')



##License

MIT

*Free Software, Forever . YEAH !*
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/eafd00c3c74c7362ed850f6a50120c30 "githalytics.com")](http://githalytics.com/emilsoman/cloudster)
