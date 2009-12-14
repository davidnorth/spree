module Spree::ThemeSupport::HookHelper
  
  # Allow hooks to be used in views like this:
  # 
  #   <%= hook :some_hook %>
  #
  #   <% hook :some_hook do %>
  #     <p>Some HTML</p>
  #   <% end %>
  # 
  def hook(hook_name, &block)
    content = block ? capture(&block) : ''
    concat Spree::ThemeSupport::Hook.render_hook(hook_name, content, self)
  end

end