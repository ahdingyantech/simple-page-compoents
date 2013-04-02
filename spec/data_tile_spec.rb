# -*- encoding : utf-8 -*-
require 'spec_helper'

include SimplePageCompoents::DataTile

class MockApple
  attr_accessor :avatar, :title, :content, :comments
  def initialize(avatar, title, content, comments)
    @avatar, @title, @content, @comments = avatar, title, content, comments
  end
end

describe SimplePageCompoents::DataTile::Render  do
  before(:all) {
    @items = [
      MockApple.new('/tom.png'   , 'cat'   , :catch  , 8),
      MockApple.new('/jerry.png' , 'mouse' , 'run'   , 9),
      MockApple.new('/ben.png'   , 'slm'   , 'what?' , 3)
    ]

    @first_item = @items[0]
  }

  describe '.initialize' do
    it('view should be pass') {
      SimplePageCompoents::DataTile::Render.new($view, :test).view.should == $view
    }
  end

  describe '#css_class' do
    it {
      @tile = SimplePageCompoents::DataTile::Render.new $view, :users
      @tile.css_class.should == 'page-data-tile users'
    }
  end

  describe '#render (no models)' do
    before(:each) {
      @tile = SimplePageCompoents::DataTile::Render.new($view, :test)
      @html = $view.capture_haml {@tile.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @html.should_not be_blank
    }

    it {
      @nokogiri.at_css('.page-data-tile').content.should be_blank
    }

    it {
      @nokogiri.at_css('div')['class'].should == 'page-data-tile test'
    }
  end

  describe '#add' do
    before(:each) {
      @tile = SimplePageCompoents::DataTile::Render.new($view, :test, @items)
      @tile.
        add(:title).
        add(:content).
        add(:avatar) { |item|
          "(#{item.avatar})"
        }

      @html = $view.capture_haml {@tile.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it 'items should be pass' do
      @tile.items.should == @items
    end

    it {
      @tile.datas.length.should == 3
    }

    it {
      @tile.datas[0].name.should == 'title'
    }

    it 'table object should be pass in add_column' do
      @tile.datas[1].tile.should == @tile
    end

    it {
      @nokogiri.css('.page-data-tile.test > .tile-item.mock_apple').length.should == 3
    }

    it {
      @nokogiri.css('.page-data-tile.test > .tile-item.mock_apple > .tile-body > .tile-field.title').length.
        should == 3
    }

    it {
      @nokogiri.css('.page-data-tile.test > .tile-item.mock_apple > .tile-body > .tile-field.content').length.
        should == 3
    }

    it {
      @nokogiri.css('.page-data-tile.test > .tile-item.mock_apple > .tile-body > .tile-field.avatar').length.
        should == 3
    }

    it {
      @tile.items[0].class.should == MockApple
    }

    it do
      @nokogiri.css('.page-data-tile.test > .mock_apple > .tile-body > .title')[0].text.
        should == 'cat'
    end

    context '#add_left, #add_foot' do
      before(:each) {
        @tile.add_left(:avatar)
        @tile.add_foot(:comments) do |item|
          "#{item.comments}条评论"
        end

        @html = $view.capture_haml {@tile.render}
        @nokogiri = Nokogiri::XML(@html)
      }

      it {
        @nokogiri.css('.page-data-tile.test > .mock_apple > .tile-left').length.
          should == 3
      }

      it {
        @nokogiri.css('.page-data-tile.test > .mock_apple > .tile-body > .tile-foot').
          length.should == 3
      }

      it {
        @nokogiri.css('.tile-right').length.should == 0
      }

      context '#add_right' do
        before {
          @tile.add_right(:gogo) do |item|
            '不是吧'
          end

          @html = $view.capture_haml {@tile.render}
          @nokogiri = Nokogiri::XML(@html)
        }

        it {
          @nokogiri.css('.page-data-tile.test > .mock_apple > .tile-right').
            length.should == 3
        }
      end
    end
  end

  context 'no-left' do
    before(:each) {
      @tile = SimplePageCompoents::DataTile::Render.new($view, :test, @items)
      @tile.
        add(:title).
        add(:content).
        add(:avatar) { |item|
          "(#{item.avatar})"
        }

      @html = $view.capture_haml {@tile.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @nokogiri.css('.tile-body.no-left.no-right').length.should == 3
    }
  end

  context 'bold' do
    before(:each) {
      @tile = SimplePageCompoents::DataTile::Render.new($view, :test, @items)
      @tile.
        add(:title, :bold).
        add(:content).
        add(:avatar) { |item|
          "(#{item.avatar})"
        }

      @html = $view.capture_haml {@tile.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @nokogiri.css('.tile-body .title.bold').length.should == 3
    }
  end

  context '#set_id' do
    before(:each) {
      @tile = SimplePageCompoents::DataTile::Render.new($view, :test, @items)
      @tile.
        set_id { |item|
          'hohoho'
        }.
        add(:title, :bold).
        add(:content).
        add(:avatar) { |item|
          "(#{item.avatar})"
        }

      @html = $view.capture_haml {@tile.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      @nokogiri.css('#hohoho').length.should == 3
    }
  end

  context '#context' do
    before(:each) {
      @tile = SimplePageCompoents::DataTile::Render.new($view, :test, @items)
      @tile.add_left(:abc) {'test'}
      @tile.context do |item|
        add(:title, :bold)
        add(:content)
        add(:avatar) {
          "(#{item.avatar})"
        }
      end
      @tile.add(:foo) do
        :bar
      end
      @tile.context do |item|
        add(:hehe) { '笑' }
      end



      @html = $view.capture_haml {@tile.render}
      @nokogiri = Nokogiri::XML(@html)
    }

    it {
      puts @html
      @nokogiri.css('.mock_apple .title.bold').length.should == 3
    }

    it {
      @nokogiri.css('.tile-left + .tile-body').length.should == 3
    }
  end
end