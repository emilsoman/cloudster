require 'spec_helper'

describe "Hash" do
  describe "#deep_merge" do
    it "should do a deep merge for new keys and deep override for existing keys" do
      hash1 = {
        'key1' => 'value1',
        'key2' => {
          'inner_key1' =>'inner_value1',
          'inner_key2' =>'inner_value2'
        }
      }
      hash2 = {
        'key_to_merge' => 'value_to_merge',
        'key2' => {
          'inner_key_to_be_merged' =>'inner_value_to_be_merged',
          'inner_key2' =>'inner_value_to_override'
        }
      }
      hash1.deep_merge(hash2).should == {
        "key1"=>"value1",
        "key2"=>{
          "inner_key1"=>"inner_value1",
          "inner_key2"=>"inner_value_to_override",
          "inner_key_to_be_merged"=>"inner_value_to_be_merged"
        },
        "key_to_merge"=>"value_to_merge"
      }
    end
  end
end
