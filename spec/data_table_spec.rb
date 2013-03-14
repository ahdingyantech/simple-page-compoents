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
        MockItem.new('foo', 'bar', :hee),
        MockItem.new('magic', 'fire', 'skill'),
        MockItem.new('blz', :wow, 'game')
      ]

      @first_item = @items[0]
    }

    before(:each) {
      @table = Render.new($view, :test, @items)
      @table.
        add_column(:name).
        add_column(:val) { |item|
          item.value
        }.
        add_column(:kind)

      @html = $view.capture_haml {@table.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it 'items should be pass' do
      puts @html
      @table.items.should == @items
    end

    it {
      @table.columns.length.should == 3
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

    it do
      @nokogiri.css('tbody > tr > td')[0].text.
        should == 'foo'
    end

    it 'td class name should be column name' do
      @nokogiri.css('tbody > tr > td')[1]['class'].
        should == 'val'
    end

    it {
      @nokogiri.css('tbody > tr > td')[1].text.
        should == 'bar'
    }

    it 'test bugfix Issue #1' do
      @nokogiri.css('tbody > tr > td')[2].text.
        should == 'hee'
    end

    context TableColumn do
      context '#value_of' do
        it {
          @table.columns[0].value_of(@first_item).should == 'foo'
        }

        it {
          @table.columns[1].value_of(@first_item).should == 'bar'
        }

        it {
          @table.columns[2].value_of(@first_item).should == 'hee'
        }
      end
    end
  end
end