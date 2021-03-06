# Copyright 2013 Mike Ragalie
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Current execution times:
# Without rxjava-jruby: 3.31s
# With rxjava-jruby: 2.18s

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: jruby --profile.api performance.rb [options]"

  opts.on("-c", "--core CORE-PATH", "Path to the rxjava-core.jar") {|core| options[:core] = core}
  opts.on("-j", "--jruby [JRUBY-PATH]", "Path to the rxjava-jruby.jar (optional)") {|jruby| options[:jruby] = jruby}
end.parse!

require options[:core]

if options[:jruby]
  require options[:jruby]
  require 'rx/lang/jruby/interop'
end

require 'jruby/profiler'

profile_data = JRuby::Profiler.profile do
  10000.times do
    o = Java::Rx::Observable.create do |observer|
      observer.onNext("one")
      observer.onNext("two")
      observer.onNext("three")
      observer.onCompleted
      Java::RxSubscriptions::Subscription.empty
    end
    o.map {|n| n * 2}.subscribe {|n| n}
  end
end

profile_printer = JRuby::Profiler::FlatProfilePrinter.new(profile_data)
profile_printer.printProfile(STDOUT)
