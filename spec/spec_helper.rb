$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kiji'
require 'pry'
require 'dotenv'
require 'zip'
Dotenv.load

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options  = {
    re_record_interval: 60 * 60 * 24 # 1 day
  }
end

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end
  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir)
    entries.delete('.DS_Store')
    entries.delete('.')
    entries.delete('..')
    io = Zip::File.open(@output_file, Zip::File::CREATE)
    write_entries(entries, '', io)
    io.close
  end
  # A helper method to make the recursion work.

  private

  def write_entries(entries, path, io)
    entries.each do |e|
      zip_file_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zip_file_path)
      # puts 'Deflating ' + disk_file_path
      if File.directory?(disk_file_path)
        # io.mkdir(zip_file_path)
        subdir = Dir.entries(disk_file_path)
        subdir.delete('.DS_Store')
        subdir.delete('.')
        subdir.delete('..')
        write_entries(subdir, zip_file_path, io)
      else
        io.get_output_stream(zip_file_path) { |f| f.print(File.open(disk_file_path, 'rb').read) }
      end
    end
  end
end
