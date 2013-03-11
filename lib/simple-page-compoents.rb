module SimplePageCompoents
  class NavbarRender

    class NavItem
      attr_accessor :text, :url
      def initialize(parent, text, url)
        @parent = parent
        @view = parent.view

        @text = text
        @url  = url
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
        end
      end
    end

    attr_accessor :view

    def initialize(view, *args)
      @view = view
      @items = []
      @prepends = []

      @fixed_top = args.include? :fixed_top
      @fixed_bottom = args.include? :fixed_bottom
      @color_inverse =  args.include? :color_inverse
    end

    def add_item(text, url)
      @items << NavItem.new(self, text, url)
      self
    end

    def prepend(str)
      @prepends << str
    end

    def css_class
      c = ['page-navbar']
      c << 'navbar-fixed-top' if @fixed_top
      c << 'navbar-fixed-bottom' if @fixed_buttom
      c << 'color-inverse' if @color_inverse

      c.join(' ')
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
            @items.each do |item|
              item.render
            end
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