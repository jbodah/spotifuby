class HashProxy
  def initialize(hash)
    @hash = hash
  end

  def method_missing(sym)
    @hash[sym.to_s]
  end
end
