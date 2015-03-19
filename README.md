# Open Hosting API client library

This library implements every method in the 
[Open Hosting API](http://www.openhosting.com/api/) 
in the Ruby programming language. It depends on the 
[Faraday HTTP client library](https://github.com/lostisland/faraday), 
which has the advantage of abstracting various backends. It has a
clearly defined interface and works well for small programs and large scale web
applications alike.

By default it uses the 
[Patron adapter](https://toland.github.io/patron/) 
for maximum compatibility with the 
[reference implementation](http://www.elastichosts.com/support/api/)
 designed by Elastic Hosts. Patron requires the libcurl native library for high performance and features.

If you wish to use the default Ruby Net::HTTP library, modify the file
`lib/connection.rb` to read `faraday.adapter :default_adapter` during connection
initialization. This will eventually be wrapped into some initialization
option.

## Connecting

To get started, install the gem and set a single environment variable in your
shell containing your account's user id and secret key. This information is available through your account [Profile under the Authentication tab](https://east1.openhosting.com/accounts/profile/#auth). Put this into
`~/.bashrc` to load these automatically.

```
$ gem install openhosting
$ export OHAUTH=<userid>:<secret key>
```

From there, establish a connection to the API like so

```
require 'openhosting'
oh = Openhosting.new
```

From here, you can pass around the connection to other objects.

## Drives
### Create a drive

```
drives = OHDrives.new(oh)
drive = OHDrive.new("Foo", "1G")
foo_drive = drives.create drive
```

The drive API supports advanced methods not available through the web GUI. They
are:

"avoid": when set to a list of drive UUIDs, weight the load balancing algorithm
to ensure this drive is created on different physical storage than those in the
list

"encryption:cipher": Open Hosting drives are transparently encrypted by
default. If this value is set to "none" it will bypass the encryption.

### Uploading and Downloading

The API supports the upload and download of raw data to and from your local
disk. This can be used for many things, including the upload of a raw QEMU
image to boot into a Virtual Machine. This is also useful for backing up the
binary data of a drive that isn't mounted.

## Servers

```
servers = OHServers.new(oh)
server = OHServer.new("Foo",1500,1024,{"nic:0:dhcp" => "auto", "vnc" => "auto", "password" => "changeme" })
foo_server = servers.create server, false
```

This will create a persistent server named Foo with no drives attached in the
stopped state. The second required argument to `OHServer#new` determines if the
server is persistant or not. It should usually be true. The second argument to
OHServers#create determines if the server should be started on creation. This
is also useful for autoscaling setups.

To get it to boot, you'll have to create an an empty drive and use the image
method to copy a prebuilt image into it. The following will do that for the
Debian 7 prebuilt, using the above new drive creation semantics.

```
source = "2e4a8cc1-734e-465a-8f27-889baffd4e56"
drives.image foo_drive['drive'], source
drives.info source['drive']
```

When it's done imaging, you can attach it to the server and start it up.

```
servers.set foo_server['server'], {"ide:0:0" => foo_drive['drive'], "boot" => "ide:0:0"}
servers.start foo_server['server']
```

You'll get "imaging" => true and a bunch of other options about it being
claimed.

The server API supports more options than available through the GUI
control panel. Notably you can set a Virtual Machine to be non-persistant so
that it is automatically destroyed when stopped. With this option it is
possible to implement auto-scaling infrastructure. 

It also gives you the option to influence the load balancing algorithm to
determine the physical infrastructure where your servers and drives are located.
This can be used for Virtual Machines which are expected to have heavy load, so
they are evenly spread out over the physical infrastructure.

You can also set the MAC address of the optional NICs 1 through 3.

## Resources
### List all resources

```
resources = OHResources.new(oh)
all_resources = resources.list
```

The resources are defined by their type. There are only two resource types at
the moment, "ip" and "vlan".

Each resource requires a name, though only the vlan resource shows this name
through any meaningful interface. It appears that the ip resource automatically
assigns a two letter name when an object of this type is created through the
web GUI.

Each resource type has extended metadata associated with it. This information
is acquired through the "info" verb. An individual resource requires a location
that resembles this:

```
conn.get '/resources/#{type}/#{resource}/info'
```

Where the resource value is the "resource" key in the output of the
`/resources/list` method. That means an IP address for the ip type and a UUID
of a vlan for that type. *Very confusing!*

## Testing

This library intends to have a full set of tests which operate on mocks and stubs. HTTP
request mocks are generated with [Webmock](https://github.com/bblimke/webmock).
Fixtures are generated with the [VCR framework](https://github.com/vcr/vcr).
Unit tests are done with [Minitest](https://github.com/seattlerb/minitest),
which is built into Ruby > 1.8.

The basic test architecture is based on [an
article](http://code.tutsplus.com/tutorials/writing-an-api-wrapper-in-ruby-with-tdd--net-23875)
by [Claudio Ortolina](http://tutsplus.com/authors/claudio-ortolina)
