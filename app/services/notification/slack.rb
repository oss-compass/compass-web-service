# frozen_string_literal: true

class Notification::Slack < NotificationService
  attr_accessor :login_bind

  def execute
    return unless enabled?

    uid = login_bind.uid
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: uid,
      text: send("#{notification_type}_context"),
      mrkdwn: true
    )
  end

  def subscription_update_context
    "## OSS Compass project subscription update - #{subject_name}

    Hi #{user.name},

    There has been a recent update to the project report you subscribed to on OSS Compass, as follows:

    - [#{subject_name}](#{subject_url})

    Click the link above to view the updated report. If you need to manage your OSS Compass project subscription, [please click here](#{subscription_url}).
    For more insight into open source software project analysis, visit: [OSS Compass](#{explore_url}).

    [OSS Compass team](#{about_url})
"
  end

  def submission_context
    "## OSS Compass project subscription

    Hi #{user.name},

    Your analysis request for [#{subject_name}](#{subject_url}) on the OSS Compass website has been submitted and subscribed. We will synchronize the relevant report information with you after we confirm and complete the analysis.

    To manage OSS Compass project subscriptions, [please click here](#{subscription_url}).
    For more insight into open source software project analysis, visit: [OSS Compass](#{explore_url}).

    [OSS Compass team](#{about_url})
"
  end

  def subscription_create_context
    "## OSS Compass project subscription

    Hi #{user.name},

    You have successfully subscribed to the analysis report of the [#{subject_name}](#{subject_url}). We will update the report information with you when the project report is updated.

    To manage OSS Compass project subscriptions, [please click here](#{subscription_url}).
    For more insight into open source software project analysis, visit: [OSS Compass](#{explore_url}).

    [OSS Compass team](#{about_url})
"
  end

  def subscription_delete_context
    "## OSS Compass project unsubscription

    Hi #{user.name},

    You have successfully unsubscribed the analysis report for the [#{subject_name}](#{subject_url}).

    To manage OSS Compass project subscriptions, [please click here](#{subscription_url}).
    For more insight into open source software project analysis, visit: [OSS Compass](#{explore_url}).

    [OSS Compass team](#{about_url})
"
  end

  def enabled?
    @login_bind = user.login_binds.find_by(provider: 'slack')
    @login_bind.present?
  end
end
