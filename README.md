# GHL workflow
Automation repository for GHL workflow.

## Setup:
  * Install Ruby(> 2.3.0)
  * Install Bundler
  * Download ChromeDriver(>= 2.46) and place it under '/usr/local/bin'
  * Clone the repo and get into the parent folder in Terminal
  * Run 'bundle install'
  * Install Allure command line tools

 ## Execution:
  * Navigate to the parent folder from Terminal
 To run all specs sequentially,

>     rspec <spec-folder> / <spec_file-name.rb> 
example: `rspec Spec/Create_appointment_spec.rb`


 ## Generating reports:
  * Wait for the tests gets executed successfully
  * Run `allure generate Report --clean`
  * Run `allure serve report` (This will open a reports in your default browser's tab)
  * `ctrl + c` to kill serving.
