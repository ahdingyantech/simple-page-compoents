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

      def table=(table)
        @table = table
        @view = table.view
      end

      def name_string
        I18n.t "compoents.data_table.#{@table.name}.#{@name}"
      end

      def value_of(item)
        value = @block.nil? ? item.send(@name) : @view.capture {@block.call(item)}
        value.to_s 
        # 如果返回 symbol，将会不能显示
        # bugfix: Issue #1
      end
    end

    class Render
      attr_reader :view, :items, :columns, :name

      def initialize(view, name, items = [], *args)
        @view = view
        @items = items
        @name = name

        @columns = []
        @line_datas = []

        # change color on mouse hover
        @table_hover = args.include? :hover 
        
        # table lines with striped color
        @striped = args.include? :striped

        # table with cell border
        @bordered = args.include? :bordered
      end

      def css_class
        c = [
          "page-data-table", @name
        ]
        c << 'table-hover' if @table_hover
        c << 'striped' if @striped
        c << 'bordered' if @bordered
        c.join(' ')
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

      def add_line_data(name, &block)
        @line_datas << name
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
            @view.haml_tag :th, :class => th_css_class do
              @view.haml_tag :span, text, :class => 'th-inner'
            end
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
          data = _render_line_data(item)
          @view.haml_tag :tr, :data => data, :class => tr_css_class do
            _render_tds(item)
          end
        end

        def _render_line_data(item)
          re = Hash.new ''
          @line_datas.each { |data|
            re[data] = item.send(data)
          }
          re
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
