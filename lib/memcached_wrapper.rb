require 'dalli'
require 'dalli/memcache-client'


class MemcachedWrapper < Dalli::Client
  def get(key, raw =false)
    super(key, :raw => raw)
  end

  def set(key, value, expire = @default_ttl, raw = false)
    $memcache.set(key, value, expire, :raw => raw) if active?
  end

end