### Rename photos and video files
Ruby script to rename my photos/videos files to "YYYY-MM-DD-000" format using the file creation date.


#### Options
* :dir => the folder to search for files (Required)
* :after => only rename files with creation date after <:after> (Optional)
* :test => run in test mode (Optional)


#### Usage (ruby console)
    dir = "/Users/sergio/Downloads"

    # test mode
    rename_photos({ :dir => dir, :after => "2013-10-27", :test => true })
    rename_photos({ :dir => dir, :test => true })

    # rename!
    rename_photos({ :dir => dir, :after => "2013-10-27" })
    rename_photos({ :dir => dir })

#### Usage (shell script)
Make the script available on PATH, and then navigate to the desired folder, the script will rename photos in current folder

    # test mode
    rename_photos.rb -test

    # rename!
    rename_photos.rb

#### Samples
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
