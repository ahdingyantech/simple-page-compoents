# -*- encoding : utf-8 -*-
module SimplePageCompoents
  module DataTable
    class TableColumn
      attr_reader :name
      attr_accessor :table

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def name_string
        I18n.t "compoents.data_table.#{@table.name}.#{@name}"
      end

      def value_of(item)
        @block.nil? ? item.send(@name) : @block.call(item)
      end
    end

    class Render
      attr_reader :view, :items, :columns, :name

      def initialize(view, name, items = [])
        @view = view
        @items = items
        @name = name

        @columns = []
      end

      def css_class
        "page-data-table #{name}"
      end

      def render
        @view.haml_tag :table, :class => css_class do
          _render_thead
          _render_tbody
        end
      end

      def add_column(name, &block)
        column = TableColumn.new(name.to_s, &block)
        column.table = self
        @columns << column
        self
      end

      private
        def _render_thead
          @view.haml_tag :thead do
            @view.haml_tag :tr do
              _render_ths
            end
          end
        end

        def _render_ths
          @columns.each do |column|
            text = column.name_string
            th_css_class = column.name
            @view.haml_tag :th, text, :class => th_css_class
          end
        end

        def _render_tbody
          @view.haml_tag :tbody do
            @items.each do |item|
              _render_line(item)
            end
          end
        end

        def _render_line(item)
          tr_css_class = item.class.to_s.tableize.singularize
          @view.haml_tag :tr, :class => tr_css_class do
            _render_tds(item)
          end
        end

        def _render_tds(item)
          @columns.each do |column|
            text = column.value_of item
            td_css_class = column.name
            @view.haml_tag :td, text, :class => td_css_class
          end
        end
    end
  end
end