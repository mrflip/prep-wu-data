
DATEFORMAT='%Y%m%d%H%M%S'

class PanelIdea < Struct.new(
      :id,
      :scraped_at,
      :name,
      :url,
      :org,
      :level,
      :type,
      :category,
      :title,
      :text   )
end

class PanelComment < Struct.new(
    :id,
    :idea_id,
    :name,
    :url,
    :created_at,
    :text )
end
