###
# TouchSelector.
# @author remiel.
# @module TouchSelector
# @example TouchSelector
#
#   jsx:
#   <TouchSelector></TouchSelector>
#
# @param options {Object} the options
# @option extClass {String} add a class to the wrapper for style
#
###
React = require 'react'
utils = require './utils'

TouchSelector = React.createClass
    displayName: 'TouchSelector'
    propsType:
        tagName: React.PropTypes.string
        component: React.PropTypes.element
        active: React.PropTypes.number
        duration: React.PropTypes.number
        onChange: React.PropTypes.func

    getDefaultProps: () ->
        tagName: 'div'
        active: 0
        duration: 200
        onChange: (value) ->
            console.log value

    getInitialState: ->

        @dx = null
        @dy = null
        @translateY = null
        @newTranslateY = null
        @transformProperty = utils.getProperty 'Transform'
        @transitionProperty = utils.getProperty 'Transition'

        animated: yes
        active: @props.active

    componentDidMount: ->
        # console.log 'cdm'
        @initValue()
        els = @getEls()
        if @state.active
            @newTranslateY = -(+@state.active * @itemHeight)
            if utils.support.transform3d
                els.inner.style[@transformProperty] = 'translate3d(0,' + @newTranslateY + 'px' + ',0)'
            else
                els.inner.style[@transformProperty] = 'translate(0,' + @newTranslateY + 'px' + ')'


    componentWillUpdate: (nextProps, nextState) ->
        # console.log 'cwu'



    render: ->
        # console.log 'render'
        classes = "touch-select"
        style =
            outer:
                overflow: 'hidden'
            inner:
                overflow: 'hidden'
        Component = @props.component || @props.tagName
        <Component ref="outer" {...@props} className={classes} style={style.outer}>
            <div ref="inner" style={style.inner} onTouchStart={@handleTouchStart} onTouchEnd={@handleTouchEnd} onTouchCancel={@handleTouchEnd} onTouchMove={@handleTouchMove}>
                {
                    @props.data.map (item, i) =>
                        itemClassName = 'item'
                        itemClassName += ' active' if @state.active is i
                        <div ref="item" key={i} className={itemClassName}>{item.text}</div>
                }
            </div>
            <div className="background"></div>
        </Component>

    getEls: () ->
        outer: @refs.outer.getDOMNode()
        inner: @refs.inner.getDOMNode()
        item: @refs.item.getDOMNode()

    initValue: () ->
        els = @getEls()
        @outerHeight = els.outer.offsetHeight
        @itemHeight = els.item.offsetHeight
        @innerPadding = @outerHeight/2 - @itemHeight/2
        els.inner.style['padding'] = @innerPadding + 'px 0'
        @innerHeight = els.inner.offsetHeight
        @dragRadius = @innerHeight - @outerHeight
        @canceled = !(@dragRadius >= 0)

    getTouchPosition: (e) ->
        touch = e.touches[0]
        x: touch.pageX
        y: touch.pageY

    handleTouchStart: (e)->
        return 0 if e.touches.length isnt 1
        e.stopPropagation()
        e.preventDefault()
        return 0 if !@state.animated
        @setState
            animated: yes
            active: -1
        els = @getEls()
        @initValue()
        els.inner.style[@transitionProperty] = ''
        @xy = @getTouchPosition e
        @translateY = parseInt els.inner.style[@transformProperty].split(',')[1]
        @translateY = 0 if isNaN @translateY

        # @setState active: -1

    handleTouchEnd: (e)->
        e.stopPropagation()
        return 0 if !@state.animated

        if !@canceled
            els = @getEls()
            index = Math.round(@newTranslateY / @itemHeight)
            @newTranslateY = index * @itemHeight
            els.inner.style[@transitionProperty] = 'all ' + @props.duration + 'ms '
            @setState
                animated: no
                active: -index
            if utils.support.transform3d
                els.inner.style[@transformProperty] = 'translate3d(0,' + @newTranslateY + 'px' + ',0)'
            else
                els.inner.style[@transformProperty] = 'translate(0,' + @newTranslateY + 'px' + ')'
            @props.onChange @props.data[-index]

            @timer = setTimeout ()=>
                els.inner.style[@transitionProperty] = ''
                @setState
                    animated: yes
            , @props.duration


    handleTouchMove: (e)->
        return 0 if e.touches.length isnt 1
        e.stopPropagation()
        e.preventDefault()
        return 0 if !@state.animated
        els = @getEls()
        els.inner.style[@transitionProperty] = ''
        new_xy = @getTouchPosition e
        return 0 if !@xy
        @dx = new_xy.x - @xy.x
        @dy = new_xy.y - @xy.y


        if !@canceled
            @newTranslateY = @translateY + @dy
            @newTranslateY = 0 if @newTranslateY > 0
            @newTranslateY = -@dragRadius if @newTranslateY < -@dragRadius
            if utils.support.transform3d
                els.inner.style[@transformProperty] = 'translate3d(0,' + @newTranslateY + 'px' + ',0)'
            else
                els.inner.style[@transformProperty] = 'translate(0,' + @newTranslateY + 'px' + ')'
            # index = Math.round(@newTranslateY / @itemHeight)
            # @setState
            #     active: -index



module.exports = TouchSelector
