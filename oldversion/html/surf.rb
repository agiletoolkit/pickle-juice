
# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'watir' 
require 'test/unit'

module Longboard
  
  module SurfTable   
    def get_table
      @@element_index = 1
      @@element = subelement('table')
    end
    
    def find_row_in_table
      row_values = @@element.row_values(@@element_index)
      table_values = [@col_1.to_s, @col_2.to_s, @col_3.to_s, @col_4.to_s, @col_5.to_s, @col_6.to_s, @col_7.to_s, @col_8.to_s]
      table_values = table_values.collect!{| value | value == 'blank' ? '' : value } 
      @@element_index += 1
      table_values = table_values[0..row_values.size-1]
      if row_values == table_values 
        return true
      end
      return row_values
    end
    
    def table_cell_should_equal
      get_table
      row_values = @@element.row_values(@row)
      return @adapter.to_fit( row_values[@col-1] )
    end	  
  end     
  
  module SurfDirectMethods
    # browser control
    ### Page functions
    def find_text_on_page 
      clear_return(@browser.contains_text(@value) )
    end
    def page_should_equal 
      clear_return( Page.new(@name,@mapper.resolve_name(@name)).should_equal(@browser,@value) )
    end
    def go_to_page 
      clear_return( Page.new(@name,@mapper.resolve_name(@name)).navigate_to(@browser) )       
    end

    def subelement(type)
      @browser.subelement(type, @mapper.resolve_name(@name))
    end
    
    def  title_should_equal 
      @value== @browser.title
    end
    
    #Map action to local method call
    def take_action 
      clear_return(send(@action.gsub(/\s/, '_')))
    end
    
    
    def click_link 
      subelement('link').click    
    end
    
    
    def set_value_of_radio_button
      radios = @browser.radios
      for radio in radios
        if radio.value == @value
          radio.set
        end
      end
    end
    
    def radio_button_should_equal
      radios = @browser.radios
      for radio in radios
        if radio.isSet?
          return @adapter.to_fit(radio.value)
        end
      end
    end   
    
    
    def set_value_of_checkbox
      box = subelement('checkbox')
      if @value == 'checked'
        box.set   
        return true
      end
      if @value == 'unchecked'
        box.clear   
        return true
      end	
      false
    end 	    
    def checkbox_should_equal
      if subelement('checkbox').isSet? 
        return 'checked'
      end 
      return 'unchecked'
    end 
    
    def set_value_of_file_field
      subelement('file_field').set(@value)
    end
    def get_input
      return   subelement('text_field')
    end 
    
    def set_value_of_input
      get_input.set(@adapter.to_browser(@value))
    end
    def input_should_contain
      contents =    get_input.getContents
      if contents.index(@value)
        return true
      end		
      return false
    end 
    
    def input_should_equal
      @adapter.to_fit( get_input.getContents)
    end 
    
    
    def set_value_of_drop_down
      subelement('select_list').select(@value.to_s)
    end 
    def drop_down_should_equal
      @adapter.to_fit(subelement('select_list').getSelectedItems.first)
    end   
    
    
    def select_value_in_multi_select
      subelement('select_list').select(@value)
    end   
    
    def value_exists_in_list (items) 
      for item in items 
        if item.strip == @value.strip
          return true
        end
      end
      false
    end
    
    def multi_select_should_contain
      value_exists_in_list (subelement('select_list').getAllContents)
    end
    
    def clear_multi_select
      subelement('select_list').clearSelection
    end
    def multi_select_should_be_selected
      value_exists_in_list (subelement('select_list').getSelectedItems)
    end
    
    
    
    def click_button
      return   subelement('button').click   
    end 
  end  
  
  
  
  class Surf < Fit::ColumnFixture
    attr_accessor :action,:name, :type, :identifier, :col_1,:col_2,:col_3,:col_4,:col_5,:col_6,:col_7,:col_8, :row, :col
    include SurfTable
    include SurfDirectMethods
    def initialize
      @browser = Browser.new
      @mapper = ElementMapper.new
      @adapter = FitTypeAdapter.new
    end 
    
    def value=(value)
      @value=@adapter.from_fit(value)
    end
    def value
      @value
    end
    def clear_return(value)
      clear
      value
    end
    def clear
      @name, @value, @action, @identifier,  @type, @col_1, @col_2, @col_3, @col_4, @col_5, @col_6, @col_7, @col_8, @row, @col = nil
    end 
    def pause 
      sleep @value.to_i
    end
    
    def set_value
      element = @mapper.get(@name)
      clear_return(element.set_value(@browser, @value))
    end
    
     
    def attach_window
      @browser.attachWindow(@value)
    end
    
    def expect_window
      @browser.expectWindow
    end
     def switch_window_focus
      ret = nil
      if @value
        ret = @browser.setCurrentByName(@value)
      else
        ret = @browser.swapWindow
      end
      clear_return(ret)
    end
        
    def close_browser 
      @browser.close
    end
    def open_browser 
      @browser.open(@value)
    end
    
    def map_element
      if (!defined? @type && @type!=nil )
        @type = 'Element'
      end
      begin
        element = Longboard.const_get(@type).new(@name,@identifier)
      rescue
        element = Longboard.const_get('Element').new(@name,@identifier)
      end
      
      ret = @mapper.map(element)
      clear
      if ret.name
        return true
      end
      false
    end	
    
    def map_name
      com = Element.new(@name, @value)
      ret = @mapper.map(com)
      clear
      ret.name
    end	
    
    def clear_name_map
      @mapper.clear  
    end	    
    
    def should_be_selected
      element = @mapper.get(@name)
      clear_return(element.should_be_selected(@browser, @value))
    end
    def should_equal
      element = @mapper.get(@name)
      clear_return(element.should_equal(@browser, @value))
    end
    
    def should_contain
      element = @mapper.get(@name)
      clear_return(element.should_contain(@browser, @value))
    end
    def navigate_to
      element = @mapper.get(@name)
      clear_return(element.navigate_to(@browser))
    end
    def click
      element = @mapper.get(@name)
      clear_return(element.click(@browser, @value))
    end
  end
  
  class FitTypeAdapter
    def from_fit(value)
      value = value.to_s.strip.gsub('&','')    
      if !((value =~ /^-?\d*\.\d+$/ || value =~ /^-?\d+$/))
        value = value.gsub('comma', ',')
      end
      return value
    end 
    def to_fit(value)
      value = value.strip
      if (value == '' || value == nil)
        return 'blank'
      end  
      if (value =~ /^-?\d*\.\d+$/ || value =~ /^-?\d+$/)
        return value.to_f 
      end  
      value.gsub(',','&comma' )
    end     
    def to_browser(value)
      value=value.to_s.gsub('EscapedAmp','&' )
      if value == 'blank' || value == nil
        value=''
      end  
      return value 
    end
    
  end
  
  
  class Browser 
    def open(speed)
      $browsers = BrowserCollection.new unless $browsers
      $browsers.addBrowser(Watir::IE.new)
      $ie = $browsers.getCurrentBrowser
      if speed == 'slow'
        $ie.set_slow_speed     
      else
        $ie.set_fast_speed         
      end	
    end
    def setCurrentByName(name)
      
      ret = $browsers.setCurrentByName(name)
      if ret == nil
        $browsers.getCurrentBrowser.attach_init(:title, name)
      end
      
      assign_ie
    end
    def expectWindow
      return $ie.title
      $ie.capture_events
    end
    def assign_ie
      $ie = $browsers.getCurrentBrowser
      $ie.title   
    end
    def attachWindow(value = nil)
      ie = Watir::IE.attach(:title, value)
      $browsers.addBrowser(ie)
      assign_ie
    end
    def swapWindow
      $browsers.nextBrowser
      assign_ie
    end
    def startClicker( button , waitTime = 0.5)
        w = WinClicker.new
        longName = $ie.dir.gsub("/" , "\\" )
        shortName = w.getShortFileName(longName)
        c = "start rubyw #{shortName }\\watir\\clickJSDialog.rb #{button } #{ waitTime} "
        puts "Starting #{c}"
        w.winsystem(c )   
        w=nil
    end
    def close
      title = $ie.title
      $browsers.closeCurrentBrowser
      sleep 2 
      title
    end   
    def goto(url) 
      $ie.goto(url)
    end
    def url 
      $ie.url 
    end
    def  title 
      $ie.title
    end
    def contains_text(text)
      $ie.contains_text(text) ? true : false
    end
    def subelement(type, identifier)
      element = nil 
      begin
        element =  $ie.send(type,:text, identifier)
      rescue
      end  
      if (element && element.exists?)
        return element
      end
      
      begin
        element = $ie.send(type,:id, identifier)
      rescue
      end  
      if (element && element.exists?)
        return element
      end    
      begin
        element =  $ie.send(type,:name, identifier)
      rescue
      end  
      if (element && element.exists?)
        return element
      end
      begin
        element =  $ie.send(type,:value, identifier)
      rescue
      end  
      return element
    end    
    def radios
      $ie.radios
    end
    def span(id)
      $ie.span(:id , id)
    end
    def element(element, identifier)
      Textbox.new(subelement(element, identifier))
    end 
  end
  
  class ElementMapper
    def resolve_name(name)
      if $element_map && $element_map[name]
        return $element_map[name].identifier
      end   
      return name  
    end
    def map(element)
      if !defined?  $element_map
        $element_map= Hash.new  
      end	
      
      $element_map[element.name]=element
    end 
    def get(name)
      $element_map[name]
    end 
    def clear
      $element_map= Hash.new
    end 
    
  end
  
  class MapperTest < Test::Unit::TestCase
    def test_Element_map
      com_one = Element.new('cb','cb1')
      com_two = Element.new('tf','tf1')
      map = ElementMapper.new
      map.map(com_one)
      map.map(com_two)
      assert_equal(com_one, map.get('cb'))
      assert_equal(com_two, map.get('tf'))
      assert_equal('cb1',map.get('cb').identifier)
      assert_equal('tf1', map.resolve_name('tf'))      
    end
  end
  
  class ElementTest < Test::Unit::TestCase 
    def test_element
      com = Element.new
      assert_not_nil(com)
      com.name = 'testName'
      assert_equal('testName', com.name)
      com.identifier='frmEmp:cbox'
      assert_equal('frmEmp:cbox', com.identifier)
      
      com.value='bob'
      assert_equal('bob', com.value)
      com = Element.new('name','id')
      assert_equal('name', com.name)
      assert_equal('id', com.identifier)
    end    
  end 
  
  class PageTest < Test::Unit::TestCase
    def test_page
      page =  Longboard.const_get("Page").new('name','id')
      assert_not_nil(page)
      assert_equal('name', page.name)
      assert_equal('id', page.identifier)
    end    
  end 
   
  
  class Element
    attr_accessor :name, :identifier, :value
    def initialize(name=nil, identifier=nil)
      @name = name
      @identifier = identifier.gsub('&EscapedAmp','&' ).gsub('&EscapedPipe','|' ).gsub(/^&/,'') if identifier
      @adapter = FitTypeAdapter.new
    end
    def string_contains(string, value)
      if string.index(value)
        return true
      end	
      return false	
    end
  end 
  
  class Page < Element
    def should_contain(browser=nil, value=nil)
      browser.contains_text(value)
    end
    def should_equal(browser=nil, value=nil)
      if browser.url.to_s == value.to_s
        return true
      end
      browser.url.to_s   
    end  
    def navigate_to(browser=nil, value=nil)
      browser.goto(@identifier)
    end
    
  end
  
  class Input < Element
    def should_contain(browser=nil, value=nil)
      string_contains(browser.subelement('text_field', @identifier).getContents, value)	
    end
    def should_equal(browser=nil, value=nil)
      @adapter.to_fit( browser.subelement('text_field', @identifier).getContents)      
    end  
    def set_value(browser=nil, value=nil)
      element = browser.subelement('text_field', @identifier)
      if element == nil
        return @identifier
      end
      element.set(@adapter.to_browser(value))
    end
  end
  
  class Label < Element
    def initialize(name=nil,identifier=nil,adapter=nil)
      super(name,identifier)
      if adapter
        @adapter = adapter
      end
    end
    
    def should_equal(browser=nil,value=nil)
      @adapter.to_fit(browser.subelement('label', @identifier).text)
    end  
  end
  
  class LabelTest < Test::Unit::TestCase
    def test_should_equal()
      adapter1 = MockAdapter.new('20060510')
      adapter2 = MockAdapter.new('1308')
      assert_not_nil()
      assert_equal(true, Label.new(nil,'anything',adapter1).should_equal(MockBrowser.new(nil,MockLabel.new('anything', '20060510'))))
      assert_equal(false, Label.new(nil,'anything',adapter2).should_equal(MockBrowser.new(nil,MockLabel.new('anything', '20060510'))))
      assert_equal(false, Label.new(nil,'anything',adapter1).should_equal(MockBrowser.new(nil,MockLabel.new('anything', '1253'))))
      assert_equal(true, Label.new(nil,'other',adapter2).should_equal(MockBrowser.new(nil,MockLabel.new('other', '1308'))))
    end
  end
  
  class MockLabel
    attr_accessor :name
    
    def initialize(id=nil,value=nil)
      @text = value
      @name = id
    end
    
    def text
      @text
    end
  end
  
  class MockAdapter
    def initialize(value=nil)
      @value = value
    end
    
    def to_fit(value)
      @value == value
    end
  end
  
  class CheckBox < Element
    def should_equal(browser=nil, value=nil)
      if browser.subelement('checkbox', @identifier).isSet? 
        return 'checked'
      end 
      return 'unchecked'
      
    end  
    def set_value(browser=nil, value=nil)
      box = browser.subelement('checkbox', @identifier)
      if value == 'checked'
        box.set   
        return true
      end
      if value == 'unchecked'
        box.clear   
        return true
      end	
      false
    end
  end
  
  class Radio < Element
    def should_equal(browser=nil, value=nil)
      radios = browser.radios
      for radio in radios
        if radio.name == @identifier && radio.isSet?
          return @adapter.to_fit(radio.value)
        end
      end
    end  
    def set_value(browser=nil, value=nil)
      radios = browser.radios
      for radio in radios
        if radio.name == @identifier && radio.value == value
          radio.set
        end
      end
    end
    
  end
  
  class DropDown < Element
    def should_contain(browser=nil, value=nil)
      element = browser.subelement('select_list', @identifier)
      options = element.getAllContents
      for option in options
        if option ==  value
          return true
        end
      end
      return false
    end
    def should_equal(browser=nil, value=nil)
      @adapter.to_fit(browser.subelement('select_list', @identifier).getSelectedItems.first)
    end  
    def set_value(browser=nil, value=nil)
      value = value.to_s
      browser.subelement('select_list', @identifier).select(value)
    end
  end
  
  class MultiSelect < Element
    def value_exists_in_list (value, items) 
      for item in items 
        if item.strip == value.strip
          return true
        end
      end
      false
    end
    def should_contain(browser=nil, value=nil)
      value_exists_in_list(value, browser.subelement('select_list', @identifier).getAllContents)
    end
    def should_be_selected(browser=nil, value=nil)
      value_exists_in_list(value, browser.subelement('select_list', @identifier).getSelectedItems)
    end  
    def set_value(browser=nil, value=nil)
      browser.subelement('select_list', @identifier).select(value.to_s)
    end
  end
  
  class Link < Element
    def should_contain(browser=nil, value=nil)
      string_contains(browser.subelement('link', @identifier).href, value)
    end
    def should_equal(browser=nil, value=nil)
      browser.subelement('link', @identifier).href
    end  
    def navigate_to(browser=nil, value=nil)
      browser.subelement('link', @identifier).click
      return @identifier
    end
    alias :click :navigate_to
  end
  
  class Button < Element
    def click(browser=nil, value=nil)
      browser.subelement('button', @identifier).click
    end
  end
  
  class Span < Element
    def should_contain(browser=nil, value=nil)
      string_contains(browser.span(@identifier).text, value)
    end
    def should_equal(browser=nil, value=nil)
      browser.span(@identifier).text
    end  
  end
  
  class Table < Element
  end
  
  class Row < Element
    def get_row_values(browser=nil)
      row_values = browser.subelement('table',@identifier[0]).row_values(@identifier[1])
      row_values.collect!{| value | value == '' ? 'blank' : value }
    end
    def should_contain(browser=nil, value=nil)
      row_values = get_row_values(browser)
      for item in value
          if !row_values.include?(@adapter.from_fit(item)) 
              return false
          end       
      end
      return true
    end
    def should_equal(browser=nil, value=nil)
        get_row_values(browser)
    end  
  end
  
  class AlertClicker < Element
    def set_value(browser=nil, value=nil)
      browser.startClicker(value)     
    end
  end
  
 class BrowserCollection
    def initialize() 
      @browsers = []
    end
    def addBrowser(newBrowser)
        @browsers << newBrowser
        @current = @browsers.size() - 1
    end
    def setCurrentByName(name)
        for index in 0..@browsers.size() - 1
          if name == @browsers[index].title 
            @current = index
            return getCurrentBrowser.title
          end
        end
        nil
    end
    def getCurrentBrowser
       @browsers[@current]
    end
    def nextBrowser()
      @current = (@current + 1) % @browsers.size()
    end
    def closeCurrentBrowser
      getCurrentBrowser().close
      @browsers.delete_at(@current)
      @current = 0
    end
 end
 
 class MockBrowser
    attr_accessor :title,:closed
    
    def initialize(title=nil,element=nil)
        @element = element
        @closed = false
        @title = title
    end
    
    def close
      @closed = true
    end
    
    def subelement(type=nil,id=nil)
      if type == 'Label' && id == @element.name
        @element
      end
    end
 end
 
 class BrowserCollectionTest < Test::Unit::TestCase 
      def setup
          @b1 = MockBrowser.new("window1")
          @b2 = MockBrowser.new("window2")
          @b3 = MockBrowser.new("windowA")
          @bc = BrowserCollection.new
      end
      
      def add_all_browsers
          @bc.addBrowser(@b1)
          @bc.addBrowser(@b2)
          @bc.addBrowser(@b3)
      end
      
      def test_close_browser
        add_all_browsers
        @bc.setCurrentByName("windowA")
        @bc.closeCurrentBrowser
        assert_equal(true, @b3.closed)
        assert_equal(@b1, @bc.getCurrentBrowser)
        @bc.closeCurrentBrowser
        assert_equal(true, @b1.closed)
        assert_equal(@b2, @bc.getCurrentBrowser)
        @bc.closeCurrentBrowser
        assert_equal(true, @b2.closed)
        assert_equal(nil, @bc.getCurrentBrowser())
      end
      
      def test_attach_by_name
          add_all_browsers
          assert_equal("window2", @bc.setCurrentByName("window2"))
          assert_equal(@b2, @bc.getCurrentBrowser)
          assert_equal("windowA", @bc.setCurrentByName("windowA"))
          assert_equal(@b3, @bc.getCurrentBrowser)
          assert_equal(nil, @bc.setCurrentByName("not_there"))
          assert_equal(@b3, @bc.getCurrentBrowser)
      end
      
      def test_multiple_browsers
          assert_not_nil(@b1)
          @bc.addBrowser(@b1)
          assert_equal(@b1, @bc.getCurrentBrowser)
          @bc.addBrowser(@b2)
          assert_equal(@b2, @bc.getCurrentBrowser)
          @bc.nextBrowser()
          assert_equal(@b1, @bc.getCurrentBrowser)
          @bc.addBrowser(@b3)
          assert_equal(@b3, @bc.getCurrentBrowser)
          @bc.nextBrowser()
          assert_equal(@b1, @bc.getCurrentBrowser)
          @bc.nextBrowser()
          assert_equal(@b2, @bc.getCurrentBrowser)
          @bc.nextBrowser()
          assert_equal(@b3, @bc.getCurrentBrowser)
      end
      
      def test_single_browser_switching
        @bc.addBrowser(@b1)
        assert_equal(@b1, @bc.getCurrentBrowser)
        @bc.nextBrowser
        assert_equal(@b1, @bc.getCurrentBrowser)
      end
 end
 
 
end


