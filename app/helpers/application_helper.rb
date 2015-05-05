module ApplicationHelper

  def render_projects(user)
    projects = user.projects.all

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
      projectList << { id: project.id, name: project.name, description: project.description, milestones: milestoneList }
    end
    projectList
  end

  def full_title(title = "")
    base_title = "Goaldigger"
    if title.blank?
      return base_title
    else
      return "#{title} | #{base_title}"
    end
  end

  def project_percentage_done(project)
    items = 0
    items_done = 0

    project.milestones.each do |milestone|
      milestone.items.each do |item|
        items += 1
        items_done += 1 if item.done
      end
    end

    if items > 0
      percent = items.to_f / items_done
      "#{percent}%"
    else
      "0%"
    end
  end
end
