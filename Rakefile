desc 'Install the dependencies'
task :bootstrap do
  sh 'git submodule update --init'
  sh 'bundle install'
end

begin
  require 'rubygems'
  require 'bundler/setup'

  task :env do
    $LOAD_PATH.unshift(File.expand_path('../', __FILE__))
    require 'config/init'
  end

  task :rack_env do
    ENV['RACK_ENV'] ||= 'development'
  end

  task :update_stats do
    exec 'ruby app/stats_coordinator.rb'
  end

  desc 'Starts a interactive console with the model env loaded'
  task :console do
    exec 'irb', '-I', File.expand_path('../', __FILE__), '-r', 'config/init'
  end

  desc 'Starts processes for local development'
  task :serve do
    exec 'env PORT=4567 RACK_ENV=development foreman start'
  end

  desc 'Run the specs'
  task :spec do
    title 'Running the specs'
    sh "bacon #{FileList['spec/**/*_spec.rb'].shuffle.join(' ')}"

    # Sorry rubocop, orta doesn't care
    # title 'Checking code style'
    # Rake::Task[:rubocop].invoke
  end

  desc 'Use Kicker to automatically run specs'
  task :kick do
    exec 'bundle exec kicker -c'
  end

  desc 'Get stats for all pods'
  task :daily do
    exec 'bundle', 'exec', 'foreman', 'run', 'ruby', 'runner/daily_runner.rb', '-r', 'config/init'
  end

  task :default => :spec

rescue SystemExit, LoadError => e
  puts "[!] The normal tasks have been disabled: #{e.message}"
end

#-- UI ------------------------------------------------------------------------

def title(title)
  cyan_title = "\033[0;36m#{title}\033[0m"
  puts
  puts '-' * 80
  puts cyan_title
  puts '-' * 80
  puts
end
