#!/usr/bin/env ruby

require 'open3'
require 'time'

FileInfo = Data.define(:path, :created_at) do
  def extension
    File.extname(path).downcase
  end
end

class FileRename
  attr_reader :old_path, :new_dir, :new_file_name

  def initialize(old_path:, new_dir:, new_file_name:)
    @old_path = old_path
    @new_dir = new_dir
    @new_file_name = new_file_name
  end

  def new_path
    File.join(new_dir, new_file_name)
  end

  def new_temporary_path
    File.join(new_dir, "temp_#{new_file_name}")
  end

  def puts_rename(include_new_dir: true)
    if include_new_dir
      puts "  #{old_path} -> #{new_path}"
    else
      puts "  #{old_path} -> #{new_file_name}"
    end
  end

  def process(to_temporary: false, from_temporary: false)
    raise 'use only one flag' if to_temporary && from_temporary

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
  EXTENSIONS = %w[avi heic jpeg jpg mov mp4 mpg mts png]

  attr_reader :dir, :after_date

  def initialize(dir:, after_date: nil)
    @dir = dir
    @after_date = after_date
  end

  def process
    puts_file_renames

    if file_renames.any? && apply_renames?
      if collisions?
        puts 'Renaming with temporary files'
        file_renames.each { |file_rename| file_rename.process(to_temporary: true) }
        file_renames.each { |file_rename| file_rename.process(from_temporary: true) }
      else
        file_renames.each(&:process)
      end

      puts 'Done'
      true
    else
      false
    end
  end

  private

  def creation_time(file)
    # Using exiftool to extract time information
    # This may fail with a lot of files open (more than 256)
    #   In the terminal, set "ulimit -n 1000" top allow opening more files
    extracted_info = Open3.popen2('exiftool', '-s3', '-DateTimeOriginal', '-OffsetTimeOriginal', '-MDItemContentModificationDate', '-d', '%Y-%m-%d %H:%M:%S', file)[1].read
    Time.parse(extracted_info).localtime('-01:00')
    # TODO: when info is not present
  end

  def files
    @files ||= Dir.glob(File.join(dir, "*.{#{(EXTENSIONS + EXTENSIONS.map(&:upcase)).join(',')}}"))
  end

  def photos
    @photos ||= begin
      photos_list = files.map do |file|
        created_at = creation_time(file)
        FileInfo.new(path: file, created_at: created_at) if after_date.nil? || created_at.to_date > after_date
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

        new_name = "#{current_date}-#{format('%03d', index)}#{photo.extension}"
        FileRename.new(old_path: photo.path, new_dir: dir, new_file_name: new_name)
      end
    end
  end

  def puts_file_renames
    if file_renames.any?
      puts 'File renames:'
      file_renames.each { |file_rename| file_rename.puts_rename(include_new_dir: false) }
      puts 'Collisions detected, will rename with temporary files' if collisions?
    else
      puts 'No files to rename.'
    end
  end

  def apply_renames?
    printf "\nRename? (press 'y' to continue) "
    $stdin.gets.chomp.casecmp('y').zero?
  end

  def collisions?
    (file_renames.map(&:old_path) & file_renames.map(&:new_path)).any?
  end
end

# run rename in current folder
RenamePhotos.new(dir: Dir.pwd).process
