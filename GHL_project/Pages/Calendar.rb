module Pages
  class Calendar

    def initialize(driver)
      @driver = driver

    end

    def click_side_tab(tab_name)
      ele = Utilities::Locator.new(:xpath, "//*[contains(text(), '#{tab_name}')]/ancestor::a")
      ele.click
    end

    def click_links(sec_name)
      ele = Utilities::Locator.new(:xpath, "//*[contains(text(), '#{sec_name}')]/ancestor::a")
      ele.click
    end

    def open_calendar(calendar_name)
      ele = Utilities::Locator.new(:xpath, "//span[contains(text() ,  '#{calendar_name}')]/../ancestor::div[contains(@class, 'card--service')]//button[contains(@class, 'btn-link')]")
      ele.click
      switch_to_last_tab
      current_url.include?('widget')
    end

    def book_appointment(hash, time_zone)
      select_time_zone(time_zone)
      sleep 2
      hash['slot'] = fetch_time_slot
      hash.each do |key, value|
        ele = Utilities::Locator.new(:xpath, "//td[@data-id= '#{value}'] | //span[text() =  '#{value}']")
        ele.click
      end

      click_button('Continue')
      hash['slot']
    end

    def select_time_zone(zone)
      Utilities::Locator.new(:xpath, "//*[@class = 'multiselect__single']").click
      Utilities::Locator.new(:xpath, "//span[text() = '#{zone}']/../ancestor::li").click
    end

    def fetch_time_slot
      $driver.find_elements(:xpath, "//li[contains(@class, 'time-slot')]/span").map {|ele| ele.text}.sample
    end

    def fill_form(hash)
      hash.each do |k , v|
        Utilities::Locator.new(:xpath, "//label[contains(text() , '#{k}')]/..//input | //label[contains(text() , '#{k}')]/..//textarea").fill(v)
      end
    end

    def click_goback
      Utilities::Locator.new(:xpath, "//*[contains(text(), 'Go Back')]").click
    end

    def fetch_appointment_time(patient_name)
      ele = $driver.find_elements(:xpath, "//h4[text() = '#{patient_name}']/ancestor::tr//td")
      values =[]
      ele.each do |e|
        values << e.text
      end
      values[2]
    end
    
  end
end