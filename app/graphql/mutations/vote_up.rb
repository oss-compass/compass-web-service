# frozen_string_literal: true

module Mutations
  class VoteUp < BaseMutation

    field :status, String, null: false

    argument :src_package_name, String, required: true, description: 'src_package_name'
    argument :src_ecosystem, String, required: true, description: 'src_ecosystem'
    argument :target_package_name, String, required: true, description: 'target_package_name'
    argument :target_ecosystem, String, required: true, description: 'target_ecosystem'
    argument :who_vote, String, required: true, description: 'user name'

    def resolve(src_package_name: nil,
                src_ecosystem: nil,
                target_package_name: nil,
                target_ecosystem: nil,
                who_vote: nil
    )

      payload = {
        src_package_name: src_package_name,
        src_ecosystem: src_ecosystem,
        target_package_name: target_package_name,
        target_ecosystem: target_ecosystem,
        who_vote: who_vote,

      }

      current_user = context[:current_user]
      login_required!(current_user)
      url =  ENV.fetch('THIRD_URL')
      response = Faraday.post(
        "#{url}/vote_up",
        payload.to_json,
        { 'Content-Type' => 'application/json' }
      )

      resp = JSON.parse(response.body)
      data = resp['data'] || {}
      message = data['message'] || ''
      mapping = {
        'Vote up recorded successfully' => 'vote.vote_up_success'
      }
      key = mapping[message]
      res =  key.present? ? I18n.t(key) : message
      { status: true, message: res }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
