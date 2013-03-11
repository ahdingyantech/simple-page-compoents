require 'spec_helper'

include SimplePageCompoents

describe SimplePageCompoents::NavbarRender do
  before {
    @view = stub("view")
  }

  describe '.initialize' do
    it {
      NavbarRender.new(@view).view.should == @view
    }
  end

  describe '#css_class' do
    it {
      NavbarRender.new(@view).css_class.should == 'page-navbar'
    }

    it {
      NavbarRender.new(@view, :fixed_top, :color_inverse).css_class.should == 
        'page-navbar fixed-top color-inverse'

      NavbarRender.new(@view, :color_inverse, :fixed_top).css_class.should == 
        'page-navbar fixed-top color-inverse'
    }
  end

  describe '#add_item' do
    before(:all) {
      @navbar = NavbarRender.new(@view)
    }

    it {
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
      @navbar.items[1].items.length.should == 1
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
  end

  describe '#add_item_obj' do
    before(:all) {
      @navbar = NavbarRender.new(@view)
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
end

describe SimplePageCompoents::NavItem do
end