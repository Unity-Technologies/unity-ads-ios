require 'bundler'
Bundler.require(:default)

INFO_PLIST_PATH = 'UnityAdsExample/Info.plist'
INFO_PLIST_ATS_KEY = 'NSAppTransportSecurity'
INFO_PLIST_ATS_EXCEPTION_DOMAINS_KEY = 'NSExceptionDomains'
INFO_PLIST_ATS_EXCEPTION_DOMAINS_INCLUDES_SUBDOMAINS_KEY = 'NSIncludesSubdomains'
INFO_PLIST_ATS_EXCEPTION_DOMAINS_ALLOW_HTTP_REQUESTS_KEY = 'NSTemporaryExceptionAllowsInsecureHTTPLoads'
INFO_PLIST_UADS_TEST_SERVER_ADDRESS_KEY = "UADSTestServerAddress"

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

  def set_server(server_address, port)
    plist_entry_hash = {INFO_PLIST_ATS_EXCEPTION_DOMAINS_KEY => {server_address =>
          {INFO_PLIST_ATS_EXCEPTION_DOMAINS_INCLUDES_SUBDOMAINS_KEY => true,
            INFO_PLIST_ATS_EXCEPTION_DOMAINS_ALLOW_HTTP_REQUESTS_KEY => true}}}

    @info_plist_hash[INFO_PLIST_ATS_KEY] = plist_entry_hash
    test_server_address = "http://#{server_address}#{":#{port}" if port}"
    @info_plist_hash[INFO_PLIST_UADS_TEST_SERVER_ADDRESS_KEY] = test_server_address
  end

  def clear
    @info_plist_hash.delete(INFO_PLIST_UADS_TEST_SERVER_ADDRESS_KEY)
    @info_plist_hash.delete(INFO_PLIST_ATS_KEY)
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
  opt :server, "Set test-server address (for example: terminal.applifier.info (no leading 'http://'))", :type => :string
  opt :port, "Set test-server port", :type => :int
  opt :clear, "Clear testing entries from plist"
end

if opts[:clear]
  ip = InfoPlist.new(INFO_PLIST_PATH)
  ip.clear
  ip.to_file
  exit
end

if opts[:server]
  ip = InfoPlist.new(INFO_PLIST_PATH)
  ip.set_server(opts[:server], opts[:port])
  ip.to_file
else
  Optimist::die "Please set server-address"
end
