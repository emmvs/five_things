# frozen_string_literal: true

namespace :assets do
  desc 'Generate PWA icons in multiple sizes from source image'
  task copy_icons: :environment do
    require 'fileutils'
    require 'mini_magick'

    source = Rails.root.join('app/assets/images/five.png')

    # Warn if source file doesn't exist
    unless File.exist?(source)
      puts "❌ Source image not found: #{source}"
      puts 'Please ensure app/assets/images/five.png exists and is at least 512x512px'
      exit 1
    end

    # Check source image dimensions
    image = MiniMagick::Image.open(source)
    if image.width < 512 || image.height < 512
      puts "⚠️  Warning: Source image is #{image.width}x#{image.height}. Recommended minimum is 512x512px"
    end

    # Define icon sizes: [destination_path, size]
    icons = [
      [Rails.root.join('public/apple-touch-icon.png'), 180],
      [Rails.root.join('public/apple-touch-icon-precomposed.png'), 180],
      [Rails.root.join('public/icon-192.png'), 192],
      [Rails.root.join('public/icon-512.png'), 512]
    ]

    icons.each do |dest, size|
      resized_image = MiniMagick::Image.open(source)
      resized_image.resize "#{size}x#{size}"
      resized_image.write(dest)
      puts "✅ Generated #{dest.basename} (#{size}x#{size})"
    end

    puts "\n🎉 PWA icons updated successfully!"
  end
end
