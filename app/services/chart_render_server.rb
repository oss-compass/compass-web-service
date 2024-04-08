# frozen_string_literal: true
class ChartRenderServer
  include Common
  include CompassUtils

  def initialize(params = {})
    @short_code = params[:short_code] || params[:id]
    @begin_date = params[:begin_date]
    @end_date = params[:end_date]
    @interval = params[:interval]
    @metric = params[:metric]
    @field = params[:field]
    @chart = params[:chart] || 'line'
    @width = params[:width] || 800
    @height = params[:height] || 600
    @y_abs = params[:y_abs].to_s == '1'
    @y_trans = params[:y_trans].to_s == '1'
    @label = params[:lable] || ShortenedLabel.revert(@short_code)&.label
    @repo_type = params[:repo_type]
  end

  def render!
    if @metric == 'overview'
      render_overview_chart!
    else
      render_single_chart!
    end
  end

  def render_single_chart!

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

    @field ||= metrics.main_score

    x_values, y_values =
              if @metric != 'organizations_activity' && !@interval
                build_metrics_with_search(metrics, type)
              else
                build_metrics_with_agg(metrics, type)
              end

    x = generate_x_axis(data: x_values)

    y_min = y_values.min || 0
    y_max = y_values.max || 0

    y = [
      generate_y_axis(
        name: @field,
        min: @y_abs ? 0 : y_min < 1 ? y_min.floor(2) - 0.01 : y_min.floor - 1,
        max: y_max < 1000 ? y_max < 1 ? y_max.ceil(2) + 0.01 : y_max.ceil + 1 : (y_max / 1000 + 1).to_i * 1000,
        data: y_values,
        chart: @chart
      )
    ]

    request_svg(
      options(
        x: x, y: y,
        legend: [@field],
        width: @width,
        height: @height,
        title: generate_title(metrics, @field),
        subtext: auto_break_line(
          generate_subtext(metrics, @field),
          max_length: (0.1 * @width.to_i).to_i
        )
      )
    )
  end

  def render_overview_chart!
    type = @short_code&.start_with?('c') ? @repo_type || 'software-artifact' : nil

    x_final_values = []

    y_final_values =
      [ActivityMetric, CommunityMetric, CodequalityMetric, GroupActivityMetric].map do |metrics|

      @field = metrics.main_score

      x_values, y_values =
                if metrics != GroupActivityMetric
                  build_metrics_with_search(metrics, type)
                else
                  build_metrics_with_agg(metrics, type)
                end

      x_final_values = x_values if x_values.length > x_final_values.length
      [metrics, y_values]
    end

    x = generate_x_axis(data: x_final_values)

    y_final_values_flatten = y_final_values.map { |pair| pair[1] }.flatten.compact

    y_min_value = @y_abs ? 0 : y_final_values_flatten.min ? y_final_values_flatten.min.floor : 0

    y_max_value = @y_abs ?
                    @y_trans ? 100 : 1 :
                    y_final_values_flatten.max ?
                      y_final_values_flatten.max.ceil :
                      @y_trans ? 100 : 1
    y_legends = []

    y = y_final_values.map do |metric_pair|
      y_legends << metric_pair[0].i18n_name
      generate_y_axis(
        name: metric_pair[0].i18n_name,
        color: metrics_mapping_colors[metric_pair[0]],
        min: y_min_value,
        max: y_max_value,
        data: metric_pair[1],
        chart: @chart
      )
    end

    payload = options(
      x: x, y: y,
      legend: y_legends,
      width: @width,
      height: @height,
      title: generate_title('overview', @field),
      subtext: auto_break_line(
        generate_subtext('overview', @field),
        max_length: (0.1 * @width.to_i).to_i
      )
    )

    request_svg(payload)
  end

  def build_metrics_with_search(metrics, type)
    x_values, y_values = [], []
    resp = metrics.query_repo_by_date(@label, @begin_date, @end_date, page: 1, type: type)
    hits = resp&.[]('hits')&.[]('hits')
    if hits.present?
      hits.each do |hit|
        source = hit['_source']
        x_values << source['grimoire_creation_date'].slice(0, 10)
        y_src = (source[@field] || source[metrics.fields_aliases[@field.to_s]])
        y_values << (@y_trans && @field == metrics.main_score ? metrics.scaled_value(nil, target_value: y_src) : y_src).round(2)
      end
    end
    [x_values, y_values]
  end

  def build_metrics_with_agg(metrics, type)
    x_values, y_values = [], []
    @interval ||= '1w'
    aggs = generate_interval_aggs("Types::#{metrics.to_s}Type".constantize, :grimoire_creation_date, @interval)
    resp = metrics.aggs_repo_by_date(@label, @begin_date, @end_date, aggs, type: type)
    aggs = resp&.[]('aggregations')&.[]('aggsWithDate')&.[]('buckets')
    hits = resp&.[]('hits')&.[]('hits')
    if aggs.present?
      template = hits.first&.[]('_source')
      aggs.map do |data|
        x_values << data['key_as_string'].slice(0, 10)
        y_src = (data[@field]&.[]('value') || data[metrics.fields_aliases[@field.to_s]]&.[]('value') ||
                 template[@field] || template[metrics.fields_aliases[@field.to_s]])
        y_values << (@y_trans && @field == metrics.main_score ? metrics.scaled_value(nil, target_value: y_src) : y_src).round(2)
      end
    end
    [x_values, y_values]
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

  def metrics_mapping_colors
    {
      CodequalityMetric => '#5470c6',
      CommunityMetric => '#91cc75',
      ActivityMetric => '#fac858',
      GroupActivityMetric => '#ee6666'
    }
  end

  def generate_y_axis(name: '', color: '#5470c6', min: 0, max: 0, data: [], chart: 'line')
    {
      color: color,
      axis: {
        type: 'value',
        min: min,
        max: max,
        scale: true,

        axisLabel: {}
      },
      series: {
        name: name,
        data: data,
        type: chart,
        smooth: true,
        showSymbol: false
      }
    }
  end

  def generate_x_axis(data: [], type: 'category')
    {
      type: type,
      data: data,
      axisLabel: {
        align: 'center',
        interval: 'auto',
        rotate: 30,
        overflow: 'truncate',
        margin: 35,
      },
      axisTick: {
        alignWithLabel: true,
      }
    }
  end

  private
  def options(
        x: {}, y: [],
        legend: [],
        width: 800, height: 600,
        x_type: 'category',
        x_legend: 'date',
        background: '#fff',
        title: '',
        subtext: ''
      )
    init_opts = default_option
    init_opts[:width] = width
    init_opts[:height] = height
    init_opts[:option][:title][:text] = title
    init_opts[:option][:legend][:data] = legend
    init_opts[:option][:title][:subtext] = subtext
    init_opts[:option][:backgroundColor] = background
    init_opts[:option][:xAxis] = x
    init_opts[:option][:color] = y.map { |y| y[:color] }
    init_opts[:option][:yAxis] = y.map { |y| y[:axis] }
    init_opts[:option][:series] = y.map { |y| y[:series] }
    init_opts
  end

  def request_svg(payload)
    Faraday.post(
      "#{ECHARTS_SERVER}/api/image",
      payload.to_json,
      { 'Content-Type' => 'application/json'}
    ).body
  end

  def default_option
    {
      width: 800,
      height: 600,
      type: 'svg',
      option: {
        grid: {
          left: '10%',
          right: '10%',
          top: '18%',
          bottom: '20%'
        },
        legend: {
          data: [],
          padding: [85, 0, 0, 0]
        },
        title: {
          text: 'Title',
          subtext: 'Sub Title',
          left: 'center',
          textStyle: {
            fontSize: 18,
            fontWeight: 'bold'
          }
        },
        backgroundColor: '#fff',
        xAxis: {
          type: 'category',
          data: [],
          axisLabel: {
            interval: 0,
            rotate: 45
          }
        },
        yAxis: [],
        series: [],
        graphic: [
          {
            type: 'text',
            left: '5%',
            bottom: '8%',
            style: {
              text: 'Powered by oss-compass.org',
              fill: '#ADADAD',
              fontSize: 12
            }
          }
        ]
      }
    }
  end
end
