# frozen_string_literal: true
class DeveloperChartRenderServer
  include Common
  include CompassUtils

  def initialize(params = {})
    @begin_date = params[:begin_date]
    @end_date = params[:end_date]
    @option = params[:option]
    @width = params[:width]
    @height = params[:height]

  end

  def render!
    render_developer_chart!
  end

  def render_developer_chart!
    option = @option

    payload = {
      option: option,
      width: @width,
      height: @height,
      type: "svg"
    }

    request_svg(
      payload
    )
  end

  def generate_title(metrics, field)
    if metrics == 'overview'
      I18n.t("analyze.overview")
    elsif field == metrics.main_score
      I18n.t("metrics_models.#{metrics.text_ident}.title")
    else
      I18n.t("metrics_models.#{metrics.text_ident}.metrics.#{field}")
    end
  end

  def generate_subtext(metrics, field)
    if metrics == 'overview'
      ''
    elsif field == metrics.main_score
      ''
    else
      I18n.t("metrics_models.#{metrics.text_ident}.metrics.#{field}_desc")
    end
  end

  private

  def request_svg(payload)
    Faraday.post(
      "#{ECHARTS_SERVER}/developer_overview",
      payload.to_json,
      { 'Content-Type' => 'application/json' }
    ).body
  end

end
