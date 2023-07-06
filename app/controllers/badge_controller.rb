class BadgeController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def show
    short_code = params[:id]
    metric = params[:metric]
    is_metric_badge = true
    metrics =
      case metric
      when 'community'
        CommunityMetric
      when 'collab_dev_index'
        CodequalityMetric
      when 'organizations_activity'
        GroupActivityMetric
      when 'activity'
        ActivityMetric
      else
        is_metric_badge = false
        ActivityMetric
      end
    if short_code.present?
      label = ShortenedLabel.revert(short_code)&.label
      if label.present?
        latest_metric = metrics.find_one('label', label)
        @score = latest_metric.present? ? metrics.scaled_value(latest_metric) : '--'
        if is_metric_badge
          return render template: "badge/#{metric}", layout: false, content_type: 'image/svg+xml'
        else
          return render template: 'badge/shield', layout: false, content_type: 'image/svg+xml'
        end
      end
    end
    render template: 'badge/notfound', layout: false, content_type: 'image/svg+xml'
  end
end
