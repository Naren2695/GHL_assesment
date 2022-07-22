module Pages
  class Login

    def initialize(driver)
      @driver = driver

      @username = Utilities::Locator.new(:xpath, "//input[@placeholder = 'Your email address']")
      @password = Utilities::Locator.new(:xpath, "//input[@placeholder = 'The password you picked']")
    end

    def login(username, password)
      navigate_to($conf['app_url'])
      @username.fill(username)
      @password.fill(password)
      click_button('Sign in')
      wait_until_url_changes
    end
  end
end