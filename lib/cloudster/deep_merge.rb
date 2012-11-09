# Stolen shamelessly from here http://apidock.com/rails/Hash/deep_merge!
class Hash
  def deep_merge(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end
end
