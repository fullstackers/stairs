util = require 'util'
EventEmitter = require('events').EventEmitter

describe 'lib', ->
  
  Given -> @lib = requireSubject 'lib', {
    './../package.json':
      version: 1
  }

  describe '.version', ->

    When -> @version = @lib.version
    Then -> expect(@version).toEqual 1

  describe '#', ->

    When -> @res = @lib()
    Then -> expect(@res instanceof @lib).toBe true
    And -> expect(@res instanceof EventEmitter).toBe true
    And -> expect(@res.title).toBe 'Untitled'

  describe '#(title:String="Extraction")', ->

    Given -> @title = 'Extraction'
    When -> @res = @lib @title
    Then -> expect(@res instanceof @lib).toBe true
    And -> expect(@res instanceof EventEmitter).toBe true
    And -> expect(@res.title).toBe @title

  describe '#(title:String="")', ->

    Given -> @title = ''
    When -> @res = @lib @title
    Then -> expect(@res instanceof @lib).toBe true
    And -> expect(@res instanceof EventEmitter).toBe true
    And -> expect(@res.title).toBe 'Untitled'

  describe '#(title:String=null)', ->

    Given -> @title = null
    When -> @res = @lib @title
    Then -> expect(@res.title).toBe 'Untitled'

  describe '#(title:Number=0)', ->

    Given -> @title = 0
    When -> @res = @lib @title
    Then -> expect(@res.title).toBe 'Untitled'


  describe 'prototype', ->

    Given -> @name = 'Stairs'
    Given -> @stairs = @lib @name
    Given -> spyOn(@stairs, 'run').andCallThrough()

    describe '#', ->

      When -> @res = @stairs()
      Then -> expect(@res).toBe @stairs
      And -> expect(@stairs.run).toHaveBeenCalledWith()

    describe '#(scope:Object)', ->

      Given -> @scope = {}
      When -> @res = @stairs @scope
      Then -> expect(@res).toEqual @stairs
      And -> expect(@stairs.run).toHaveBeenCalledWith @scope

    describe '#step(title:String,fn:Function)', ->
      
      Given -> @title = 'Step 1'
      Given -> @fn = ->
      Given -> @steps = []
      Given -> spyOn(@stairs,'steps').andReturn @steps
      When -> @res = @stairs.step @title, @fn
      Then -> expect(@fn.title).toBe @title
      And -> expect(@steps[0]).toBe @fn
    
    describe '#steps', ->

      When -> @res = @stairs.steps()
      Then -> expect(util.isArray(@res)).toBe true

    describe '#run', ->

      Given -> @a = (scope, next) -> scope.a = 1; next()
      Given -> @b = (scope, next) -> scope.b = 1; next()
      Given -> @c = (scope, next) -> scope.c = 2; next()
      Given -> @stairs.step 'a', @a
      Given -> @stairs.step 'b', @b
      Given -> @stairs.step 'c', @c
      Given -> @scope = {}
      When (done) -> @stairs.run @scope, done
      Then -> expect(@scope.a).toBe 1
      And -> expect(@scope.b).toBe 1
      And -> expect(@scope.c).toBe 2

    describe '#end', ->
      
      Given -> @a = (scope, next) -> scope.a = 1; next()
      Given -> @b = (scope, next) -> scope.b = 1; @end(); next()
      Given -> @c = (scope, next) -> scope.c = 2; next()
      Given -> @stairs.step 'a', @a
      Given -> @stairs.step 'b', @b
      Given -> @stairs.step 'c', @c
      Given -> @scope = {}
      When (done) -> @stairs.run @scope, done
      Then -> expect(@scope.a).toBe 1
      And -> expect(@scope.b).toBe 1
      And -> expect(@scope.c).toBe undefined

