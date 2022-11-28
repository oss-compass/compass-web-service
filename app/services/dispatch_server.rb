# frozen_string_literal: true

class DispatchServer
  class InvalidParams < StandardError; end

  def execute(opts={project_name: nil})
    case opts
        in { project_name: '_all' }
        ProjectTask
          .where.not(project_name: nil)
          .where.not(remote_url: nil)
          .find_each(batch_size: 500) do |task|
          task_execute(task)
        end
        in { project_name: String }
        task = ProjectTask.find_by(project_name: opts[:project_name])
        if task.present?
          task_execute(task)
        else
          job_logger.error "no such task with project_name: #{opts[:project_name]}"
          { status: :error, message: I18n.t('dispatch.project.no_exists', project_name: opts[:project_name]) }
        end
    else
      job_logger.error "invalid project_name: #{opts[:project_name]}"
      { status: :error, message: I18n.t('dispatch.project.invalid', project_name: opts[:project_name])
    }
    end
  end

  private
  def task_execute(task)
    case task.level
    when 'repo'
      job_logger.info "Begin to execute repo task #{task.id}: with remote_url #{task.remote_url}"
      case AnalyzeServer.new(repo_url: task.remote_url).execute(only_validate: false)
          in { status: 'pending' }
          job_logger.info "repo task #{task.id} dispatch successfully"
          in { status: :progress }
          job_logger.warn "last repo task #{task.id} is still processing"
          in { status: status, message: message }
          job_logger.error "repo task #{task.id} dispatch result: status #{status}, message #{message}"
      end
    when 'project'
      job_logger.info "Begin to execute repo task #{task.id}: with remote_url #{task.remote_url}, project_name: #{task.project_name}"
      case AnalyzeGroupServer.new(yaml_url: task.remote_url).execute(only_validate: false)
          in { status: 'pending' }
          job_logger.info "project task #{task.id} dispatch successfully"
          in { status: :progress }
          job_logger.warn "last project task #{task.id} is still processing"
          in { status: status, message: message }
          job_logger.error "project task #{task.id} dispatch result: status #{status}, message #{message}"
      end
    else
      job_logger.error "Failed to execute task: #{task.to_json}"
    end
  end

  def job_logger
    Crono.logger.nil? ? Rails.logger : Crono.logger
  end
end
