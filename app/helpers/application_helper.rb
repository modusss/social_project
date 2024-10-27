module ApplicationHelper
  def flash_message
    return unless flash[:notice] || flash[:alert]

    message = flash[:notice] || flash[:alert]
    content_tag(:p, message, class: "py-2 px-3 bg-green-50 mb-5 text-green-500 font-medium rounded-lg inline-block", id: "flash-message")
  end
end
