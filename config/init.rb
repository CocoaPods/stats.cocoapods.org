# -- General ------------------------------------------------------------------

ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(ROOT, 'lib')

# -- Logging ------------------------------------------------------------------

require 'logger'
require 'fileutils'

if ENV['STATS_APP_LOG_TO_STDOUT']
  STDOUT.sync = true
  STDERR.sync = true
  STATS_APP_LOGGER = Logger.new(STDOUT)
  STATS_APP_LOGGER.level = Logger::INFO
else
  FileUtils.mkdir_p(File.join(ROOT, 'log'))
  STATS_APP_LOG_FILE = File.new(File.join(ROOT, "log/#{ENV['RACK_ENV']}.log"), 'a+')
  STATS_APP_LOG_FILE.sync = true
  STATS_APP_LOGGER = Logger.new(STATS_APP_LOG_FILE)
  STATS_APP_LOGGER.level = Logger::DEBUG
end

# -- Console ------------------------------------------------------------------

if defined?(IRB)
  puts "[!] Loading `#{ENV['RACK_ENV']}' environment."
  Dir.chdir(ROOT) { require 'app/models' }
end
