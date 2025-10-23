# frozen_string_literal: true

namespace :assets do
  desc 'Copy PWA icons to public folder'
  task copy_icons: :environment do
    require 'fileutils'
    
    source = Rails.root.join('app/assets/images/five.png')
    destinations = [
      Rails.root.join('public/apple-touch-icon.png'),
      Rails.root.join('public/apple-touch-icon-precomposed.png'),
      Rails.root.join('public/icon-192.png'),
      Rails.root.join('public/icon-512.png')
    ]
    
    destinations.each do |dest|
      FileUtils.cp(source, dest)
      puts "✅ Copied #{source.basename} to #{dest.basename}"
    end
    
    puts "\n🎉 PWA icons updated successfully!"
  end
end
