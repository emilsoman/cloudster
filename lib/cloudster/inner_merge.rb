# Comes from Rails : http://apidock.com/rails/Hash/deep_merge!
class Hash
  def inner_merge(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.inner_merge(v) : v
    end
    self
  end
end
