# -*- encoding : utf-8 -*-
module SimplePageCompoents
  module DataTile
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

    class TileData
      attr_reader :name, :position
      attr_accessor :tile

      def initialize(name, position, *args, &block)
        @name = name
        @position = position
        @block = block

        @bold = args.include? :bold
        @quiet = args.include? :quiet

        @font12 = args.include? :font12
        @font13 = args.include? :font13
        @font14 = args.include? :font14
        @font15 = args.include? :font15
        @font16 = args.include? :font16
      end

      def tile=(tile)
        @tile = tile
        @view = tile.view
      end

      def value_of(item)
        value = @block.nil? ? item.send(@name) : @view.capture {@view.instance_exec item, &@block}
        value.to_s
      end

      def css_class
        c = ['tile-field', @name]
        c << 'bold' if @bold
        c << :quiet if @quiet
        c << :font12 if @font12
        c << :font13 if @font13
        c << :font14 if @font14
        c << :font15 if @font15
        c << :font16 if @font16
        c.join ' '
      end
    end

    class TileContext
      attr_reader :datas

      def initialize(&block)
        @block = block
        @datas = []
      end

      def position
        :context
      end

      def tile=(tile)
        @tile = tile
        @view = tile.view
      end

      def add(name, *args, &block)
        data = TileData.new(name.to_s, :body, *args, &block)
        data.tile = @tile
        @datas << data
        self
      end

      def add_foot(name, *args, &block)
        data = TileData.new(name.to_s, :foot, *args, &block)
        data.tile = @tile
        @datas << data
        self
      end

      def call(item)
        instance_exec item, self, &@block
      end

      def clean!
        @datas = []
      end
    end

    class DataStack
      attr_accessor :body, :left, :right, :foot

      def initialize
        @body = []
        @left = []
        @right = []
        @foot = []
      end
    end

    class Render
      attr_reader :view, :items, :name
      attr_reader :datas, :left_datas, :foot_datas

      def initialize(view, name, items = [], *args)
        @view = view
        @items = items
        @name = name

        @datas = []

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

      def set_id(*args, &block)
        obj = TileId.new(*args, &block)
        obj.tile = self
        @id = obj
        self
      end

      def add(name, *args, &block)
        _add_x(name, :body, *args, &block)
      end

      def add_left(name, *args, &block)
        _add_x(name, :left, *args, &block)
      end

      def add_right(name, *args, &block)
        _add_x(name, :right, *args, &block)
      end

      def add_foot(name, *args, &block)
        _add_x(name, :foot, *args, &block)
      end

      def context(&block)
        c = TileContext.new(&block)
        c.tile = self
        @datas << c
        self
      end

      def body_css_class(stack)
        [
          'tile-body',
          (stack.left.blank? ? 'no-left' : nil),
          (stack.right.blank? ? 'no-right' : nil)
        ].compact.join(' ').strip
      end

      private
        def _add_x(name, position, *args, &block)
          data = TileData.new(name.to_s, position, *args, &block)
          data.tile = self
          @datas << data
          self
        end

        def _push_stack!(stack, datas, item)
          datas.each do |data|
            case data.position
              when :body
                stack.body << data
              when :left
                stack.left << data
              when :right
                stack.right << data
              when :foot
                stack.foot << data
              when :context
                data.call(item)
                _push_stack!(stack, data.datas, item)
                data.clean!
            end
          end
        end

        def _render_line(item)
          div_css_class = ['tile-item', item.class.to_s.tableize.singularize] * ' '
          id = @id.blank? ? '' : @id.render(item)

          hash = if @id.blank? then
            { :class => div_css_class }
          else
            { :id => id, :class => div_css_class }
          end

          stack = DataStack.new
          _push_stack!(stack, @datas, item)

          @view.haml_tag :div, hash do
            _render_left(item, stack)
            _render_body(item, stack)
            _render_right(item, stack)
          end
        end

        def _render_left(item, stack)
          _render_x(item, stack.left, 'tile-left')
        end

        def _render_right(item, stack)
          _render_x(item, stack.right, 'tile-right')
        end

        def _render_body(item, stack)
          @view.haml_tag :div, :class => self.body_css_class(stack) do
            stack.body.each do |data|
              text = data.value_of item
              @view.haml_tag :div, text, :class => data.css_class
            end
            _render_foot(item, stack)
          end
        end

        def _render_foot(item, stack)
          _render_x(item, stack.foot, 'tile-foot')
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