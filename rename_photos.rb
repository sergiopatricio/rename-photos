#!/usr/bin/env ruby

require "open3"
require "time"

class Photo
  attr_accessor :path
  attr_accessor :created_at

  def initialize(path:, created_at:)
    self.path = path
    self.created_at = created_at
  end

  def extension
    File.extname(path).downcase
  end
end

class FileRename
  attr_accessor :old_path
  attr_accessor :new_dir
  attr_accessor :new_file_name

  def initialize(old_path:, new_dir:, new_file_name:)
    self.old_path = old_path
    self.new_dir = new_dir
    self.new_file_name = new_file_name
  end

  def new_path
    File.join(new_dir, new_file_name)
  end

  def new_temporary_path
    File.join(new_dir, "temp_#{new_file_name}")
  end

  def puts_rename(include_new_dir: true)
    if include_new_dir
      puts "#{old_path} -> #{new_path}"
    else
      puts "#{old_path} -> #{new_file_name}"
    end
  end

  def process(to_temporary: false, from_temporary: false)
    raise "use only one flag" if to_temporary && from_temporary

    if to_temporary
      File.rename(old_path, new_temporary_path)
    elsif from_temporary
      File.rename(new_temporary_path, new_path)
    else
      File.rename(old_path, new_path)
    end
  end
end

class RenamePhotos
  attr_accessor :dir, :after_date

  def initialize(dir:, after_date: nil)
    self.dir = dir
    self.after_date = after_date
  end

  def process
    puts_file_renames

    if file_renames.any? && apply_renames?
      if collisions?
        puts "Renaming with temporary files"
        file_renames.each{ |file_rename| file_rename.process(to_temporary: true) }
        file_renames.each{ |file_rename| file_rename.process(from_temporary: true) }
      else
        file_renames.each(&:process)
      end

      puts "Done"
      true
    else
      false
    end
  end

  private

  def creation_time(file)
    # mdls is Mac OS specific
    Time.parse(Open3.popen2("mdls", "-name", "kMDItemContentCreationDate", "-raw", file)[1].read)
  end

  def files
    @files ||= Dir.glob(File.join(dir, "*.{jpg,jpeg,png,heic,mts,mp4,mpg,avi,mov}"), File::FNM_CASEFOLD)
  end

  def photos
    @photos ||= begin
      photos_list = files.map do |file|
        created_at = creation_time(file)
        if after_date.nil? || created_at.to_date > after_date
          Photo.new(path: file, created_at: created_at)
        end
      end

      photos_list.compact.sort_by { |photo| [photo.created_at, photo.path] }
    end
  end

  def file_renames
    @file_renames ||= begin
      index = 1
      previous_date = nil
      photos.map do |photo|
        current_date = photo.created_at.to_date
        if current_date != previous_date
          index = 1
          previous_date = current_date
        else
          index += 1
        end

        new_name = "#{current_date.to_s}-#{"%03d" % index}#{photo.extension}"
        FileRename.new(old_path: photo.path, new_dir: dir, new_file_name: new_name)
      end
    end
  end

  def puts_file_renames
    if file_renames.any?
      puts "File renames:"
      file_renames.each { |file_rename| file_rename.puts_rename(include_new_dir: false) }
      puts "Collisions detected, will rename with temporary files" if collisions?
    else
      puts "No files to rename."
    end
  end

  def apply_renames?
    printf "\nRename? (press 'y' to continue) "
    STDIN.gets.chomp.downcase == 'y'
  end

  def collisions?
    (file_renames.map(&:old_path) & file_renames.map(&:new_path)).any?
  end
end

# run rename in current folder
RenamePhotos.new(dir: Dir.pwd).process
