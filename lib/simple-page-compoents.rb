module SimplePageCompoents

  class NavItem
    attr_accessor :text, :url
    attr_accessor :view, :items
    
    def initialize(text, url)
      @parent = nil
      @view = parent.view

      @text = text
      @url  = url

      @items = []
    end

    def is_active?
      @view.request.path == @url
    end

    def css_class
      is_active? ? 'active' : ''
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
      add_item_obj NavItem.new(text, url)
    end

    def add_item_obj(item)
      item.parent = self
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
      c << 'navbar-fixed-top' if @fixed_top
      c << 'navbar-fixed-bottom' if @fixed_buttom
      c << 'color-inverse' if @color_inverse

      c.join(' ')
    end

    def add_item(text, url, &block)
      add_item_obj NavItem.new(text, url)
    end

    def add_item_obj(item)
      item.parent = self
      @items << item
      self
    endqui

    def prepend(str)
      @prepends << str
    end

    def render
      @view.haml_tag :div, :class => self.css_class do
        @view.haml_tag :div, :class => 'navbar-inner' do
          @view.haml_tag :div, :class => 'nav-prepend' do
            @prepends.each do |p|
              @view.haml_concat p
            end
          end

          @view.haml_tag :ul, :class => 'nav' do
            @items.each { |item| item.render }
          end
        end
      end
    end
  end

  module Helper
    def page_navbar(*args)
      NavbarRender.new(self, *args)
    end

    def page_breadcrumb(*args)
      BreadcrumbRender.new(self, *args)
    end
  end

  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'SimplePageLayout.helper' do |app|
        ActionView::Base.send :include, Helper
      end
    end

    class Engine < ::Rails::Engine
    end
  end
end