describe 'Epoch.Events', ->
  eventsObject = null

  before (done) ->
    eventsObject = new Epoch.Events()
    done()

  it 'should execute callbacks when events are triggered', (done) ->
    errorCallback = ->
      assert false, 'Event callback never executed'
      done()
    timeout = setTimeout errorCallback, 1000
    eventsObject.on 'event', ->
      clearTimeout(timeout)
      done()
    eventsObject.trigger 'event'

  it 'should not execute callbacks that have been removed', (done) ->
    errorCallback = ->
      assert false, 'Event callback still executed'
      done()
    eventsObject.on 'example', errorCallback
    eventsObject.off 'example', errorCallback
    eventsObject.trigger 'example'
    done()

  it 'should execute all callbacks associated with an event name', (done) ->
    total = 4

    errorCallback = ->
      assert false, 'Not all callbacks were executed'
      done()
    timeout = setTimeout errorCallback, 1000

    makeCallback = -> ->
      total--
      if total == 0
        clearTimeout(timeout)
        done()
    eventsObject.on('multi', makeCallback()) for i in [0...total]
    eventsObject.trigger 'multi'

  it 'should remove all callbacks when using .off([String])', (done) ->
    makeCallback = -> ->
      assert false, "A callback was still executed"
      done()
    eventsObject.on('multi2', makeCallback()) for i in [0...4]
    eventsObject.off('multi2')
    eventsObject.trigger('multi2')
    setTimeout (-> done()), 200

  it 'should execute methods on the object when using .on([String], [String])', (done) ->
    errorCallback = ->
      assert false, 'Trigger did not call the appropriate method.'
      done()
    timeout = setTimeout(errorCallback, 1000)

    eventsObject.method = ->
      clearTimeout(timeout)
      done()

    eventsObject.on 'method-event', 'method'
    eventsObject.trigger 'method-event'

  it 'should register all events when executing .onAll([Object])', (done) ->
    errorCallback = ->
      assert false, 'Not all events were triggered.'
      done()
    timeout = setTimeout(errorCallback, 1000)

    eventNames = ['multi:a', 'multi:b', 'multi:c', 'multi:d']
    total = 0

    eventCallback = ->
      total += 1
      if total == eventNames.length
        clearTimeout(timeout)
        done()

    eventMap = {}
    eventMap[name] = eventCallback for name in eventNames

    eventsObject.onAll(eventMap)
    eventsObject.trigger(name) for name in eventNames


  it 'should remove all events when executing .offAll([Array])', ->
    eventCallback = ->
      assert false, 'A removed callback was still triggered.'

    eventNames = ['multi-off:a', 'multi-off:b', 'multi-off:c', 'multi-off:d']
    eventMap = {}
    eventMap[name] = eventCallback for name in eventNames

    eventsObject.onAll(eventMap)
    eventsObject.offAll(eventNames)
    eventsObject.trigger(name) for name in eventNames


  it 'should remove specific event callbacks when executing .offAll([Object])', (done) ->
    makeEventCallback = -> ->
      assert false, 'A removed callback was still triggered.'

    eventNames = ['multi-off:a', 'multi-off:b', 'multi-off:c', 'multi-off:d']
    eventMap = {}
    eventMap[name] = makeEventCallback() for name in eventNames

    eventsObject.onAll(eventMap)
    eventsObject.offAll(eventMap)
    eventsObject.trigger(name) for name in eventNames
    setTimeout (-> done()), 200
