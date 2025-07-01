module ApplicationHelper
  def body_classes
    base_classes = "min-h-screen flex flex-col"

    if !(controller_name == "conversations" && action_name == "show")
      base_classes += " bg-base-200"
    end

    base_classes
  end
end
