class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Pagy::Backend

  after_action { pagy_headers_merge(@pagy) if @pagy }

  def analyze
    opts = params.permit(:project_url, :enrich, :raw, :metrics)
    case AnalyzeServer.new(opts).perform_async
        in { result: :ok, message: }
        render json: { message: message }, status: 200
        in { result: :none, message: }
        render json: { message: message }, status: 202
        in {result: :error, message: }
        render json: { message: message }, status: 400
    else
      render json: { message: 'Unknown params' }, status: 400
    end
  end

  def check
    opts = params.permit(:project_url, :enrich, :raw, :metrics)
    status = AnalyzeServer.new(opts).get_analyze_status
    render json: status
  end

  def website
    render template: 'layouts/website'
  end

  def panel
    return redirect_to website_path unless user_signed_in?

    render template: 'layouts/panel'
  end
end
