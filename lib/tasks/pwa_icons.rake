# frozen_string_literal: true

namespace :assets do
  desc 'Copy PWA icons to public folder'
  task copy_icons: :environment do
    require 'fileutils'

    # NOTE: This task copies the source image as-is without resizing.
    # Ensure your source image (app/assets/images/five.png) is at least 512x512px
    # for best quality across all icon sizes.
    # For production, consider using ImageMagick or similar to generate properly sized icons.
    source = Rails.root.join('app/assets/images/five.png')

    # Warn if source file doesn't exist
    unless File.exist?(source)
      puts "❌ Source image not found: #{source}"
      puts 'Please ensure app/assets/images/five.png exists and is at least 512x512px'
      exit 1
    end

    destinations = [
      Rails.root.join('public/apple-touch-icon.png'), # 180x180 (iOS)
      Rails.root.join('public/apple-touch-icon-precomposed.png'), # 180x180 (iOS)
      Rails.root.join('public/icon-192.png'),                  # 192x192 (Android)
      Rails.root.join('public/icon-512.png')                   # 512x512 (Android)
    ]

    destinations.each do |dest|
      FileUtils.cp(source, dest)
      puts "✅ Copied #{source.basename} to #{dest.basename}"
    end

    puts "\n🎉 PWA icons updated successfully!"
  end
end
