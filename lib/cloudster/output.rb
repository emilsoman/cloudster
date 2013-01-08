module Cloudster
  module Output
    # Returns the Output template for resources
    #
    # ==== Parameters
    # * output: Hash containing the valid outputs and their cloudformation translations
    def output_template(outputs)
      resource_name = outputs.keys[0]
      outputs_array = outputs.values[0].collect
      each_output_join = outputs_array.collect {|output| {"Fn::Join" => [":", output]}}
      return resource_name => {
        'Value' => { "Fn::Join" => [ ",", each_output_join] }
      }
    end

  end
end
