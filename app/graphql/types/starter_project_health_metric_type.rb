# frozen_string_literal: true

module Types
  class StarterProjectHealthMetricType < Types::BaseObject
    field :pr_time_to_first_response_avg, Float, description: 'mean of pull request time to first response'
    field :pr_time_to_first_response_mid, Float, description: 'middle of pull request time to first response'
    field :change_request_closure_ratio_all_period, Float, description: 'the change request closure ratio all period'
    field :change_request_closed_count_all_period, Float, description: 'the change request closure ratio same period'
    field :change_request_created_count_all_period, Float, description: 'the change request created count all period'
    field :change_request_closure_ratio_recently, Float, description: 'the change request closure ratio recently'
    field :change_request_closed_count_recently, Float, description: 'the change request closed count recently'
    field :change_request_created_count_recently, Float, description: 'the change request created count recently'
    field :pr_time_to_close_avg, Float, description: 'mean of pull request time to close'
    field :pr_time_to_close_mid, Float, description: 'middle of pull request time to close'
    field :bus_factor, Float, description: 'the smallest number of people that make 50% of contributions'
    field :release_frequency, Float, description: 'the frequency of project releases (including point releases with bug fixes)'
    field :starter_project_health, Float, description: 'score of starter project health model'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
    field :short_code, String, description: 'metric model object short code'
  end
end
