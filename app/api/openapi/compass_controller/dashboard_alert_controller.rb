# frozen_string_literal: true

module Openapi
  module CompassController

    class DashboardAlertController < Grape::API

      # version 'compass', using: :path
      prefix :services
      format :json

      helpers Openapi::SharedParams::Search

      helpers Openapi::V1::Helpers
      # helpers Openapi::SharedParams::ErrorHelpers
      helpers Openapi::SharedParams::RestapiHelpers

      # rescue_from :all do |e|
      #   case e
      #   when Grape::Exceptions::ValidationErrors
      #     handle_validation_error(e)
      #   when SearchFlip::ResponseError
      #     handle_open_search_error(e)
      #   else
      #     handle_generic_error(e)
      #   end
      # end
      INDEX_CLASS_MAPPING = {
        'compass_metric_model_v2_response_timeliness' => ResponseTimelinessMetric,
        'compass_metric_model_v2_collaboration_quality' => CollaborationQualityMetric,
        'compass_metric_model_v2_developer_base' => DeveloperBaseMetric,
        'compass_metric_model_v2_contribution_activity' => ContributionActivityMetric,
        'compass_metric_model_v2_community_popularity' => CommunityPopularityMetric,
        'compass_metric_model_v2_organizational_governance' => OrganizationalGovernanceMetric,
        'compass_metric_model_v2_personal_governance' => PersonalGovernanceMetric
      }.freeze

      before { require_login! }

      helpers do
        include Pagy::Backend

        def paginate_fun(scope)
          pagy(scope, page: params[:page], items: params[:per_page])
        end

        def fetch_metrics_by_range(db_index_key, label, start_date, end_date,level)

          return {} if db_index_key.blank? || label.blank?
          metric_class = INDEX_CLASS_MAPPING[db_index_key]

          real_index_name = metric_class ? metric_class.index_name : db_index_key

          begin
            # response = metric_class
            #              .must(terms: { "label.keyword" => label })
            #              .range(:grimoire_creation_date, gte: start_date, lte: end_date)
            #              .sort(grimoire_creation_date: :asc)
            #              .limit(100)
            #              .execute
            #              .raw_response
            #
            # hits = response&.[]('hits')&.[]('hits') || []

            query = metric_class
                      .must(terms: { "label.keyword" => label })
                      .range(:grimoire_creation_date, gte: start_date, lte: end_date)
                      .sort(grimoire_creation_date: :asc)
                      .limit(100)

            if level == 'community'
              query = query.must(term: { "type.keyword"=> "software-artifact" })
            end
            response = query.execute.raw_response
            hits = response&.[]('hits')&.[]('hits') || []
            hits.map { |data| data["_source"] }
          rescue => e
            Rails.logger.error "SearchFlip Range Query Error [#{real_index_name}]: #{e.message}"
            []
          end
        end


        def validate_no_overlap(organizations)
          return if organizations.size <= 1

          sorted = organizations.sort_by { |o| Date.parse(o[:first_date] || o['first_date']) }

          sorted.each_cons(2) do |current, next_org|
            current_end = current[:last_date] || current['last_date']
            next_start = next_org[:first_date] || next_org['first_date']

            if current_end.blank? || Date.parse(current_end) >= Date.parse(next_start)
              error!({ error: 'Organization date ranges overlap' }, 400)
            end
          end
        end



        # 检查当前用户是否在看板中（任何角色）
        def require_dashboard_member!(dashboard)
          return dashboard if dashboard.public?
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)
          error!({ error: '无权访问此看板' }, 403) unless member
          member
        end

        # 检查编辑权限
        def require_dashboard_editor!(dashboard)
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)
          error!({ error: '需要编辑权限' }, 403) unless member&.can_edit?
          member
        end

        # 检查管理员权限
        def require_dashboard_admin!(dashboard)
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)
          error!({ error: '需要管理员权限' }, 403) unless member&.can_manage_members?
          member
        end

        # 获取当前用户在看板中的角色
        def current_member_role(dashboard)
          dashboard.dashboard_members.find_by(user: current_user, status: :active)&.role
        end
      end



      resource :dashboard_alert do




      end
    end
  end
end

