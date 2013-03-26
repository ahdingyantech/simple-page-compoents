# -*- encoding : utf-8 -*-
require 'spec_helper'

include SimplePageCompoents

describe SimplePageCompoents::ProgressBar::Render do
  describe '.initialize' do
    before {
      @bar = ProgressBar::Render.new($view)
      @html = $view.capture_haml {@bar.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it('view should be pass') {
      @bar.view.should == $view
    }

    it {
      @html.should_not be_blank
      puts @html
    }
  end

  describe '#percent' do
    before {
      @bar = ProgressBar::Render.new($view, 62)
      @html = $view.capture_haml {@bar.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @bar.percent.should == 62
    }

    it {
      @nokogiri.css('.page-progress > .bar')[0]['style'].
        should == 'width:62%;'
    }
  end

  describe '#css_class' do
    before {
      @bar = ProgressBar::Render.new($view, 62, :striped, :active, :success)
      @html = $view.capture_haml {@bar.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @bar.percent.should == 62
    }

    it {
      @bar.css_class.should == 'page-progress striped active success'
    }
  end
end
