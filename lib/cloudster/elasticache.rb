module Cloudster
 #ElastiCache Resource
 class ElastiCache

   attr_accessor :name, :template
   # Initializes an ElastiCache resource
   #
   # ==== Notes
   # options parameter must include values for :node_type, :cache_security_group_names, :engine, :node_count
   #
   # ==== Parameters
   # * options<~Hash>
   #   * :name : String representing the name for the ElastiCache resource (Required)
   #   * :node_type : String representing the compute and memory capacity of nodes in a Cache Cluster. One of : cache.t1.micro | cache.m1.small | cache.m1.medium | cache.m1.large | cache.m1.xlarge | cache.m3.xlarge | cache.m3.2xlarge | cache.m2.xlarge | cache.m2.2xlarge | cache.m2.4xlarge | cache.c1.xlarge (Required)
   #   * :cache_security_group_names : Array of cache security group names (Required)
   #   * :engine : String containing the name of the cache engine to be used for this cache cluster. Only 'memcached' is supported now.(Required)
   #   * :node_count : Integer indicating number of cache nodes the cache cluster should have.(Required)
   # ==== Examples
   #   cache = Cloudster::ElastiCache.new(
   #    :name => 'ElastiCacheResource',
   #    :node_type => 'cache.t1.micro',
   #    :cache_security_group_names => ['default'],
   #    :engine => 'memcached',
   #    :node_count => 3"
   #   )

   def initialize(options = {})
     require_options(options, [:name, :node_type, :cache_security_group_names, :engine, :node_count])
     @name = options[:name]
     @node_type = options[:node_type]
     @cache_security_group_names = options[:cache_security_group_names]
     @engine = options[:engine]
     @node_count = options[:node_count]
   end

   # Returns a Ruby hash version of the Cloud Formation template for the ElastiCache resource
   #
   # ==== Examples
   #   elasticache = Cloudster::ElastiCache.new(
   #    :name => 'ElastiCacheResource',
   #    :node_type => 'cache.t1.micro',
   #    :cache_security_group_names => ['default'],
   #    :engine => 'memcached',
   #    :node_count => 3"
   #   )
   #   elasticache.template
   #
   # ==== Returns
   # * Ruby hash version of the Cloud Formation template for the elasticache resource
    def template
      @template ||= ElastiCache.template({:name => @name, :node_type => @node_type, :cache_security_group_names => @cache_security_group_names, :engine => @engine, :node_count => @node_count})
    end

    # Class method that returns a Ruby hash version of the Cloud Formation template
    #
    # ==== Examples
    #   template = Cloudster::ElastiCache.template(
    #     :name => 'ElastiCacheResource',
    #     :node_type => 'cache.t1.micro',
    #     :cache_security_group_names => ['default'],
    #     :engine => 'memcached',
    #     :node_count => 3"
    #   )
    #
    # ==== Parameters
    # * options<~Hash>
    #   * :name : String representing the name for the ElastiCache resource (Required)
   #   * :node_type : String representing the compute and memory capacity of nodes in a Cache Cluster. One of : cache.t1.micro | cache.m1.small | cache.m1.medium | cache.m1.large | cache.m1.xlarge | cache.m3.xlarge | cache.m3.2xlarge | cache.m2.xlarge | cache.m2.2xlarge | cache.m2.4xlarge | cache.c1.xlarge (Required)
    #   * :cache_security_group_names : Array of cache security group names (Required)
    #   * :engine : String containing the name of the cache engine to be used for this cache cluster. Only 'memcached' is supported now.(Required)
    #   * :node_count : Integer indicating number of cache nodes the cache cluster should have.(Required)
    # ==== Returns
    # * Ruby hash version of the Cloud Formation template for ElastiCache
    def self.template(options = {})
      require_options(options, [:name, :node_type, :cache_security_group_names, :engine, :node_count])
      properties = {}
      properties.merge!({
        "CacheNodeType" => options[:node_type],
        "CacheSecurityGroupNames" => options[:cache_security_group_names],
        "Engine" => options[:engine],
        "NumCacheNodes" => options[:node_count].to_s
      })
      template = {'Resources' => {
                        options[:name] => {
                          'Type' => 'AWS::ElastiCache::CacheCluster',
                          'Properties' => properties
                       }
                  }
      }
      return template
    end
 end
end
