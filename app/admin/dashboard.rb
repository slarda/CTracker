include ERB::Util

ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel 'Logins (30 days)' do
          ul do
            query_logins_data.each do |date, logins|
              html = "#{date} (#{pluralize(logins.count, 'login')}) - "
              logins.each do |login|
                html += "<a href='/users/#{login['id']}'>#{h(login['first_name'])} #{h(login['last_name'])} " \
                        "(#{h(login['email'])}</a> "
              end
              li html.html_safe
            end
          end
        end
      end
      column do
        panel 'Recent Activity (30 days)' do
          ul do
            query_activity_data.each do |date, logins|
              html = "#{date} (#{pluralize(logins.count, 'login')}) - "
              logins.each do |login|
                html += "<a href='/users/#{login['id']}'>#{h(login['first_name'])} #{h(login['last_name'])} " \
                        "(#{h(login['email'])})</a> "
              end
              li html.html_safe
            end
          end
        end
      end
    end
  end
end

def query_logins_data
  logins_30days = User.where('last_login_at >= ?', 30.days.ago).
      select("DATE_FORMAT(last_login_at, '%Y/%c/%e') AS date, users.id, email, first_name, last_name").
      collect { |user| user.attributes }

  day_to_login_map = {}
  logins_30days.each do |user|
    day_to_login_map[user['date']] ||= []
    users = day_to_login_map[user['date']]
    users.push(user)
  end
  day_to_login_map.sort { |x,y| y[0] <=> x[0] }
end

def query_activity_data
  activity_30days = User.where('last_activity_at >= ?', 30.days.ago).
      select("DATE_FORMAT(last_activity_at, '%Y/%c/%e') AS date, users.id, email, first_name, last_name").
      collect { |user| user.attributes }

  day_to_activity_map = {}
  activity_30days.each do |user|
    day_to_activity_map[user['date']] ||= []
    users = day_to_activity_map[user['date']]
    users.push(user)
  end
  day_to_activity_map.sort { |x,y| y[0] <=> x[0] }
end
