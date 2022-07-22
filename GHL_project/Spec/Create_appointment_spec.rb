require './spec_helper'

describe 'Calendar Appointment schedule:', :Calendar do
  before(:all) do
  end

  before(:each) do
    @driver = Utilities::Browser.new($conf['browser']).invoke

    @login_page = Pages::Login.new(@driver)
    @calandar_page = Pages::Calendar.new(@driver)
  end

  after(:each) do |e| # Captures screenshot of the current page when failure happens
    snap_screenshot(e)
    quit_browser
  end

  after(:all) do
  end

  it 'Create appointment for patient' do |e|

    e.run_step 'Patient logging in' do
      @login_page.login($conf['users']['email'], $conf['users']['password'])
    end

    e.run_step 'Patient redirecting to book the appointment' do
      @calandar_page.click_side_tab('Settings')
      sleep 2
      @calandar_page.click_side_tab('Calendars')
      expect(@calandar_page.open_calendar($conf['calendar_name'])).to eq true
    end
    
    e.run_step 'Patient scheduling the appointment' do 
      appointment_details = {
        'date' => Date.today.strftime('%Y-%-m-%d'),
      }
      @time_zone = ['GMT-07:00 America/Tijuana (PDT)', 'GMT-07:00 America/Dawson (GMT-7)', 'GMT-06:00 America/Boise (MDT)',
                    'GMT-06:00 America/Edmonton (MDT)', 'GMT-06:00 America/Guatemala (CST)'].sample

      @slot_booked = @calandar_page.book_appointment(appointment_details, @time_zone)
      expect(check_element_visibility('Enter Your Information')).to eq true
    end

    e.run_step 'Patient adding the information' do
      @patient_details = {
        'First Name' => "#{Faker::Name.first_name}".delete("'"),
        'Last Name' =>  "#{Faker::Name.last_name}".delete("'"),
        'Phone' => "98765#{rand(12_345..99_999)}",
        'Email' => "#{Faker::Name.first_name[0..5].downcase}#{rand(12_345..99_999)}@yopmail.com",
        'Additional Information' => Faker::Quote.matz
      }

      @calandar_page.fill_form(@patient_details)
      click_button('Schedule Meeting')
      expect(check_element_visibility('Your Meeting has been Scheduled')).to eq true
    end

    e.run_step 'verify the created appointment in calendar' do
      time_diff = @time_zone.split(':')[0].delete('GMT')
      time_booked = Time.strptime(@slot_booked, "%I:%M %P").strftime("%H:%M")
      scheduled_time = Date.today.strftime("%d-%m-%Y #{time_booked}:00 #{time_diff}:00")
      exp_ist = DateTime.parse(scheduled_time).in_time_zone('Mumbai').strftime("%b %d %Y, %H:%M %P")
      close_tab
      @calandar_page.click_goback
      @calandar_page.click_side_tab('Calendars')
      @calandar_page.click_links('Appointments')
      sleep 5
      expect(@calandar_page.fetch_appointment_time("#{@patient_details['First Name']} #{@patient_details['Last Name']}")).to eq exp_ist
    end
  end
end
