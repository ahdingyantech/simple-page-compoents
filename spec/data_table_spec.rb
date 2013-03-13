# -*- encoding : utf-8 -*-
require 'spec_helper'

include SimplePageCompoents::DataTable

class MockItem
  attr_accessor :name, :value, :kind
  def initialize(name, value, kind)
    @name, @value, @kind = name, value, kind
  end
end

describe SimplePageCompoents::DataTable::Render  do
  describe '.initialize' do
    it('view should be pass') {
      Render.new($view, :test).view.should == $view
    }
  end

  describe '#css_class' do
    before {
      @table = Render.new $view, :users
      @table.css_class.should == 'page-data-table users'
    }
  end

  describe '#render (no models)' do
    before(:each) {
      @table = Render.new($view, :test)
      @html = $view.capture_haml {@table.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @html.should_not be_blank
    }

    it 'should have thead' do
      @nokogiri.at_css('table > thead > tr').should_not be_blank
    end

    it 'should have tbody' do
    end

    it {
      @nokogiri.at_css('table')['class'].should == 'page-data-table test'
    }
  end

  describe '#add_column' do
    before(:all) {
      @items = [
        MockItem.new('foo', 'bar', 'hee'),
        MockItem.new('magic', 'fire', 'skill'),
        MockItem.new('blz', 'wow', 'game')
      ]
    }

    before(:each) {
      @table = Render.new($view, :test, @items)
      @table.
        add_column(:name).
        add_column(:val) do |item|
          item.value
        end

      @html = $view.capture_haml {@table.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it 'items should be pass' do
      puts @html
      @table.items.should == @items
    end

    it {
      @table.columns.length.should == 2
    }

    it {
      @table.columns[0].name.should == 'name'
    }

    it 'table object should be pass in add_column' do
      @table.columns[1].table.should == @table
    end

    it {
      @nokogiri.at_css('th.name').text.
        should == I18n.t('compoents.data_table.test.name')
    }

    it {
      @nokogiri.css('tbody > tr').length.should == 3
    }

    it {
      @nokogiri.css('tbody > tr')[0]['class'].should == 'mock_item'
    }

    it {
      @nokogiri.css('tbody > tr > td')[0]['class'].
        should == 'name'
    }

    it {
      @table.items[0].class.should == MockItem
    }
    
    it {
      @nokogiri.css('tbody > tr > td')[0].text.
        should == 'foo'
    }

    it {
      @nokogiri.css('tbody > tr > td')[1]['class'].
        should == 'val'
    }

    it {
      @nokogiri.css('tbody > tr > td')[1].text.
        should == 'bar'
    }
  end
end