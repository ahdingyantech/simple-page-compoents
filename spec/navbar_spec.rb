require 'spec_helper'

include SimplePageCompoents

describe SimplePageCompoents::NavbarRender do
  describe '.initialize' do
    it('view should be pass') {
      NavbarRender.new($view).view.should == $view
    }
  end

  describe '#css_class' do
    it {
      NavbarRender.new($view).css_class.should == 'page-navbar'
    }

    it {
      NavbarRender.new($view, :fixed_top, :color_inverse).css_class.should == 
        'page-navbar fixed-top color-inverse'

      NavbarRender.new($view, :color_inverse, :fixed_top).css_class.should == 
        'page-navbar fixed-top color-inverse'
    }
  end

  describe '#add_item' do
    before(:all) {
      @navbar = NavbarRender.new($view)
    }

    it('view should pass') {
      @navbar.items.should == []
    }

    it {
      @navbar.add_item('haha', '/')
      @navbar.items.length.should == 1
    }

    it {
      @navbar.add_item 'water', '/water' do |item|
        item.add_item 'fire', '/fire'
      end
      @navbar.items.length.should == 2
    }

    it {
      @navbar.items.length.should > 0
    }

    it 'items should find parent' do
      @navbar.items.each { |item|
        item.parent.should == @navbar
      }
    end

    it 'items should find view' do
      @navbar.items.each { |item|
        item.view.should == @navbar.view
      }
    end

    it {
      @navbar.items[0].text.should == 'haha'
    }

    it {
      @navbar.items[1].text.should == 'water'
    }

    it {
      @navbar.items[1].items[0].text.should == 'fire'
    }

    context "item's item" do
      before(:all) {
        @last_item = @navbar.items[-1]
      }

      it {
        @last_item.items.length.should == 1
      }

      it "item's items should find parent" do
        @last_item.items.each do |item|
          item.parent.should == @last_item
        end
      end

      it "item's items should find view" do
        @last_item.items.each do |item|
          item.view.should == @last_item.view
        end
      end
    end
  end

  describe '#add_item_obj' do
    before(:all) {
      @navbar = NavbarRender.new($view)
    }

    it {
      @navbar.add_item_obj NavItem.new('haha', '/')
      @navbar.items.length.should == 1
    }

    it {
      @navbar.add_item_obj NavItem.new('fire', '/fire')
      @navbar.items.length.should == 2
    }
  end

  describe '#render' do
    before(:each) {
      req = stub(:req)
      req.stub(:path).and_return '/fire'
      $view.request = req

      @navbar = NavbarRender.new($view)
    }

    context 'blank' do
      before {
        @html = $view.capture_haml {@navbar.render}
      }

      it {
        Nokogiri::XML(@html).at_css('.page-navbar > .navbar-inner').
          content.should be_blank
      }
    end

    context 'with items' do
      before {
        @navbar.add_item('fire', '/fire')
        @html = $view.capture_haml {@navbar.render}
      }

      it {
        Nokogiri::XML(@html).at_css('.page-navbar > .navbar-inner > ul.nav > li.active > a').
          content.should == 'fire'
      }
    end

    context 'with nested items' do
      before {
        @navbar.add_item('fire', '/fire')
        @navbar.add_item('water', '/water') do |item|
          item.add_item 'light', '/light'
        end

        @html = $view.capture_haml {@navbar.render}
      }

      it {
        Nokogiri::XML(@html).css('.page-navbar > .navbar-inner > ul.nav > li').
          length.should == 2
      }

      it {
        Nokogiri::XML(@html).css('.page-navbar > .navbar-inner > ul.nav > li li').
          length.should == 1
      }
    end

    context 'with prepends' do
      before {
        @navbar.add_item('fire', '/fire')
        @navbar.add_item('water', '/water') do |item|
          item.add_item 'light', '/light'
        end

        @navbar.prepend $view.content_tag(:div, '123', :class => 'tomo')

        @html = $view.capture_haml {@navbar.render}
      }

      it {
        Nokogiri::XML(@html).
          at_css('.page-navbar .navbar-prepend').
          at_css('div.tomo').content.should == '123'
      }
    end

  end
end

describe SimplePageCompoents::NavItem do
end