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

    class TileContext
      def initialize(&block)
        @block = block

        @context_datas = []
      end

      def tile=(tile)
        @tile = tile
        @view = tile.view
      end

      def render(item)
        @block.call(self, item)
        @context_datas.each do |data|
          text = data.value_of item
          @view.haml_tag :div, text, :class => data.css_class
        end
        @context_datas = [] # clean
      end

      def add(name, *args, &block)
        data = TileData.new(name.to_s, *args, &block)
        data.tile = @tile
        @context_datas << data
        self
      end
    end

    class TileId
      def initialize(*args, &block)
        @id = args.first
        @block = block
      end

      def tile=(tile)
        @tile = tile
        @view = tile.view
      end

      def render(item)
        value = @block.nil? ? @id : @view.capture {@block.call(item)}
        value.to_s.strip
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

        @context = []

        @id = nil
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

      def context(&block)
        c = TileContext.new(&block)
        c.tile = self
        @context << c
        self
      end

      def set_id(*args, &block)
        obj = TileId.new(*args, &block)
        obj.tile = self
        @id = obj
        self
      end

      def body_css_class
        [
          'tile-body',
          (@left_datas.blank? ? 'no-left' : ''),
          (@right_datas.blank? ? 'no-right' : '')
        ].join(' ').strip
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
          id = @id.blank? ? '' : @id.render(item)

          hash = if @id.blank? then
            { :class => div_css_class }
          else
            { :id => id, :class => div_css_class }
          end

          @view.haml_tag :div, hash do
            _render_left(item)
            _render_body(item)
            _render_right(item)
          end
        end

        def _render_context(item)
          @context.each do |ct|
            ct.render(item)
          end
        end

        def _render_left(item)
          _render_x(item, @left_datas, 'tile-left')
        end

        def _render_right(item)
          _render_x(item, @right_datas, 'tile-right')
        end

        def _render_body(item)
          @view.haml_tag :div, :class => self.body_css_class do
            _render_context(item)
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