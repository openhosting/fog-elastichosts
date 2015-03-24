class ESDrives
  attr_accessor :conn, :options
  @@subject = '/drives' # this will prepend to all locations

  def initialize(conn=ESConnection.connect, options={})
    @conn = conn
    @options = options
  end

  def list
    # the __method__ instance var is the name of the method
    resp = @conn.get "#{@@subject}/#{__method__}"
    # returns an array of Hashes, convert to an array of ESDriveUUID objects
    return JSON.parse(resp.body)
  end

  def info(*uuid)
    # add our subject, in this case "drives"
    loc = @@subject

    if ( uuid.size > 0 )
      if ( uuid.first.length == 36 )
        loc += "/#{uuid.first}"
      else
        raise TypeError, "The Drive UUID passed is invalid. It is #{uuid.first}. It must be 36 characters"
      end
    end
    # add the verb, which is the method name
    loc += "/#{__method__}"
    resp = @conn.get loc
    return JSON.parse(resp.body)
  end

  def create(drive,options={})
    if ( drive.is_a? ESDrive )
      # a data structure of optional user metadata and tags
      ctags = options[:ctags]
      user_data = options[:user]
      # we're going to have to serialize the object to JSON
      # http://www.skorks.com/2010/04/serializing-and-deserializing-objects-with-ruby/
      body = drive.to_json
      resp = @conn.post "#{@@subject}/#{__method__}", body
      return JSON.parse(resp.body)
    else
      raise TypeError, "First argument must be an instance of ESDrive with a unique name"
    end
  end

  def destroy(drive)
    loc = @@subject
    if ( drive.length == 36 )
      loc += "/#{drive}"
    else
      raise TypeError, "The Drive UUID passed is invalid. It is #{drive}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def set(drive, options={})
    # This should accept a drive object, not a UUID
    # drive.drive should return the UUID
    options = options.to_json
    loc = @@subject
    if ( drive.length == 36 )
      loc += "/#{drive}"
    else
      raise TypeError, "The Drive UUID passed is invalid. It is #{drive}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    resp = @conn.post loc, options
    return JSON.parse(resp.body) 
  end

  def image(drive, source, *conversion)
    # drive and source should be Drive objects
    loc = @@subject
    if ( drive.length == 36)
      loc += "/#{drive}"
    else
      raise TypeError, "The Drive UUID passed is invalid. It is #{drive}. It must be 36 characters"
    end 
    loc += "/#{__method__}"   
    if ( source.length == 36)
      loc += "/#{source}"
    else
      raise TypeError, "The Source UUID passed is invalid. It is #{source}. It must be 36 characters"
    end
    if ( conversion.size > 0 )
      loc += "/#{conversion.first.to_s}"
    end
    resp = @conn.post loc
    return resp.status 
  end

  # this will take some weird options for Faraday
  # http://www.rubydoc.info/gems/faraday/
  def read(drive, offset=0, size="4M")
    content_type = "application/octet-stream"
    loc = @@subject
    if ( drive.length == 36 )
      loc += "/#{drive}"
    else
      raise TypeError, "The Drive UUID passed is invalid. It is #{drive}. It must be 36 characters"
    end 
    loc += "/#{__method__}/#{offset.to_s}/#{size.to_s}"
    return loc
    #resp = @conn.get loc
    #return JSON.parse(resp.body)
    # this'll have to take a file as an argument, since we are streaming binary data to disk.
  end 

  def write(drive, offset=0)
    if ( drive.is_a? ESDrive )
      content_type = "application/octet-stream"
      content_encoding = "gzip"
      loc = @@subject
      if ( drive.length == 36 )
        loc += "/#{drive}"
      else
        raise TypeError, "The Drive UUID passed is invalid. It is #{drive}. It must be 36 characters"
      end 
      loc += "/#{__method__}/#{offset.to_s}"
      return loc
      # this'll have to take a file as an argument, since we are streaming binary data to a URL.
      #resp = @conn.post loc, body
      #return resp.status
    end 
  end
end

class ESDrive

=begin
The /drives/<uuid>/info location returns a hash which looks like this as of API v?? on Fri Feb  6 01:40:45 UTC 2015

It appears the only required parameters are :name and :size, :drive is the UUID and automatically assigned

{"drive"=>"e173e5a2-d8ff-4e82-9365-5f5aec240add", "encryption:cipher"=>"aes-xts-plain", "name"=>"teamnerds.cool (diaspora fun) (backup)", "size"=>17179869184, "status"=>"active", "tier"=>"disk", "user"=>"e179a513-5a36-4ffa-92a2-bbdc497ecd21"}
=end

  attr_accessor :name, :size, :claim_type, :readers, :ctags, :user, :avoid, :encryption_cipher

  def initialize(name, size="1G", *options)
    @name = name.to_s
    @size = size.to_s
    # let's pause with the optional args for now.
    #@claim_type = options['claim:type']
    #@readers = options['readers']
    #@ctags = options['ctags']
    #@user = options['user']
    #@avoid = options['avoid']
    #@encryption_cipher = options['encryption:cipher']
    # if we only need an instance from a JSON response, we get some more attributes.
    # I need to figure out how to take raw JSON from the options hash and make this
    # object from it
    #@uuid = options['drive']
  end

  # weird little object to JSON serialization method
  def to_json(*a)
    h = {}
    self.instance_variables.each do |i|
      n = i.to_s.delete("@")
      h[n] = self.instance_variable_get(i)
    end
    return h.to_json(*a)
  end

  def self.from_json(o)
    new(options.first)
  end
end
