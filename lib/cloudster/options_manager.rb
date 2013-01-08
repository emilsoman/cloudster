module OptionsManager
  def require_options(options, required_params)
    missing_args = []
    required_params.each do |param|
      missing_args << param.to_s if  options[param].nil?
    end
    raise ArgumentError, "Missing required argument: #{missing_args.join(',')}" unless missing_args.empty?
  end

  def validate_option_in_list(option, list)
    raise ArgumentError, "Option: #{option} should be one of #{list.inspect}" unless list.include?(option)
  end

end
