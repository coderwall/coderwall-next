namespace :report do

  task :revenue => :environment do
    # https://github.com/stomita/heroku-buildpack-phantomjs
    require 'capybara/poltergeist'
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.default_driver = :poltergeist
    browser = Capybara.current_session

    browser.visit 'https://www.newsletterdirectory.co/log-in/'
    browser.find('#email').set('matt@assemblymade.com')
    browser.find('#password').set(ENV['SPONSOR_PWD'])
    sleep 2
    browser.find("#logInButton").trigger('click')
    sleep 2
    browser.visit "https://www.newsletterdirectory.co/manage-text-adzone/?adzone=11384"

    labels = browser.all('.adzonestats .grid_4').collect{|div| div.text}
    values = browser.all('.adzonestats .grid_2').collect{|div| div.text}
    report = [
      "Sponsor Revenue Performance",
      "#{values[0]} Avg CTR",
      "#{values[1]} Pending Monthly Earnings",
      "#{values[2]} Last Month's Earnings"
    ].join("\n")

    Slack.notify!(':moneybag:', report) if Rails.env.production?
    puts report
  end

end
