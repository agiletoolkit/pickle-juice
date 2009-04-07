Feature: Browser
  In order to do functional testing we need to have a DSL for story testing
  
  Scenario: Basic Navigation and text assertion
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has the text Cucumber Test Page
    When navigating to /open.html
    Then page has the text The Open Page
    When navigating to /form.html
    Then page has the text Cucumber Test Page
    When clicking the button with text of Go
    Then page has the text Open Page
    When navigating back
    Then page has the text Cucumber Test Page
  
  Scenario: New Window
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has the text Cucumber Test Page
    And clicking the link with text of New Window
    And page has the text The Open Page
  
  Scenario: links
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a link with text of New Window
    And page has a link with id of linkId
    And page has a link with xpath of //a[@id='linkId']
    And page has a link with name of linkName
    And page has a link with xpath of //a[@name='linkName']
    #And page has a link with title of linkTitle				DOESN'T WORK
    #And page has a link with xpath of //a[@title='linkTitle']	DOESN'T WORK
    #And page has a link with class of linkClass				DOESN'T WORK
    #And page has a link with xpath of //a[@class='linkClass']	DOESN'T WORK
    
  Scenario: clicking a link
    Given a browser for http://localhost:8000
    When navigating to /form.html
    And clicking the link with id of linkId
    Then page has the text The Open Page
    
  Scenario: clicking an element by id
    Given a browser for http://localhost:8000
    When navigating to /form.html
    And clicking element with id of linkId
    Then page has the text The Open Page
    
  Scenario: clicking an element by xpath
    Given a browser for http://localhost:8000
    When navigating to /form.html
    And clicking element with xpath of //a[@id='linkId']
    Then page has the text The Open Page
    
  Scenario: clicking an xpath
    Given a browser for http://localhost:8000
    When navigating to /form.html
    And clicking the link with xpath of //a[@id='linkId']
    Then page has the text The Open Page
    
  Scenario: navigating to a link URL
    Given a browser for http://localhost:8000
    When navigating to /form.html
  	And navigating with the url of the link with id of linkId
    Then page has the text The Open Page
      
  Scenario: Select list
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a select_list with name of selectName
    And page has a select_list with id of selectId
    
    When selecting ten in select_list with name of numberSelectName
    # select_list value is the displayed string
    Then select_list with id of numberSelectId should have value ten selected
    # select_list option is the parameter string
    Then select_list with id of numberSelectId should have option 10 selected
    And select_list with id of numberSelectId should not have value fifteen selected
    And select_list with id of numberSelectId should not have option 15 selected
    
    And select_list with id of multiSelectId should not have anything selected  
    When selecting Bob Martin in select_list with id of multiSelectId 
    And selecting Bob Payne in select_list with id of multiSelectId 
    Then select_list with id of multiSelectId should have value Bob Payne selected
    And select_list with id of multiSelectId should have value Bob Martin selected
    And select_list with id of multiSelectId should not have value AdminTest Andy selected
    And select_list with id of multiSelectId should not have option 3 selected
    
    Then select_list with id of multiSelectId has values
      |value|
      |AdminTest Andy|
      |Bob Payne|
      |Club Sunshine|
      |Bob Martin|
    Then select_list with id of selectId has values
      |value|
      ||
      |Empty Option|
      |First Option|
      |Second Option|

  Scenario: Text Field, Area, Hidden
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a text_field with name of textboxName
    And page has a text_field with id of textboxId
    And page has a text_field with xpath of //input[@id='textboxId']
     
    Then text_field with id of textboxId should be blank
    When entering Bob Payne in text_field with id of textboxId
    Then text_field with id of textboxId should equal Bob Payne
    And text_field with id of textboxId should contain Payne
    
    Then text_field with id of textAreaId should be blank
    When entering Bob Martin in text_field with id of textAreaId
    Then text_field with id of textAreaId should equal Bob Martin
    And text_field with id of textAreaId should contain Bob

    Then text_field with id of hiddenId should equal not visible
    
  Scenario: Radio
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a radio with name of radioName
    And page has a radio with id of radio2
    And page has a radio with xpath of //input[@id='radio1']
    Then radio with id of radio1 should not be checked
    And radio with id of radio2 should not be checked
    When checking the radio with id of radio1
    Then radio with id of radio1 should be checked
    And radio with id of radio2 should not be checked
    When checking the radio with id of radio2
    Then radio with id of radio1 should not be checked
    And radio with id of radio2 should be checked
    

  Scenario: Checkbox
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a checkbox with name of checkboxName
    And page has a checkbox with id of checkboxId
    And page has a checkbox with xpath of //input[@id='checkboxId']
    Then checkbox with id of checkboxId should not be checked
    When checking the checkbox with id of checkboxId
    Then checkbox with id of checkboxId should be checked
    When unchecking the checkbox with id of checkboxId
    Then checkbox with id of checkboxId should not be checked

  Scenario: Button 
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a button with name of buttonName
    And page has a button with id of buttonId
    And page has a button with text of Go
    And page has a button with xpath of //input[@id='buttonId']
    When clicking the button with text of Go
    Then page has the text The Open Page
    
  Scenario: Non input elements
    Given a browser for http://localhost:8000
    When navigating to /form.html
    Then page has a h1 with text of Header 1
    Then page has a h2 with text of Header 2
    Then page has a h3 with text of Header 3
    Then page has a span with id of spanId
    Then span with id of spanId should contain Span Contents
    And div with id of internalDiv should equal Internal DIV
    And div containing text of First Paragraph should also contain Second paragraph
    And cell containing text of Alert should also contain Popup
    And row containing text of Span: should also contain Span Contents

  Scenario: Store and retrieve variables
    Given a browser for http://localhost:8000
    When navigating to /form.html
    When storing text_field with id of hiddenId as hidden_value 
    Then variable hidden_value should contain visible
    Then variable hidden_value should be equal to not visible
	  When storing div containing text of First Paragraph as my_temporary_variable
	  Then variable my_temporary_variable should contain Second paragraph
 
   