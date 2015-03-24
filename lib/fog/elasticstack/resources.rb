class EHResources
  attr_accessor :conn, :options
  @@subject = '/resources' # this will prepend to all locations

  def initialize(conn=EHConnection.connect, options={})
    @conn = conn
    @options = options
  end

  def list(*type)
    # the __method__ instance var is the name of the method
    loc = @@subject
    if ( type.size > 0 )
      loc += "/#{type.first}"
    end
    loc += "/#{__method__}"   
    resp = @conn.get loc
    return JSON.parse(resp.body)
  end

  def info(*options)
    # add our subject, in this case "resources"
    loc = @@subject
    if ( options.size > 0)
      loc += "/#{options[0].to_s}/#{options[1]}"
    end
    # add the verb, which is the method name
    loc += "/#{__method__}"
    resp = @conn.get loc
    return JSON.parse(resp.body)
  end

  def create(type, name, options={})
    options = options.to_json
    resp = @conn.post "#{@@subject}/#{type.to_s}/#{__method__}", options
    return JSON.parse(resp.body)
  end

  def destroy(type, resource)
    loc = "#{@@subject}/#{type.to_s}/#{resource.to_s}/#{__method__}"   
    resp = @conn.post loc
    return resp.status
  end

  def set(type, resource, options={})
    options = options.to_json
    loc = @@subject
    loc += "/#{type.to_s}/#{resource.to_s}/#{__method__}"   
    resp = @conn.post loc, options
    return JSON.parse(resp.body) 
  end
end

class Resource
  attr_accessor :type

  types = ["ip", "vlan"] 
  def initialize( type )
    @type = type
  end
end
