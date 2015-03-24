class ESServers
  attr_accessor :conn, :options
  @@subject = '/servers' # this will prepend to all locations

  def initialize(conn=ESConnection.connect, options={})
    @conn = conn
    @options = options
  end

  def list
    # the __method__ instance var is the name of the method
    resp = @conn.get "#{@@subject}/#{__method__}"
    return JSON.parse(resp.body)
  end

  def info(*uuid)
    # add our subject, in this case "servers"
    loc = @@subject

    if ( uuid.size > 0 )
      if ( uuid.first.length == 36 )
        loc += "/#{uuid.first}"
      else
        raise TypeError, "The Server UUID passed is invalid. It is #{uuid.first}. It must be 36 characters"
      end
    end
    # add the verb, which is the method name
    loc += "/#{__method__}"
    resp = @conn.get loc
    return JSON.parse(resp.body)
  end

  def create(server, start=true)
    if ( server.is_a? ESServer )
      body = server.to_json
      if ( start )
        resp = @conn.post "#{@@subject}/#{__method__}", body
        return JSON.parse(resp.body)
        # rescue JSON::ParserError resp.body
      else
        resp = @conn.post "#{@@subject}/#{__method__}/stopped", body
        #would be cool if this returned an ESServer object to use later
        return JSON.parse(resp.body)
        #rescue JSON::ParserError resp.body
      end
    else
      raise TypeError, "First argument must be an instance of ESServer with a unique name"
    end

  end

  def start(uuid)
    loc = @@subject
    if ( uuid.length == 36 )
      loc += "/#{uuid}"
    else
      raise TypeError, "The Server UUID passed is invalid. It is #{uuid}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def stop(uuid)
    loc = @@subject
    if ( uuid.length == 36 )
      loc += "/#{uuid}"
    else
      raise TypeError, "The Server UUID passed is invalid. It is #{uuid}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def shutdown(uuid)
    loc = @@subject
    if ( uuid.length == 36 )
      loc += "/#{uuid}"
    else
      raise TypeError, "The Server UUID passed is invalid. It is #{uuid}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def reset(uuid)
    loc = @@subject
    if ( uuid.length == 36 )
      loc += "/#{uuid}"
    else
      raise TypeError, "The Server UUID passed is invalid. It is #{uuid}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def destroy(uuid)
    loc = @@subject
    if ( uuid.length == 36 )
      loc += "/#{uuid}"
    else
      raise TypeError, "The Server UUID passed is invalid. It is #{uuid}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def set(uuid, options={})
    # gonna need some schema validation logic here, as the options to set are significantly reduced when a server is active.
    options = options.to_json
    loc = @@subject
    if ( uuid.length == 36 )
      loc += "/#{uuid}"
    else
      raise TypeError, "The Server UUID passed is invalid. It is #{uuid}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc, options
    return JSON.parse(resp.body)
  end
end

class ESServer

=begin
The /servers/<uuid>/info location returns a hash which looks like this as of API v?? on Fri Feb  6 01:40:45 UTC 2015

=end

  attr_accessor :name, :cpu, :mem, :options

  def initialize(name, cpu=1000, mem=512, *options)
    # method argument fun times
    # http://www.skorks.com/2009/08/method-arguments-in-ruby/
    @name = name.to_s
    @cpu = cpu.to_s
    @mem = mem.to_s
    @options = options.first
  end

  # we're going to have to serialize the object to JSON and merge the options
  # http://www.skorks.com/2010/04/serializing-and-deserializing-objects-with-ruby/
  def to_json(*a)
    # here's a more concise version of what I figured out myself!
    # https://stackoverflow.com/questions/5030553/ruby-convert-object-to-hash
    h = {}
    self.instance_variables.each do |i|
      n = i.to_s.delete("@")
      h[n] = self.instance_variable_get(i)
    end
    # merge in options hash and delete raw argument post-merge
    # http://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-delete
    obj = h.merge @options
    obj.delete("options")
    return obj.to_json(*a)
  end

  def self.from_json(o)
    new(options.first)
  end
end
