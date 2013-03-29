# -*- encoding : utf-8 -*-
module SimplePageCompoents
  module DataTile
    class TileData
      attr_reader :name
      attr_accessor :tile

      def initialize(name, *args, &block)
        @name = name
        @block = block

        @bold = args.include? :bold
        @quiet = args.include? :quiet

        @font12 = args.include? :font12
        @font13 = args.include? :font13
        @font14 = args.include? :font14
      end

      def tile=(tile)
        @tile = tile
        @view = tile.view
      end

      def value_of(item)
        value = @block.nil? ? item.send(@name) : @view.capture {@block.call(item)}
        value.to_s
      end

      def css_class
        c = ['tile-field', @name]
        c << 'bold' if @bold
        c << :quiet if @quiet
        c << :font12 if @font12
        c << :font13 if @font13
        c << :font14 if @font14
        c.join ' '
      end
    end

    class Render
      attr_reader :view, :items, :name
      attr_reader :datas, :left_datas, :foot_datas

      def initialize(view, name, items = [], *args)
        @view = view
        @items = items
        @name = name

        @left_datas  = []
        @right_datas = []
        @datas       = []
        @foot_datas  = []
      end

      def css_class
        c = [
          "page-data-tile", @name
        ]
        c.join(' ')
      end

      def render
        @view.haml_tag :div, :class => css_class do
          @items.each do |item|
            _render_line(item)
          end
        end
      end

      def add(name, *args, &block)
        _add_x(name, @datas, *args, &block)
      end

      def add_left(name, *args, &block)
        _add_x(name, @left_datas, *args, &block)
      end

      def add_right(name, *args, &block)
        _add_x(name, @right_datas, *args, &block)
      end

      def add_foot(name, *args, &block)
        _add_x(name, @foot_datas, *args, &block)
      end

      private
        def _add_x(name, datas, *args, &block)
          data = TileData.new(name.to_s, *args, &block)
          data.tile = self
          datas << data
          self
        end

        def _render_line(item)
          class_css_class = item.class.to_s.tableize.singularize
          div_css_class = ['tile-item', class_css_class] * ' '
          @view.haml_tag :div, :class => div_css_class do
            _render_left(item)
            _render_body(item)
            _render_right(item)
          end
        end

        def _render_left(item)
          _render_x(item, @left_datas, 'tile-left')
        end

        def _render_right(item)
          _render_x(item, @right_datas, 'tile-right')
        end

        def _render_body(item)
          return if @datas.blank?
          body_css_class = [
            'tile-body',
            (@left_datas.blank? ? 'no-left' : ''),
            (@right_datas.blank? ? 'no-right' : '')
          ]


          @view.haml_tag :div, :class => body_css_class do
            @datas.each do |data|
              text = data.value_of item
              @view.haml_tag :div, text, :class => data.css_class
            end
            _render_foot(item)
          end
        end

        def _render_foot(item)
          _render_x(item, @foot_datas, 'tile-foot')
        end

        def _render_x(item, datas, class_name)
          return if datas.blank?
          @view.haml_tag :div, :class => class_name do
            datas.each do |data|
              text = data.value_of item
              @view.haml_tag :div, text, :class => data.css_class
            end
          end
        end
    end
  end
end