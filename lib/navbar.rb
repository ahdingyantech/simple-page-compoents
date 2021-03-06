# -*- encoding : utf-8 -*-
module SimplePageCompoents
  module CanRenderNavUl
    private
      def _render_ul
        ul_css_class = 'nav'
        ul_css_class = 'sidebar-menu' if @new_theme.present? && @new_theme
        @view.haml_tag :ul, :class => ul_css_class do
          @items.each { |item| item.render }
        end if @items.present?
      end
  end

  class NavItem
    include CanRenderNavUl

    attr_accessor :text, :url
    attr_accessor :parent, :view
    attr_accessor :items
    attr_accessor :ico_class
    
    def initialize(text, url, options = {})
      @option_class = options[:class] || ''
      @option_ico_class = options[:ico_class] || ''

      @parent = nil
      @view   = nil

      @text = text
      @url  = url

      @items = []
    end

    def is_active?
      @view.request.path == @url
    rescue
      false
    end

    def css_class
      c = [@option_class]
      c << 'active' if is_active?

      re = c.join(' ')

      re.blank? ? nil : re
    end

    def render
      @view.haml_tag :li, :class => self.css_class do
        _render_a
        _render_ul
      end
    end

    def add_item(text, url, options = {}, &block)
      item = NavItem.new(text, url)
      add_item_obj item
      yield item if block_given?
      self
    end

    # 此方法为预留钩子，一般不用
    def add_item_obj(item)
      item.parent = self
      item.view = @view
      @items << item
      self
    end

    def with_icon?
      @parent.with_icon?
    end

    def new_theme?
      @parent.new_theme?
    end

    private
      def _render_a
        if @url.blank?
          @view.haml_tag :div, @text, :class => 'static'
          return
        end

        if self.new_theme?
          @view.haml_tag :a, :href => @url do
            @view.haml_tag :i, '', :class => 'fa ' + @option_ico_class
            @view.haml_tag :span, @text
          end
          return
        end

        if self.with_icon?
          @view.haml_tag :a, :href => @url do
            @view.haml_tag :i, '', :class => 'icon'
            @view.haml_concat @text
          end
          return
        end

        @view.haml_tag :a, @text, :href => @url
      end
  end

  class NavbarRender
    include CanRenderNavUl
    
    attr_accessor :view, :items

    def initialize(view, *args)
      @view = view
      @items = []
      @prepends = []

      @fixed_top = args.include? :fixed_top
      @fixed_bottom = args.include? :fixed_bottom
      @color_inverse =  args.include? :color_inverse
      @as_list = args.include? :as_list
      @with_icon = args.include? :with_icon
      @new_theme = args.include? :new_theme
      @attached_style = args - [:fixed_top, :fixed_bottom, :color_inverse, :as_list, :with_icon, :new_theme]
    end

    def css_class
      if @as_list
        return 'page-navlist'
      end

      c = ['page-navbar']
      c << 'fixed-top' if @fixed_top
      c << 'fixed-bottom' if @fixed_buttom
      c << 'color-inverse' if @color_inverse
      c << @attached_style.join(' ') if @attached_style

      c.join(' ')
    end

    def inner_css_class
      if @as_list
        return 'navlist-inner'
      end

      'navbar-inner'
    end

    def add_item(text, url, options = {}, &block)
      item = NavItem.new(text, url)
      add_item_obj item
      yield item if block_given?
      self
    end

    # 此方法为预留钩子，一般不用
    def add_item_obj(item)
      item.parent = self
      item.view = @view
      @items << item
      self
    end

    def with_icon?
      @with_icon
    end

    def new_theme?
      @new_theme
    end

    def prepend(str = '', &block)
      @prepends << str
      self
    end

    def render
      if @new_theme
        _render_prepend
        _render_ul
      else
        @view.haml_tag :div, :class => self.css_class do
          @view.haml_tag :div, :class => self.inner_css_class do
            _render_prepend
            _render_ul
          end
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

