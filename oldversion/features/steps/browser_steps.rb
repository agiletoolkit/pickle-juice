require 'spec' # so we can call .should
require 'celerity'
require 'rexml/document'
require 'rexml/xpath'
include REXML
import 'com.gargoylesoftware.htmlunit.WebAssert'
import 'com.gargoylesoftware.htmlunit.DefaultCredentialsProvider'
import 'java.security.Security'
import 'java.lang.System'

module Celerity
  class Browser
    def execute_script(source)
      assert_exists
      script_result = @page.executeJavaScript(source.to_s)
      @page = script_result.getNewPage() || @page
      script_result.getJavaScriptResult
    end
    
    def click_element_by_id(id)
		@page = @page.getHtmlElementById(id).click
		pause_for_javascript
	end
    
    def pause_for_javascript()
    	begin
         webclient.waitForJobsWithinDelayToFinish(1000)
      rescue
      end
    end
    
  end # Browser
end # Celerity


Given /a browser for (.*)/ do |hostname|
	start_browser(hostname)
end

Given /a browser$/ do ||
	start_browser("")
end


## Navigation

When /^navigating back$/ do
  @browser.back
end

Given /navigating to (.*)/ do |url|
	@browser.goto(@hostname + url)
end

Given /basic authentication is set to (.*) with password (.*)/ do |username, password|
	credentials = DefaultCredentialsProvider.new()
	credentials.addCredentials(username, password)
	@browser.webclient.setCredentialsProvider(credentials)
end 


## Generic Element 

When /entering (.*) in (.*) with (.*) of (.*)/ do |value,element,locator,location|
	locate(element,locator,location).set(value)
end

When /clicking the (.*) with (.*) of (.*)/ do |element,locator,location|
	locate(element,locator,location).click
	@browser.pause_for_javascript()
end

When /clicking element with id of (.*)/ do |id|
	@browser.click_element_by_id(id)
end

When /clicking element with xpath of (.*)/ do |xpath|
	#p @browser.element_by_xpath(xpath).absolute_url
	@browser.element_by_xpath(xpath).click
	@browser.pause_for_javascript()
end

When /performing the page onload action/ do
	# Browser.element_by_xpath() is documented, but not implemented
	# action = @browser.element_by_xpath("/html/body/@onload")
	# this hack is the workaround:
	@browser.execute_script("submit_form_page()")
end

When /sleeping for (.*) second/ do |seconds|
	sleep seconds.to_f
end 

When /clicking the (.*) containing (.*) of (.*)/ do |element,locator,location|
	locate(element,locator,/#{location}/).click
end

When /navigating with the url of the (.*) with (.*) of (.*)/ do |element,locator,location|
  	@browser.goto(@hostname + '/' + locate(element,locator,location).href.strip)
end

When /navigating with the url of element with xpath of (.*)/ do |xpath|
	@browser.goto(@browser.element_by_xpath(xpath).absolute_url)
end

When /^selecting (.*) in select_list with (.*) of (.*)$/ do |text,locator,location|
	locate("select_list", locator, location).select(/#{text}/)
end

Then /browser has the title (.*)/ do |title|
  fail unless @browser.title.include?(title)
end

Then /page does not have the text (.*)/  do |text|
	fail if @browser.contains_text(text)
end

Then /page has the text (.*)/  do |text|
	#fail unless @browser.text.include?(text)
	fail unless @browser.contains_text(text)
end

Then /page has a (.*) with (.*) of (.*)/ do |element,locator,location|
	fail unless locate(element,locator,location).exists?
end


Then /(.*) with (.*) of (.*) should be blank/ do |element,locator,location|
  begin
	fail unless locate(element,locator,location).verify_contains("")
  rescue
	fail unless locate(element,locator,location).value.strip.should == ""
  end
end


Then /(.*) with (.*) of (.*) should not be blank/ do |element,locator,location|

    fail if locate(element,locator,location).text.strip == ""
end

Then /(.*) with (.*) of (.*) should equal (.*)/ do |element,locator,location,value|
  elem = locate(element,locator,location)
  fail unless text_or_value(elem).should == value
end

Then /(.*) with (.*) of (.*) should contain (.*)/ do |element,locator,location,text|
  begin
    fail unless locate(element,locator,location).verify_contains(/#{text}/)
  rescue
    fail unless locate(element,locator,location).text.include?(text)
  end    
end

Then /^(.*) containing text of (.*) should also contain (.*)$/ do |element,first_text, second_text|
	When "storing #{element} containing text of #{first_text} as _a_temporary_variable_"
	Then "variable _a_temporary_variable_ should contain #{second_text}"
end

## Variable

When /^storing (.*) with (.*) of (.*) as (.*)$/ do |element,locator,location,variable|
  @variables[variable] = text_or_value(locate(element,locator,location))
end

When /^storing (.*) containing (.*) of (.*) as (.*)$/ do |element,locator,location,variable|
  @variables[variable] = text_or_value(locate(element,locator,/#{location}/))
end

Then /^variable (.*) should contain (.*)$/ do |variable,text|
	fail unless @variables[variable].include?(text)
end

Then /^variable (.*) should be equal to (.*)$/ do |variable,text|
  fail unless @variables[variable] == text
end

Then /^variable (.*) element (.*) should equal (.*)$/ do |variable,xpath,text|
	fail unless XPath.first(Document.new(@variables[variable]), xpath).text.should == text
end

Then /page has the value in variable (.*) element (.*)/  do |variable,xpath|
	fail unless @browser.text.include?(XPath.first(Document.new(@variables[variable]), xpath).text)
end

Then /^page has all the values in variable (.*) element (.*)$/ do |variable,xpath|
	XPath.each(Document.new(@variables[variable]), xpath) do |element_content|
	    fail unless @browser.text.include?(element_content.text)
	end
end

Then /^variable (.*) count of elements (.*) should equal ([0-9]*)$/ do |variable,xpath,count|
	fail unless XPath.match(Document.new(@variables[variable]), xpath).size.should == count.to_i
end

Then /page text contains value in variable (.*)/  do |variable|
  fail unless @browser.text.include?(@variables[variable])
end

Then /page text does not contain value in variable (.*)/  do |variable|
  fail if @browser.text.include?(@variables[variable])
end


## Checkbox and Radio

Then /^(.*) with (.*) of (.*) should not be checked$/ do |element,locator, location|
  fail if locate(element, locator, location).isSet?
end

Then /^(.*) with (.*) of (.*) should be checked$/ do |element,locator, location|
  fail unless locate("checkbox", locator, location).isSet?
end

When /^unchecking the (.*) with (.*) of (.*)$/ do |element,locator, location|
  locate("checkbox", locator, location).clear
end

When /^checking the (.*) with (.*) of (.*)$/ do |element,locator, location|
  locate("checkbox", locator, location).set
end


## Select List

Then /(.*) with (.*) of (.*) should not have value (.*) selected/ do |element,locator,location,value|
  fail if locate(element,locator,location).selected?(value)
end

Then /(.*) with (.*) of (.*) should not have option (.*) selected/ do |element,locator,location,value|
  fail if locate(element,locator,location).value == value
end

Then /(.*) with (.*) of (.*) should have value (.*) selected/ do |element,locator,location,value|
  fail unless locate(element,locator,location).selected?(value)
end

Then /(.*) with (.*) of (.*) should have option (.*) selected/ do |element,locator,location,value|
  fail unless locate(element,locator,location).value == value
end

Then /^(.*) with (.*) of (.*) should not have anything selected$/ do |element,locator,location|
  fail unless locate(element,locator,location).selected_options.size
end


Then /select_list with (.*) of (.*) has values/ do |locator,location,table|
  select = locate("select_list",locator,location)
	options = select.options
	table.hashes.each do |hash|  
			fail unless options.include?(hash["value"])
	end
end

Then /select_list with (.*) of (.*) has options/ do |locator,location,table|
	select = locate("select_list",locator,location)
	table.hashes.each do |hash|  
		option = hash["option"]
		select.select(/#{option}/)     
		fail unless select.value == hash["value"]
	end
end


## Display

Then /^display variable (.*) count of elements (.*) as (.*)$/ do |variable,xpath,label|
	puts label + ": " + XPath.match(Document.new(@variables[variable]), xpath).size.to_s
end

Then /^display variable (.*) element (.*) as (.*)$/ do |variable,xpath,label|
	puts label + ": " + XPath.first(Document.new(@variables[variable]), xpath).to_s
end

Then /^display page element (.*) as (.*)$/ do |xpath,label|
	puts label + ": " + XPath.first(Document.new(@browser.xml), xpath).to_s
end



def start_browser(hostname)
	@browser = Celerity::Browser.new(:browser => :firefox, :resynchronize => true, :status_code_exceptions => false)
	@browser.webclient.setUseInsecureSSL(true)
	@hostname = hostname
	@variables = {}
end

def locate (element,locator,location) 
	@browser.send(element.to_sym, locator.to_sym, location)
end

def text_or_value(elem)
   elem.respond_to?(:readonly?) ? elem.value.strip : elem.text.strip
end
