# Cloudster [![Build Status](https://travis-ci.org/emilsoman/cloudster.png)](https://travis-ci.org/emilsoman/cloudster) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/emilsoman/cloudster) [![Dependency Status](https://gemnasium.com/emilsoman/cloudster.png)](https://gemnasium.com/emilsoman/cloudster)

Cloudster exposes simple helper methods to provision your AWS cloud.
Cloudster uses the AWS APIs to provision stacks on Amazon Cloud.


- This gem is under active development. Currently supports only a basic EC2 resource .

##Installation

    gem install cloudster

## Usage

Create AWS EC2 resources as shown here:

    app_server = Cloudster::Ec2.new(:name => 'AppServer',
      :key_name => 'mykey',
      :image_id => 'ami_image_id'
    )
    app_server_2 = Cloudster::Ec2.new(:name => 'AppServer',
      :key_name => 'mykey',
      :image_id => 'ami_image_id'
    )

Create a stack out of the resources :

    stack = Cloudster::Cloud.new(:access_key_id => 'accesskeyid',
                                :secret_access_key => 'topsecretaccesskey')
Now you can do stuff like :

- Get the CloudFormation template for a resource in Ruby Hash :
    
        app_server.template
- Get the CloudFormation template for the stack :
    
        stack.template(:resources => [app_server, app_server_2], :description => 'Description of the stack')
    
And most importantly :

- Provision the stack :

        stack.provision(:resources => [app_server, app_server_2], :stack_name => 'TestStack', :description => 'Description of the stack')


##License

MIT

*Free Software, Forever . YEAH !*
