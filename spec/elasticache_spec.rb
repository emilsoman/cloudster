require 'spec_helper'

describe Cloudster::ElastiCache do
  describe 'initialize' do
    it "should raise argument error if no argument is provided" do
      expect { Cloudster::ElastiCache.new() }.to raise_error(ArgumentError, 'Missing required argument: name,node_type,cache_security_group_names,engine,node_count')
    end
    it "should not raise argument error if all arguments are provided" do
      expect do
        Cloudster::ElastiCache.new(
          :name => 'ElastiCache',
          :node_type => 'test',
          :cache_security_group_names => ['default'],
          :engine => 'memcached',
          :node_count => 3
        )
      end.to_not raise_error
    end
  end

  describe '#template' do
    it "should return a ruby hash for the resource cloudformation template with only mandatory fields" do
      elasticache = Cloudster::ElastiCache.new(
          :name => 'ElastiCache',
          :node_type => 'test',
          :cache_security_group_names => ['default'],
          :engine => 'memcached',
          :node_count => 3
        )
      elasticache.template.should == {'Resources' => {"ElastiCache"=>{"Type"=>"AWS::ElastiCache::CacheCluster", "Properties"=>{"CacheNodeType"=>"test", "CacheSecurityGroupNames"=>["default"], "Engine"=>"memcached", "NumCacheNodes"=>"3"}}}}
    end
  end

  describe '.template' do
    it "should raise argument error if no argument is provided" do
      expect { Cloudster::ElastiCache.template() }.to raise_error(ArgumentError, 'Missing required argument: name,node_type,cache_security_group_names,engine,node_count')
    end
    it "should return a ruby hash for the resource cloudformation template" do
      hash = Cloudster::ElastiCache.template(
          :name => 'ElastiCache',
          :node_type => 'test',
          :cache_security_group_names => ['default'],
          :engine => 'memcached',
          :node_count => 3
        )
      hash.should == {'Resources' => {"ElastiCache"=>{"Type"=>"AWS::ElastiCache::CacheCluster", "Properties"=>{"CacheNodeType"=>"test", "CacheSecurityGroupNames"=>["default"], "Engine"=>"memcached", "NumCacheNodes"=>"3"}}}}
    end
  end

end
