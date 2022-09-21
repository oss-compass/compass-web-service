# frozen_string_literal: true

class DispatchServer
  class InvalidParams < StandardError; end

  def execute(opts={project_name: nil})
    case opts
        in {project_name: '_all'}
        ProjectTask
          .where.not(project_name: nil)
          .where.not(remote_url: nil)
          .find_each(batch_size: 500) do |task|
          task_execute(task)
        end
        in {project_name: String}
        task = ProjectTask.find_by(project_name: opts[:project_name])
        if task.present?
          task_execute(task)
        else
          {status: :error, message: "no such task with project_name: #{opts[:project_name]}"}
        end
    else
      raise InvalidParams.new('Invalid project_name')
    end
  end

  private
  def task_execute(task)
    case task.level
    when 'repo'
      AnalyzeServer.new(repo_url: task.remote_url).execute(only_validate: false)
    when 'project'
      AnalyzeGroupServer.new(yaml_url: task.remote_url).execute(only_validate: false)
    else
      logger.error("Failed to execute task: #{task.to_json}")
    end
  end
end
