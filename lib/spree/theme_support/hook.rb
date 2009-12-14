# Yerked from the most awesome Redmine project http://redmine.org

module Spree
  module ThemeSupport
    module Hook
      include ActionController::UrlWriter

      @@listener_classes = []
      @@listeners = nil
      @@hook_listeners = {}
      @@hook_modifiers = {}

      class << self
        # Adds a listener class.
        # Automatically called when a class inherits from Spree::Hook::Listener.
        def add_listener(klass)
          raise "Hooks must include Singleton module." unless klass.included_modules.include?(Singleton)
          @@listener_classes << klass
          clear_listeners_instances
        end

        # Returns all the listerners instances.
        def listeners
          @@listeners ||= @@listener_classes.collect {|listener| listener.instance}
        end

        # Returns the listeners instances for the given hook.
        def hook_listeners(hook)
          @@hook_listeners[hook] ||= listeners.select {|listener| listener.respond_to?(hook)}
        end

        # Clears all the listeners.
        def clear_listeners
          @@listener_classes = []
          clear_listeners_instances
        end

        # Clears all the listeners instances.
        def clear_listeners_instances
          @@listeners = nil
          @@hook_listeners = {}
        end

        # Calls a hook.
        # Returns the listeners response.
        def call_hook(hook, context={})
          template = context[:controller].instance_variable_get('@template')
          returning [] do |response|
            hls = hook_listeners(hook)
            if hls.any?
              hls.each {|listener| response << listener.send(hook, template)}
            end
          end
        end

        # Take the content captured with a hook helper and modify with each of the listeners
        def render_hook(hook_name, content, context)
          modifiers_for_hook(hook_name).inject(content) { |result, modifier| modifier.apply_to(result, context) }
        end
        
        def modifiers_for_hook(hook_name)
          @@hook_modifiers[hook_name] ||= listeners.map {|l| l.modifiers_for_hook(hook_name)}.flatten
        end

      end



      # Listener class used for views hooks.
      # Listeners that inherit this class will include various helpers by default.
      class ViewListener
        include Singleton

        attr_accessor :hook_modifiers

        def initialize
          @hook_modifiers = []
        end

        def modifiers_for_hook(hook_name)
          hook_modifiers.select{|hm| hm.hook_name == hook_name}
        end


        def self.replace(hook_name, options = {}, &block)
          add_hook_modifier(hook_name, :replace, options, &block)
        end

        def self.insert_before(hook_name, options = {}, &block)
          add_hook_modifier(hook_name, :insert_before, options, &block)
        end

        def self.insert_after(hook_name, options = {}, &block)
          add_hook_modifier(hook_name, :insert_after, options, &block)
        end

        def self.remove(hook_name, options = {})
          add_hook_modifier(hook_name, :replace)
        end
        
        private
        
        def self.add_hook_modifier(hook_name, action, options = {}, &block)
          if block
            renderer = lambda do |template|
              template.instance_eval(&block)
            end
          else
            if options.empty?
              renderer = nil
            else
              renderer = lambda do |template|
                template.render(options)
              end
            end
          end
          instance.hook_modifiers << HookModifier.new(hook_name, action, renderer)
        end


        # A hook modifier is created for each usage of 'insert_before','replace' etc.
        # This stores how the original contents of the hook should be modified
        # and does the work of altering the hooks content appropriately
        class HookModifier
          attr_accessor :hook_name
          attr_accessor :action
          attr_accessor :renderer

          def initialize(hook_name, action, renderer = nil)
            @hook_name = hook_name
            @action = action
            @renderer = renderer
          end

          def apply_to(content, context)
            return '' if renderer.nil?
            case action
            when :insert_before
              renderer.call(context) + content
            when :insert_after
              content + renderer.call(context)
            when :replace
              renderer.call(context)
            else
              ''
            end
          end

        end

      end
      
      
      
    end
  end
end


