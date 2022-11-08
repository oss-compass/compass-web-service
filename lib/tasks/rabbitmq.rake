desc "Run all of your sneakers tasks"
namespace :rabbitmq do
  task :start => :environment do
    Rake::Task["sneakers:run"].invoke
    puts "Started sneakers workers"
  end

  task :stop => :environment do
    if File.exist?('tmp/pids/sneakers.pid')
      `kill -15 #{File.read('tmp/pids/sneakers.pid')}`
      puts "Stopped sneakers workers"
    else
      puts "Failed to stop sneakers, maybe already exited."
    end
  end

  task :restart => :environment do
    Rake::Task['rabbitmq:stop'].invoke
    Rake::Task['rabbitmq:start'].invoke
  end
end
