# frozen_string_literal: true

namespace :db do
  desc 'Backup the development database'
  task backup: :environment do
    config = ActiveRecord::Base.configurations[Rails.env] || Rails.application.config.database_configuration[Rails.env]
    database = config['database']
    username = config['username']
    host = config['host'] || 'localhost'

    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    backup_dir = Rails.root.join('db', 'backups')
    FileUtils.mkdir_p(backup_dir)
    backup_file = backup_dir.join("#{database}_#{timestamp}.dump")

    command = "pg_dump -Fc --no-acl --no-owner -h #{host} -U #{username} #{database} > #{backup_file}"
    puts "Running command: #{command}"
    system(command)

    puts "Backup completed: #{backup_file}"
  end
end
