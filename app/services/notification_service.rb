# frozen_string_literal: true

class NotificationService

  SUBSCRIPTION_UPDATE = :subscription_update
  SUBMISSION = :submission
  SUBSCRIPTION_CREATE = :subscription_create
  SUBSCRIPTION_DELETE = :subscription_delete

  NOTIFICATION_PLATFORMS = %w[wechat email slack].freeze

  attr_reader :user, :notification_type, :params

  def initialize(user, notification_type, params)
    @user = user
    @notification_type = notification_type
    @params = params
  end

  def execute
    unless notification_type.to_s.to_sym.in?([SUBSCRIPTION_UPDATE, SUBMISSION, SUBSCRIPTION_CREATE, SUBSCRIPTION_DELETE])
      Rails.logger.error("NotificationService: invalid notification_type #{notification_type}")
      return
    end
    NOTIFICATION_PLATFORMS.each do |platform|
      "Notification::#{platform.capitalize}".constantize.new(user, notification_type, params).execute
    end
  end

  def enabled?
    false
  end

  def explore_url
    "#{ENV['NOTIFICATION_URL']}#{ENV['NOTIFICATION_EXPLORE_URL']}"
  end

  def subscription_url
    "#{ENV['NOTIFICATION_URL']}#{ENV['NOTIFICATION_SUBSCRIPTION_URL']}"
  end

  def about_url
    "#{ENV['NOTIFICATION_URL']}#{ENV['NOTIFICATION_ABOUT_URL']}"
  end

  def subject_name
    subject = params[:subject]
    label = subject.label
    level = subject.level
    name = subject.label
    name = Addressable::URI.parse(label).path[1..] rescue label if level == 'repo'
    name
  end

  def subject_url
    compass_analyze_url = "#{ENV['NOTIFICATION_URL']}#{ENV['NOTIFICATION_ANALYZE_URL']}"
    compass_analyze_uri = Addressable::URI.parse(compass_analyze_url)
    compass_analyze_uri.query_values = {
      label: params[:subject].label,
      level: params[:subject].level
    }
    compass_analyze_uri.to_s
  end
end
