class ChartController < ApplicationController
  def show
    short_code = params[:id]
    params[:begin_date], params[:end_date] = extract_range
    params[:begin_date], params[:end_date], params[:interval] =
                                            extract_date(
                                              params[:begin_date] && DateTime.parse(params[:begin_date].to_s),
                                              params[:end_date] && DateTime.parse(params[:end_date].to_s))
    if short_code.present?
      label = ShortenedLabel.revert(short_code)&.label
      if label.present?
        if !RESTRICTED_LABEL_LIST.include?(label)
          params[:label] = label
          svg = ChartRenderServer.new(params).render!
          return render xml: svg, layout: false, content_type: 'image/svg+xml'
        end
      end
    end
    render template: 'chart/empty', layout: false, content_type: 'image/svg+xml'
  rescue => ex
    Rails.logger.error("Failed to render svg chart: #{ex.message}")
    render template: 'chart/empty', layout: false, content_type: 'image/svg+xml'
  end

  def extract_range
    today = Date.today.end_of_day
    case params[:range]
    when '3M'
      [today - 3.months, today]
    when '6M'
      [today - 6.months, today]
    when '1Y'
      [today - 1.year, today]
    when '2Y'
      [today - 2.years, today]
    when '3Y'
      [today - 3.years, today]
    when '5Y'
      [today - 5.years, today]
    when 'Since 2000'
      [DateTime.new(2000), today]
    else
      [params[:begin_date], params[:end_date]]
    end
  end
end
