# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
class CalculateAllTaskJob
  def perform
    DispatchServer.new.execute({project_name: '_all'})
  end
end

class CalculateSummaryJob
  def perform
    DispatchServer.new.execute({summary: true})
  end
end

class CalculateCollectionJob
  def perform
    CollectionServer.new.execute("collections")
  end
end

class ExportAllRepoInfoJob
  def perform
    ExportServer.new(ActivityMetric, 'label.keyword', 10000, 20).execute
  end
end

Crono.perform(CalculateAllTaskJob).every 4.weeks, on: :sunday, at: "09:30"
Crono.perform(CalculateSummaryJob).every 2.days, at: {hour: 15, min: 30}
Crono.perform(CalculateCollectionJob).every 2.days, at: {hour: 7, min: 30}
Crono.perform(ExportAllRepoInfoJob).every 4.days, at: {hour: 21, min: 30}
