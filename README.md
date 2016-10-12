### Rename photo and video files
Ruby script to rename my photo and video files to "YYYY-MM-DD-000" format using the file creation date.


#### Params
* dir:  the folder to search for files (Required)
* after_date: only consider files after this date (Optional)


#### Usage in ruby console
    RenamePhotos.new(dir: Dir.pwd).process
    RenamePhotos.new(dir: Dir.pwd, after_date: Date.today.prev_day).process


#### Usage in shell
Make the script available on the PATH, and then navigate to the desired folder, the script will rename photos in the current folder.

    rename_photos.rb

#### Sample
    File renames:
    /Users/sergio/Downloads/17102007154.jpg -> 2007-10-17-001.jpg
    /Users/sergio/Downloads/17102007156.jpg -> 2007-10-17-002.jpg
    /Users/sergio/Downloads/DP200094.JPG -> 2010-06-26-001.jpg
    /Users/sergio/Downloads/DSC00023.JPG -> 2011-07-31-001.jpg
    /Users/sergio/Downloads/DSC00024.JPG -> 2011-07-31-002.jpg
    /Users/sergio/Downloads/DSC00136.JPG -> 2011-08-07-001.jpg
    /Users/sergio/Downloads/DSC00345.JPG -> 2011-09-12-001.jpg
    /Users/sergio/Downloads/IMAG0023.jpg -> 2011-09-12-002.jpg
    /Users/sergio/Downloads/IMAG0013.jpg -> 2013-10-27-001.jpg
    /Users/sergio/Downloads/IMAG0014.jpg -> 2013-10-27-002.jpg
    /Users/sergio/Downloads/IMAG0015.jpg -> 2013-10-27-003.jpg
    /Users/sergio/Downloads/IMAG0016.jpg -> 2013-10-27-004.jpg

    Rename? (press 'y' to continue) y
    Done
