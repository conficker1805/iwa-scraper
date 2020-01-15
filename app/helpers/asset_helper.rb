module AssetHelper
  def action
    @current_action ||= begin
      class_mappings = { 'create' => 'new', 'update' => 'edit' }
      class_mappings[action_name] || action_name
    end
  end

  def page_wrapper
    "#{controller_name}-#{action}-container"
  end

  def javascript_init
    application_name  = Rails.application.class.module_parent_name
    js_namespace_name = controller.class.to_s.sub(/Controller$/, '')
                                  .underscore.tr('/', '_').camelize(:lower)
    js_function_name = action.camelize

    javascript_tag <<-JS
      #{application_name}.init();
      if(#{application_name}.init#{js_function_name}) {#{application_name}.init#{js_function_name}()}
      if(#{application_name}.#{js_namespace_name}) {
        if(#{application_name}.#{js_namespace_name}.init) { #{application_name}.#{js_namespace_name}.init(); }
        if(#{application_name}.#{js_namespace_name}.init#{js_function_name}) { #{application_name}.#{js_namespace_name}.init#{js_function_name}(); }
      }
    JS
  end
end
