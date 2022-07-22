module WebActions
  
  def click
    self.wait_for_element
    self.element.click
  rescue => e
    raise "Unable to click element: (#{@how}, #{@what})' \n\n Trace: #{e.message}"
  end

  def fill(value, clear = true)
    self.wait_for_element
    self.element.clear if clear
    self.element.send_keys value
  rescue => e
    raise e
  end

  def click_button(name, timeout = 15)
    $driver.find_element(:xpath, "(//button[text()='#{name}' and not(contains(@class, 'disabled'))]) | (//button//p[text()='#{name}' and not(contains(@class, 'disabled'))])").click
  end

  def snap_screenshot(ann_var)
    unless ann_var.exception.nil?
      begin
        File.exist?('./Screenshots') ? 0 : (Dir.mkdir './Screenshots')
        ann_var.add_attachment(name: 'screenshot', source: File.new($driver.save_screenshot(File.join(Dir.pwd, "Screenshots/#{Time.new.strftime("%Y-%m-%d-%H-%M-%S")}.png"))), type: Allure::ContentType::PNG)
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
  end

  def navigate_to(url)
    $driver.get(url)
  end

  def wait_for_element(timeout = nil)
    @wait = timeout.nil? ? $global_wait : Selenium::WebDriver::Wait.new(timeout: timeout)
    @wait.until { self.element }
    true
  rescue => e
    raise "Timeout Exception for '(#{@how}, #{@what})' \n\n Trace: #{e.message}"
  end

  def quit_browser
    $driver.quit
  end

  def switch_to_last_tab
    $driver.switch_to.window($driver.window_handles.last)
  end

  def wait_until_url_changes
    current_url = $driver.current_url
    wait = Selenium::WebDriver::Wait.new(timeout: 30)
    begin
      wait.until { current_url != $driver.current_url }
    rescue Exception => e
      p e.message
    end
  end

  def fetch_elements
    @exception_count = 0
    begin
      elements = $driver.find_elements(@how, @what)
      elements.map{|elem| Locator.new(nil,nil, nil,elem)}
    rescue => e
      @exception_count += 1
      sleep 1
      if @exception_count == 3
        p "Unable to find elements (#{@how}, #{@what})"
      end
      retry if @exception_count < 3
    end
  end

  def is_displayed?(timeout = nil)
    @wait = timeout.nil? ? $global_wait : Selenium::WebDriver::Wait.new(timeout: timeout)
    @wait.until { self.element }
    @wait.until { self.element.displayed? }
    true
  rescue
    false
  end

  def get_texts
    return_value = []
    self.fetch_elements.each do |x|
      return_value << x.text
    end
    return_value
  end

  def check_element_visibility(value, time_out = 10)
    Utilities::Locator.new(:xpath, "//*[contains(text(), '#{value}')]").is_displayed?(time_out)
  end

  def current_url
    $driver.current_url
  end

  def close_tab
    $driver.close
    $driver.switch_to.window($driver.window_handles.last)
  end

end