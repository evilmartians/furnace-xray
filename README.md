# Furnace X-Ray

Furnace X-Ray is a visualizer for transformations performed on Static Single
Assignment form in the [Furnace][] framework.

  [Furnace]: http://github.com/whitequark/furnace

## Installation

    $ gem install furnace-xray

## Usage

First, you need to enable instrumentation for the functions you want to
observe. Here is a sample snippet:

``` ruby
mod = SSA::Module.new

fun = SSA::Function.new('my-function')

# It is important to enable instrumentation before doing anything else
# with the function. Otherwise, the collected data will be invalid.
fun.instrumentaiton = SSA::EventStream.new
mod.add fun

# Optionally, notify the instrumentation engine that you have started
# a transformation.
fun.instrumentation.transform_start "Set return type"

# Now, do whatever you want with the function.
fun.return_type = SSA.void_type

# After you have finished transforming functions, fetch the instrumentation
# data and dump it as JSON.
File.write("data.json", JSON.dump(mod.instrumentation))
```

To view collected data, just point furnace-xray to it:

    $ furnace-xray data.json
    [2013-01-27 20:05:13] INFO  WEBrick 1.3.1
    [2013-01-27 20:05:13] INFO  ruby 1.9.3 (2012-04-20) [x86_64-linux]
    == Sinatra/1.3.3 has taken the stage on 4567 for development with backup from WEBrick
    [2013-01-27 20:05:13] INFO  WEBrick::HTTPServer#start: pid=28695 port=4567

Now, open your ~~browser~~ Chrome or Chromium and point it to
http://localhost:4567.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
