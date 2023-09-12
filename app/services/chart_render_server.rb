# frozen_string_literal: true
class ChartRenderServer
  include Common
  include CompassUtils

  def initialize(params = {})
    @short_code = params[:short_code] || params[:id]
    @begin_date = params[:begin_date]
    @end_date = params[:end_date]
    @interval = params[:interval] ? params[:interval] : '1w'
    @metric = params[:metric]
    @field = params[:field]
    @chart = params[:chart] || 'line'
    @width = params[:width] || 800
    @height = params[:height] || 600
    @y_abs = params[:y_abs].to_s == '1'
    @label = params[:lable] || ShortenedLabel.revert(@short_code)&.label
    @repo_type = params[:repo_type]
  end

  def render_single_chart!()

    type = @short_code&.start_with?('c') ? @repo_type || 'software-artifact' : nil

    metrics =
      case @metric
      when 'community'
        CommunityMetric
      when 'collab_dev_index'
        CodequalityMetric
      when 'organizations_activity'
        GroupActivityMetric
      when 'activity'
        ActivityMetric
      else
        ActivityMetric
      end

    x,y = [], []
    @field ||= metrics.main_score
    if @metric != 'organizations_activity'
      resp = metrics.query_repo_by_date(@label, @begin_date, @end_date, page: 1, type: type)
      hits = resp&.[]('hits')&.[]('hits')
      if hits.present?
        hits.each do |hit|
          source = hit['_source']
          x << source['grimoire_creation_date'].slice(0, 10)
          y << (source[@field] || source[metrics.fields_aliases[@field.to_s]])
        end
      end
    else
      aggs = generate_interval_aggs(Types::GroupActivityMetricType, :grimoire_creation_date, @interval)
      resp = GroupActivityMetric.aggs_repo_by_date(@label, @begin_date, @end_date, aggs, type: type)
      aggs = resp&.[]('aggregations')&.[]('aggsWithDate')&.[]('buckets')
      hits = resp&.[]('hits')&.[]('hits')
      if aggs.present?
        template = hits.first&.[]('_source')
        aggs.map do |data|
          x << data['key_as_string'].slice(0, 10)
          y << (data[@field]&.[]('value') || data[metrics.fields_aliases[@field.to_s]]&.[]('value') ||
                template[@field] || template[metrics.fields_aliases[@field.to_s]])
        end
      end
    end

    payload = options(
      x: x, y: y,
      width: @width,
      height: @height,
      chart: @chart,
      title: generate_title(metrics, @field),
      subtext: auto_break_line(
        generate_subtext(metrics, @field),
        max_length: (0.1 * @width.to_i).to_i
      ),
      min_y: @y_abs ? 0 : y.min.floor,
      max_y: y.max < 1000 ? y.max.ceil : (y.max / 1000 + 1).to_i * 1000,
      y_legend: @field
    )
    resp =
      Faraday.post(
        "#{ECHARTS_SERVER}/api/image",
        payload.to_json,
        { 'Content-Type' => 'application/json'}
      )
    resp.body
  end

  def generate_title(metrics, field)
    if field == metrics.main_score
      I18n.t("metrics_models.#{metrics.text_ident}.title")
    else
      I18n.t("metrics_models.#{metrics.text_ident}.metrics.#{field}")
    end
  end

  def generate_subtext(metrics, field)
    if field == metrics.main_score
      ''
    else
      I18n.t("metrics_models.#{metrics.text_ident}.metrics.#{field}_desc")
    end
  end

  private
  def options(
        x: [], y: [],
        width: 800, height: 600,
        x_type: 'category', y_type: 'value',
        x_legend: 'date', y_legend: 'value',
        chart: 'line',
        background: '#fff',
        title: '',
        subtext: '',
        min_y: 0, max_y: 1
      )
    {
      "width" => width,
      "height" => height,
      "type" => "svg",
      "option" => {
        "grid" => {
          "left" => "10%",
          "right" => "10%",
          "top" => "15%",
          "bottom" => "10%"
        },
        "title" => {
          "text" => title,
          "subtext" => subtext,
          "left" => "center",
          "textStyle" => {
            "fontSize" => 18,
            "fontWeight" => "bold",
          }
        },
        "backgroundColor" => background,
        "xAxis" => {
          "type" => x_type,
          "data" => x,
          "axisLabel" => {
            "interval" => 0,
            "rotate" => 45
          }
        },
        "yAxis" => [
          {
            "type" => y_type,
            "scale" => true,
            "min" => min_y,
            "max" => max_y,
            "axisLabel" => {}
          }
        ],
        "series" => [
          {
            "data" => y,
            "type" => chart,
            "smooth" => true
          }
        ],
        "legend" => {
          "data" => [y_legend]
        }
      }
    }
  end
end
