describe 'Champ Tracker authentication', ->

  it 'show a login page', ->
    browser.get 'http://localhost:4000/#/loading'
    expect(element(By.className('login-title')).getText()).toEqual 'Log In to your Account'

    #element(By.model('yourName')).sendKeys 'Julie'
    #greeting = element(By.binding('yourName'))
    #expect(greeting.getText()).toEqual 'Hello Julie!'

#  describe 'todo list', ->
#    todoList = undefined
#    beforeEach ->
#      browser.get 'http://www.angularjs.org'
#      todoList = element.all(By.repeater('todo in todos'))
#
#    it 'should list todos', ->
#      expect(todoList.count()).toEqual 2
#      expect(todoList.get(1).getText()).toEqual 'build an angular app'
#
#    it 'should add a todo', ->
#      addTodo = element(By.model('todoText'))
#      addButton = element(By.css('[value="add"]'))
#      addTodo.sendKeys 'write a protractor test'
#      addButton.click()
#      expect(todoList.count()).toEqual 3
#      expect(todoList.get(2).getText()).toEqual 'write a protractor test'
