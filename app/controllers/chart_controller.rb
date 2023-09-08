class ChartController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Utils
  include Common

  def show
    short_code = params[:id]
    params[:begin_date], params[:end_date], interval =
                                            extract_date(params[:begin_date], params[:end_date])

    if short_code.present?
      label = ShortenedLabel.revert(short_code)&.label
      if label.present?
        if !RESTRICTED_LABEL_LIST.include?(label)
          if !interval
            params[:label] = label
            svg = ChartRenderServer.new(params).render_single_chart!
            return render xml: svg, layout: false, content_type: 'image/svg+xml'
          end
        end
      end
    end
    render template: 'chart/empty', layout: false, content_type: 'image/svg+xml'
  rescue => ex
    Rails.logger.error("Failed to render svg chart: #{ex.message}")
    render template: 'chart/empty', layout: false, content_type: 'image/svg+xml'
  end
end
