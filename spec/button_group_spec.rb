# -*- encoding : utf-8 -*-
require 'spec_helper'

include SimplePageCompoents

describe SimplePageCompoents::ButtonGroup::Render do
  describe '.initialize' do
    before {
      @button_group = ButtonGroup::Render.new($view)
      @html = $view.capture_haml {@button_group.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it('view should be pass') {
      @button_group.view.should == $view
    }

    it {
      @html.should_not be_blank
    }
  end

  describe '#add' do
    before {
      @button_group = ButtonGroup::Render.new($view)
      @button_group.add '这是按钮', '/foo/bar'
    }

    it {
      @button_group.buttons.count.should == 1
    }

    it {
      @button_group.add '类型一', '/foo/bar/1'
      @button_group.add '类型二', '/foo/bar/2'
      @button_group.buttons.count.should == 3
    }

    it('button_group should be pass') {
      @button_group.buttons[0].button_group.should == @button_group
    }
  end

  describe '#render' do
    before {
      @button_group = ButtonGroup::Render.new($view)
      @button_group.add '我是歌手', '/singer'
      @button_group.add '我是程序员', '/coder', :info
      @button_group.add '我是手艺人', '/crafter', :success

      @html = $view.capture_haml {@button_group.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      puts @html
      @html.should_not be_blank
    }

    it {
      @nokogiri.css('.btn-group > a.btn').length.should == 3
    }

    it {
      @nokogiri.css('.btn-group > a.btn')[0]['class'].should == 'btn'
    }

    it {
      @nokogiri.css('.btn-group > a.btn')[1]['class'].should == 'btn info'
    }

    it {
      @nokogiri.css('.btn-group > a.btn')[2]['class'].should == 'btn success'
    }
  end
end
