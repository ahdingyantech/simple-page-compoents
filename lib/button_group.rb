# -*- encoding : utf-8 -*-
module SimplePageCompoents
  module ButtonGroup
    class Button
      attr_reader :text, :url, :button_group

      def initialize(button_group, text, url, *args)
        @view = button_group.view
        @button_group = button_group
        @text = text
        @url = url

        @primary = args.include? :primary
        @info    = args.include? :info
        @success = args.include? :success
        @warning = args.include? :warning
        @danger  = args.include? :danger
        @inverse = args.include? :inverse
      end

      def css_class
        c = ['btn']
        c << 'primary' if @primary
        c << 'info'    if @info
        c << 'success' if @success
        c << 'warning' if @warning
        c << 'danger'  if @danger
        c << 'inverse' if @inverse
        c.join ' '
      end

      def render
        @view.haml_tag 'a', text, :class => css_class, :href => url
      end
    end

    class Render
      attr_reader :view, :buttons

      def initialize(view, *args)
        @view = view
        @buttons = []
      end

      def add(text, url, *args)
        button = Button.new(self, text, url, *args)
        @buttons << button
      end

      def render
        @view.haml_tag 'div.btn-group' do
          @buttons.each do |button|
            button.render
          end
        end
      end
    end
  end
end
