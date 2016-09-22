namespace :report do

  task :revenue => :environment do
    require 'capybara/poltergeist'
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.default_driver = :poltergeist
    browser = Capybara.current_session
    browser.visit 'http://www.newsletterdirectory.co/log-in/'
    browser.fill_in 'email', with: 'matt@assemblymade.com'
    browser.fill_in 'password', with: ''
    browser.click_on 'logInButton'
    puts browser.current_url
    browser.visit "http://www.newsletterdirectory.co/manage-text-adzone/?adzone=11384"
    puts browser.current_url

    labels = browser.all('.adzonestats .grid_4').collect{|div| div.text}
    values = browser.all('.adzonestats .grid_2').collect{|div| div.text}
    labels.each_with_index do |label, index|
      puts "#{label}: #{values[index]}"
    end
  end

end
