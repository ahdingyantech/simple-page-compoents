# -*- encoding : utf-8 -*-
require 'navbar'
require 'data_table'
require 'data_tile'
require 'progress_bar'
require 'button_group'

module SimplePageCompoents
  module Helper
    def page_navbar(*args, &block)
      navbar = NavbarRender.new(self, *args)
      yield navbar
      capture {navbar.render}
    end

    def page_data_table(name, items, *args)
      table = DataTable::Render.new(self, name, items, *args)
      yield table
      capture {table.render}
    end

    def page_tile(name, items, *args)
      tile = DataTile::Render.new(self, name, items, *args)
      yield tile
      capture {tile.render}
    end

    def page_progress_bar(percent = 0, *args)
      pb = ProgressBar::Render.new(self, percent, *args)
      capture {pb.render}
    end

    def page_button_group(name, *args)
      button_group = ButtonGroup::Render.new(self, name, *args)
      yield button_group
      capture {button_group.render}
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

