class MaintenanceManagementMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_maintenance_management"
  end


  def self.dimension
    'release and maintenance'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'maintenance_management'
  end

  def self.text_ident
    'maintenance_management'
  end

  def self.main_score
    'score'
  end



end
