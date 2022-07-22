require 'selenium-webdriver'
require 'require_all'
require 'pathname'
require 'rspec'
require 'date'
require 'yaml'
require 'allure-rspec'
require 'creek'
require 'faker'
require 'os'
require 'rspec/retry'
require 'pry'
require 'ruby-debug-ide'
require 'debase'
require 'time_diff'

require_all 'Pages'
require_all 'Utilities'

include WebActions

# require_all 'Lib'
failed_ex_file = 'examples.txt'


$conf = YAML.load_file("#{Pathname.pwd}/testdata/properties.yml")
$download_path = "#{Pathname.pwd}/test-data/downloaded"
FileUtils.rm_rf Dir.glob("#{$download_path.to_s}/*") if File.directory?($download_path)
FileUtils.rm_rf Dir.glob("./Screenshots") if File.directory?("./Screenshots")


RSpec.configure do |c|
  c.formatter = AllureRspecFormatter
  c.example_status_persistence_file_path = failed_ex_file
  c.after(:suite) do
    env_variables_generator
    $gmail_helper&.sign_out_instance
  end
end

AllureRspec.configure do |c|
  (File.exist? './Report') ? 0 : (Dir.mkdir './Report')
  c.results_directory = './Report' # default: gen/allure-results

  c.clean_results_directory = !([@spec_opts, ARGV[-1]].include? '--only-failures') # clean the output directory first? (default: true)
  c.logging_level = Logger::DEBUG # logging level (default: INFO)
end


def env_variables_generator
  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.environment do
      xml.parameter do
        xml.key 'Browser'
        xml.value $conf['browser'].capitalize.to_s
      end
    end
  end
  xml_content = builder.to_xml

  file = File.open("#{Pathname.pwd}/Report/environment.xml", 'w')
  file.puts(xml_content)
  file.close
end
