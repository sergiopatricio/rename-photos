#!/usr/bin/env ruby

require "open3"
require "time"

class Photo
  attr_accessor :file
  attr_accessor :extension
  attr_accessor :created_at

  def initialize(params)
    self.file = params[:file]
    self.extension = params[:extension]
    self.created_at = params[:created_at]
  end
end

def creation_time(file)
  # mdls is Mac OS specific
  Time.parse(Open3.popen2("mdls", "-name", "kMDItemContentCreationDate", "-raw", file)[1].read)
end

def read_photos(dir)
  files = Dir.glob(File.join(dir, "*.{jpg,JPG,mts,MTS,mp4,MP4}"))

  photos = files.map do |file|
    params = {
      :file => file,
      :extension => File.extname(file).downcase,
      :created_at => creation_time(file)
    }
    Photo.new(params)
  end

  photos.sort_by! { |photo| photo.created_at }
end


def rename_photos(options)
  puts options[:test] ? "Running in test mode" : "Renaming files..."

  photos = read_photos(options[:dir])

  if options[:after]
    after_date = Date.parse(options[:after])
    photos = photos.reject { |photo| photo.created_at.to_date <= after_date }
  end

  index = 0
  previous_date = nil
  photos.each do |photo|
    current_date = photo.created_at.to_date
    if current_date != previous_date
      index = 0
      previous_date = current_date
    else
      index += 1
    end

    new_name = "#{current_date.to_s}-#{"%03d" % (index + 1)}#{photo.extension}"

    # puts "#{photo.file} -> #{File.join(options[:dir], new_name)}"
    puts "#{photo.file} -> #{new_name}"

    unless options[:test]
      File.rename(photo.file, File.join(options[:dir], new_name))
    end
  end

  nil
end


# run ruby script in current folder
current_dir = Dir.pwd
rename_photos({ :dir => current_dir, :test => ARGV[0] == "-test" })
