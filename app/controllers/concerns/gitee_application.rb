module GiteeApplication
  extend ActiveSupport::Concern
  include Common

  GITEE_TOKEN = ENV.fetch('GITEE_API_TOKEN')
  GITEE_REPO = ENV.fetch('GITEE_WORKFLOW_REPO')
  GITEE_API_ENDPOINT = 'https://gitee.com/api/v5'

  def gitee_notify_on_pr(owner, repo, pr_number, message)
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{owner}/#{repo}/pulls/#{pr_number}/comments",
        { body: message, access_token: GITEE_TOKEN }.to_json,
        { 'Content-Type' => 'application/json' }
      )
  end

  def gitee_create_branch(branch_name, refs: 'main')
    Faraday.post(
      "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/branches",
      { refs: refs, branch_name: branch_name, access_token: GITEE_TOKEN }.to_json,
      { 'Content-Type' => 'application/json' }
    )
    { status: true, ref: branch_name }
  rescue => ex
    { status: false, message: "failed to create ref, reason: #{ex.message}" }
  end

  def gitee_post_file(path, message, content_base64, branch_name)
    resp =
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/contents/#{path}",
        { message: message, content: content_base64, branch: branch_name, access_token: GITEE_TOKEN }.to_json,
        { 'Content-Type' => 'application/json'}
      )
    case JSON.parse(resp.body).symbolize_keys
        in {commit: commit, content: content}
        { status: true, message: content['name']}
        in {message: message}
        { status: false, message: message }
    else
      { status: false, message: resp.body }
    end
  rescue => ex
    { status: false, message: "failed to put file, reason: #{ex.message}" }
  end

  def gitee_create_pull(title, content, head, base: 'main')
    resp =
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/pulls",
        {
          title: title,
          body: content,
          head: head,
          base: base,
          prune_source_branch: true,
          access_token: GITEE_TOKEN
        }.to_json,
        { 'Content-Type' => 'application/json'}
      )
    pull = JSON.load(resp.body)
    { status: true, pr_id: pull['id'], pr_url: pull['html_url'] }
  rescue => ex
    { status: false, message: "failed to create ref, reason: #{ex.message}" }
  end

  private
  def gitee_owner
    @gitee_owner ||= GITEE_REPO.split('/')[-2]
  end

  def gitee_repo
    @gitee_repo ||= GITEE_REPO.split('/')[-1]
  end


  def gitee_webhook_verify
    password = request.request_parameters&.[]('password')
    render_json(403, message: 'unauthorized') unless password == HOOK_PASS
  end
end
