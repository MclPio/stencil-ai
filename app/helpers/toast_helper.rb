module ToastHelper
  def self.show_toast(stream_name, type, title, message, timeout = 5000)
    Turbo::StreamsChannel.broadcast_append_to(
      stream_name,
      target: "toast_container",
      partial: "shared/toast",
      locals: {
        type: type,
        title: title,
        message: message,
        timeout: timeout
      }
    )
  end
end
