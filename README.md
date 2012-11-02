# Cloudster [![Build Status](https://travis-ci.org/emilsoman/cloudster.png)](https://travis-ci.org/emilsoman/cloudster) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/emilsoman/cloudster) [![Dependency Status](https://gemnasium.com/emilsoman/cloudster.png)](https://gemnasium.com/emilsoman/cloudster)

Cloudster exposes simple helper methods to provision your AWS cloud.
Cloudster uses the AWS APIs to provision stacks on Amazon Cloud.


- This gem is under active development. Currently supports only a basic EC2 resource .

##Installation

    gem install cloudster

## Usage

Create AWS resources as shown here:

    app_server = Cloudster::Ec2.new(:name => 'AppServer',
      :key_name => 'mykey',
      :image_id => 'ami_image_id',
      :instance_type => 't1.micro'
    )

    app_server_2 = Cloudster::Ec2.new(:name => 'AppServer2',
      :key_name => 'mykey',
      :image_id => 'ami_image_id'
    )

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
