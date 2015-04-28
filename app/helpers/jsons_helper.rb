module JsonsHelper
  def render_projects
    projects = @user.projects.all

    projectList = []
    projects.each do |project|
      milestoneList = []

      project.milestones.all.each do |milestone|
        itemList = []

        milestone.items.all.each do |item|
          itemList << { id: item.id, name: item.name, done: item.done }
        end

        milestoneList << { id: milestone.id, name: milestone.name, items: itemList }

      end
      itemList = []
      project.items.all.each do |item|
        itemList << { id: item.id, name: item.name, done: item.done }
      end
      projectList << { id: project.id, name: project.name, description: project.description, items: itemList, milestones: milestoneList }
    end
    projectList
  end
end
