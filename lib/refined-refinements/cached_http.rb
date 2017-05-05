require 'open-uri'
require 'base64'

# RR::CachedHttp.cache_dir = 'tmp'
# # RR::CachedHttp.offline = true
# RR::CachedHttp.get('http://google.com/test')
module RR
  module CachedHttp
    def self.cache_dir
      @cache_dir || raise('Set CachedHttp.cache_dir!')
    end

    def self.cache_dir=(cache_dir)
      @cache_dir = cache_dir
    end

    def self.offline?
      @offline
    end

    def self.offline=(boolean)
      @offline = boolean
    end

    def self.cache_path(url)
      File.join(self.cache_dir, Base64.encode64(url).chomp)
    end

    def self.get(url)
      if self.offline?
        self.retrieve_from_cache(url)
      else
        self.fetch(url)
      end
    rescue SocketError
      self.retrieve_from_cache(url, true)
    rescue Exception => e
      p [:e, e]; raise e
    end

    def self.retrieve_from_cache(url, tried_to_fetch = false)
      if File.exist?(self.cache_path(url))
        File.read(self.cache_path(url))
      else
        raise "URL #{url} is not cached#{" and can't be fetched" if tried_to_fetch}."
      end
    end

    def self.fetch(url)
      open(url).read.tap do |fetched_data|
        File.open(self.cache_path(url), 'w') do |file|
          file.write(fetched_data)
        end
      end
    end
  end
end
