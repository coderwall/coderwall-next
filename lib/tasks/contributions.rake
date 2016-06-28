namespace :contributions do

  task :log => :environment do
    log = {}

    append_latest_to_log log, :last_comment,  Github.user_comment_log
    append_latest_to_log log, :last_issue,    Github.user_issue_log
    append_latest_to_log log, :last_pr,       Github.user_pr_log
    append_latest_to_log log, :last_accessed, Slack.user_access_log
    append_latest_to_log log, :last_messaged, Slack.user_message_log

    file = convert_to_csv(log)
    File.write('contributions.csv', file)
    puts "Finished writing to contributions.csv"
  end

  def convert_to_csv(log)
    require 'csv'
    csv_date = '%Y-%m-%d'
    CSV.generate do |csv|
      csv << (columns = [
        'username',
        :last_comment,
        :last_issue,
        :last_pr,
        :last_accessed,
        :last_messaged,
        :last_contribution
      ])
      log.each do |username, row|
        csv << [
          username,
          row[:last_comment].try(:strftime, csv_date),
          row[:last_issue].try(:strftime, csv_date),
          row[:last_pr].try(:strftime, csv_date),
          row[:last_accessed].try(:strftime, csv_date),
          row[:last_messaged].try(:strftime, csv_date),
          row.values.compact.sort.last.strftime(csv_date)]
      end
    end
  end

  def append_latest_to_log(log, column, results)
    flatten_to_latest(results).each do |username, contribution_date|
      if log[username].blank?
        log[username] = {
          last_comment: nil,
          last_issue: nil,
          last_pr: nil,
          last_accessed: nil,
          last_messaged: nil
        }
      end
      log[username][column] = contribution_date
    end
  end

  def flatten_to_latest(results)
    results.inject({}) do |users, row|
      user_id = row[:username]
      if users[user_id].blank? || users[user_id] < row[:created_at]
        users[user_id] = row[:created_at]
      end
      users
    end
  end

end
