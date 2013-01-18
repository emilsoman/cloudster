# Cloudster
[![Build Status](https://travis-ci.org/emilsoman/cloudster.png)](https://travis-ci.org/emilsoman/cloudster)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/emilsoman/cloudster)
[![Dependency Status](https://gemnasium.com/emilsoman/cloudster.png)](https://gemnasium.com/emilsoman/cloudster)
[![still maintained](http://stillmaintained.com/emilsoman/cloudster.png)](http://stillmaintained.com/emilsoman/cloudster)

Cloudster is a Ruby gem that was born to cut the learning curve involved in writing your own CloudFormation templates. If you don't know what
a CloudFormation template is, but know about the AWS Cloud offerings, you can still use cloudster to provision your stack. Still in infancy , cloudster
can create a basic stack like a breeze. Checkout the Usage section for the supported features.

##Installation

    gem install cloudster

## Usage

Create AWS resources :

    app_server = Cloudster::Ec2.new(:name => 'AppServer',
      :key_name => 'mykey',
      :image_id => 'ami_image_id',
      :instance_type => 't1.micro',
      :security_groups => ["TopSecurityGroup"]
    )

    chef_client = Cloudster::ChefClient.new(
     :validation_key => 'asd3e33880889098asdnmnnasd8900890a8sdmasdjna9s880808asdnmnasd90-a',
     :server_url => 'http://10.50.60.70:4000',
     :node_name => 'project.environment.appserver_1',
     :interval => 1800
    )

    elastic_ip = Cloudster::ElasticIp.new(:name => 'AppServerElasticIp')

    chef_client.add_to(app_server)
    elastic_ip.add_to(app_server)

    app_server_2 = Cloudster::Ec2.new(:name => 'AppServer2',
      :key_name => 'mykey',
      :image_id => 'ami_image_id'
    )

    #Add your app servers to the ElasticLoadBalancer
    load_balancer = Cloudster::Elb.new(:name => 'LoadBalancer',
      :instance_names => ['AppServer', 'AppServer2'],
      :listeners => [{:port => 80, :instance_port => 8080, :protocol => 'HTTP'}]
    )

    database = Cloudster::Rds.new(
      :name => 'MySqlDB',
      :instance_class => 'db.t1.micro',
      :storage_class => '100',
      :username => 'admin',
      :password => 'admin123',
      :engine => 'MySQL',
      :multi_az => true
    )

    storage = Cloudster::S3.new(
      :name => 'MyBucket'
    )

    cloud_front = Cloudster::CloudFront.new(:name => 'CloudFrontResource')
    cloud_front.add_to storage

    elasticache = Cloudster::ElastiCache.new(
      :name => 'CacheResource',
      :node_type => 'cache.t1.micro',
      :cache_security_group_names => ['default'],
      :engine => 'memcached',
      :node_count => 3
    )

Make a cloud :

    cloud = Cloudster::Cloud.new(:access_key_id => 'accesskeyid', :secret_access_key => 'topsecretaccesskey', :region => 'us-west-1')

Get the CloudFormation template for the stack :

        cloud.template(:resources => [app_server, app_server_2, load_balancer, database, storage, elasticache], :description => 'Description of the stack')

Get the CloudFormation template for a resource as a Ruby Hash :

        app_server.template

Cloudster can also interact with the provisioned AWS Cloud :

- Provision the stack :

        cloud.provision(:resources => [app_server, app_server_2, load_balancer, database], :stack_name => 'TestStack', :description => 'Description of the stack')

- Update the stack :

        cloud.update(:resources => [app_server, app_server_2], :stack_name => 'TestStack', :description => 'Description of the stack')

- Delete the stack and it's attached resources :

        cloud.delete(:stack_name => 'TestStack')

- Get the output attributes of each resource in the stack :

        cloud.outputs(:stack_name => 'TestStack')

- Describe the events of a stack :

        cloud.events(:stack_name => 'TestStack')

- Describe the attributes of a stack :

        cloud.describe(:stack_name => 'TestStack')

- Describe all resources of a stack :

        cloud.resources(:stack_name => 'TestStack')

- Get the status of a stack :

        cloud.status(:stack_name => 'TestStack')

- Describe the RDS endpoints in a stack :

        cloud.get_database_endpoints(:stack_name => 'TestStack')

- Get the details of all EC2 intances in a stack :

        cloud.get_ec2_details(:stack_name => 'TestStack')

- Get the details of all RDS intances in a stack :

        cloud.get_rds_details(:stack_name => 'TestStack')

- Get the details of all ELB intances in a stack :

        cloud.get_elb_details(:stack_name => 'TestStack')

- Get details of all keypairs created in the AWS account :

        cloud.get_key_pairs

- Get details of all Security Groups created in the AWS account :

        cloud.get_security_groups

- ### More coming soon ..

I'm trying to add every AWS resource to cloudster, one by one. If you don't find what you need,
let me know and I'll try to get the feature included ASAP, or you can submit a pull request with the feature -
that would be awesome! Or, you can patiently wait till the feature is added to cloudster.

----------------

# Contribute

Got some love for Cloudster? Sweet!

## Found a bug?

Log the bug in the [issue tracker](https://github.com/emilsoman/cloudster/issues). Be sure to include all relevant information, like
the versions of Cloudster and Ruby you're using. A [gist](http://gist.github.com/)
of the code that caused the issue as well as any error messages are also very
helpful.

## Need help?

You can use the [Issues](https://github.com/emilsoman/cloudster/issues) page to ask a new question for now. This is how you do it:
1. Click on New Issue.
2. Type in your question and submit.

## Have a patch?

Bugs and feature requests that include patches are much more likely to
get attention. Here are some guidelines that will help ensure your patch
can be applied as quickly as possible:

1. **Use [Git](http://git-scm.com) and [GitHub](http://github.com):**
   The easiest way to get setup is to fork the
   [cloudster repo](http://github.com/emilsoman/cloudster/).

2. **Write unit tests:** If you add or modify functionality, it must
   include unit tests. I use RSpec to test cloudster. If you are not an
   RSpec expert, if you let me know, I can help you write the specs.

3. **Update the `README`:** If the patch adds or modifies a major feature,
   modify the `README.md` file to reflect that. Again if you're not an
   expert with Markdown syntax, it's really easy to learn. Check out [Prose.io](http://prose.io/) to
   try it out.

4. **Push it:** Once you're ready, push your changes to a topic branch
   and add a note to the ticket with the URL to your branch. Or, say
   something like, "you can find the patch on johndoe/foobranch". I also
   gladly accept Github [pull requests](http://help.github.com/pull-requests/).

__NOTE:__ _I will take in whatever I can get._ If you prefer to
attach diffs in comments on issues, that's fine; but do know
that _someone_ will need to take the diff through the process described
above and this can hold things up considerably.


##License

MIT

*Free Software, Forever . YEAH !*

## Thanks

To Sinatra README for having a nice 'Contribute' section which I'm using(with minor changes) for Cloudster.
