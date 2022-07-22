require 'selenium-webdriver'
require 'os'

module Utilities
  class Browser
    attr_reader :browser, :download_path

    def initialize(browser, download_path = nil)
      @browser = browser.downcase
      @download_path = download_path
      $network_logs = {}
    end

    def invoke
      headless = ENV['headless'].nil? ? false : ENV['headless'].to_s.downcase == 'true'
      skip_pdf = ENV['skip_pdf_externally'].nil? ? false : ENV['skip_pdf_externally'].to_s.downcase == 'true'
      download_path = @download_path.nil? ? "#{Dir.pwd}/test-data/downloaded" : @download_path

      case browser
      when 'chrome'
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps['goog:chromeOptions'] = {
          'prefs' => {
            'download.default_directory' => download_path,
            'download.prompt_for_download' => false
          },
          'args' => [
            'disable-dev-shm-usage',
            'no-sandbox',
            'disable-popup-blocking',
            'window-size=1400,900',
            'disable-extensions',
            'disable-gpu',
            '--disable-notifications'
          ]
        }
        caps['goog:chromeOptions']['args'] << 'headless' if headless == true || OS.linux?
        caps['goog:chromeOptions']['prefs']['plugins.always_open_pdf_externally'] = true unless skip_pdf
        p 'Tarspect running thru this'
        $driver = Selenium::WebDriver.for :chrome, capabilities: caps
        $global_wait = Selenium::WebDriver::Wait.new(timeout: 30)        

        bridge = $driver.send(:bridge)
        path = '/session/:session_id/chromium/send_command'
        path[':session_id'] = bridge.session_id
        bridge.http.call(:post, path, {
                           'cmd' => 'Page.setDownloadBehavior',
                           'params' => {
                             'behavior' => 'allow',
                             'downloadPath' => download_path
                           }
                         })
        $driver
      when 'firefox'
        $driver = Selenium::WebDriver.for :firefox
        $driver
        # To be extended
      else
        raise 'Unsupported Browser type'
      end
    end
  end
end
