# -*- encoding : utf-8 -*-
module SimplePageCompoents
  module ProgressBar
    class Render
      attr_reader :view, :percent

      def initialize(view, percent = 0, *args)
        @view = view
        @percent = percent

        @striped = args.include? :striped
        @active = args.include? :active

        @info = args.include? :info
        @success = args.include? :success
        @warning = args.include? :warning
        @danger = args.include? :danger
      end

      def css_class
        c = ['page-progress']

        c << 'striped' if @striped
        c << 'active' if @active
        
        c << 'info' if @info
        c << 'success' if @success
        c << 'warning' if @warning
        c << 'danger' if @danger

        c.join(' ')
      end

      def render
        @view.haml_tag :div, :class => css_class do
          @view.haml_tag :div, '', :class => :bar, :style => "width:#{@percent}%;"
        end
      end
    end
  end
end