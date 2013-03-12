# -*- encoding : utf-8 -*-
module SimplePageCompoents
  class NavItem
    attr_accessor :text, :url
    attr_accessor :parent, :view
    attr_accessor :items
    
    def initialize(text, url)
      @parent = nil
      @view   = nil

      @text = text
      @url  = url

      @items = []
    end

    def is_active?
      @view.request.path == @url
    end

    def css_class
      is_active? ? 'active' : nil
    end

    def render
      @view.haml_tag :li, :class => self.css_class do
        @view.haml_tag :a, @text,:href => @url

        @view.haml_tag :ul, :class => 'nav' do
          @items.each { |item| item.render }
        end if @items.present?
      end
    end

    def add_item(text, url, &block)
      item = NavItem.new(text, url)
      add_item_obj item
      yield item if block_given?
      self
    end

    def add_item_obj(item)
      item.parent = self
      item.view = @view
      @items << item
      self
    end
  end

  class NavbarRender
    attr_accessor :view, :items

    def initialize(view, *args)
      @view = view
      @items = []
      @prepends = []

      @fixed_top = args.include? :fixed_top
      @fixed_bottom = args.include? :fixed_bottom
      @color_inverse =  args.include? :color_inverse
    end

    def css_class
      c = ['page-navbar']
      c << 'fixed-top' if @fixed_top
      c << 'fixed-bottom' if @fixed_buttom
      c << 'color-inverse' if @color_inverse

      c.join(' ')
    end

    def add_item(text, url, &block)
      item = NavItem.new(text, url)
      add_item_obj item
      yield item if block_given?
      self
    end

    def add_item_obj(item)
      item.parent = self
      item.view = @view
      @items << item
      self
    end

    def prepend(str = '', &block)
      @prepends << str
      self
    end

    def render
      @view.haml_tag :div, :class => self.css_class do
        @view.haml_tag :div, :class => 'navbar-inner' do
          _render_prepend

          @view.haml_tag :ul, :class => 'nav' do
            @items.each { |item| item.render }
          end if @items.present?
        end
      end
    end

    private
      def _render_prepend
        return if @prepends.blank?
        @view.haml_tag :div, :class => 'navbar-prepend' do
          @prepends.each do |p|
            @view.haml_concat p
          end
        end
      end
  end
end
