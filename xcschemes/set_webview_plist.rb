require 'bundler'
Bundler.require(:default)

INFO_PLIST_PATH = 'UnityAdsExample/Info.plist'
INFO_PLIST_WEBVIEW_KEY = 'UADSWebviewBranch'

class InfoPlist
  def initialize(file_path)
    @info_plist_path = file_path
    begin
      @info_plist_hash = Plist::parse_xml(file_path)
    rescue Exception => e
      puts "Cannot read plist from file '#{file_path}': #{e}"
      raise e
    end
  end

  def set_webview(webview_string)
    begin
      @info_plist_hash[INFO_PLIST_WEBVIEW_KEY] = webview_string
    rescue Exception => e
      puts "Unable to add webview '#{webview_string}' to key '#{INFO_PLIST_WEBVIEW_KEY}' in plist: #{e}"
      raise e
    end
  end

  def clear_webview
    @info_plist_hash[INFO_PLIST_WEBVIEW_KEY] && @info_plist_hash.delete(INFO_PLIST_WEBVIEW_KEY)
  end

  def list_current
    puts "#{@info_plist_hash[INFO_PLIST_WEBVIEW_KEY]}"
  end

  def to_file
    begin
      File.open(@info_plist_path, 'wb') do |fh|
        fh.write(@info_plist_hash.to_plist)
      end
    rescue Exception => e
      puts "Cannot write plist to file '#{@info_plist_path}': #{e}"
      raise e
    end
  end
end

# Handle command line arguments
opts = Optimist::options do
  opt :webview, "Webview that ads sdk will use in the build",
      :type => :string
end

webview = opts[:webview]

if !opts[:webview]
  Optimist::die "Webview not given, exiting"
  exit
end

ip = InfoPlist.new(INFO_PLIST_PATH)

ip.clear_webview
ip.set_webview(webview)
ip.to_file
