define do
  [ \jquery \react 'prelude-ls' \backbone \io \moment \d3]
  ($, React, Prelude, Backbone, io, moment, d3) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt, svg, g, path, rect, text} = React.DOM

    widget = {}
    window.React = React


    widget.CircleGauge = React.create-class do
      getDefaultProps: ->
        min: 0
        max: 1
        delta: Math.PI/7.5    # angle en plus de horizontal

      componentWillMount: ->
        @angle = d3.scale.linear!
          .domain [@props.min, @props.max] 
          .range [- @props.delta - Math.PI/2, @props.delta + Math.PI/2]
        @props.model.on \change, @modelChanged.bind @

      componentWillUnmount: ->
        @props.model.off \change, @modelChanged.bind @

      modelChanged: !->
        @renderSvg!

      render: ->
        div {className: 'ui center aligned segment swidget'},
          svg {ref: "gauge"},
            g {},
              text {ref: "gaugeText"}
              path {ref: "gaugeBackground"}
              path {ref: "gaugeItSelf"}

      renderSvg: ->
        parent = ($ @getDOMNode!).parent!
        w = parent.width!
        h = parent.height!
        rOut = 0.8 * Math.min w, h / 2
        rIn = 0.6 * rOut
        console.log w, h

        svgg = d3.select @refs.gauge.getDOMNode!
            .attr "width", w
            .attr "height", h
            .select "g"
            .attr "transform", "translate(" + (w / 2) + "," + (h / 2) + ")"

        text_value = @props.model.get \value
        console.log text_value
        if @props.format_value
          text_value = @props.format_value text_value
        d3.select @refs.gaugeText.getDOMNode!
            .text (text_value) + " " + (@props.model.get \unit)
            .attr "transform", "translate(" + 0 + "," + (h / 4) + ")"
            .attr "text-anchor", "middle"
            .attr "alignment-baseline", "middle"
            .classed("gauge_text", true)

        bgArc = d3.svg.arc!
          .innerRadius rIn
          .outerRadius rOut
          .startAngle @angle @props.min
          .endAngle @angle @props.max

        d3.select @refs.gaugeBackground.getDOMNode!
          .classed("gauge_bg", true)
          .attr "d", bgArc

        fgArc = d3.svg.arc!
          .innerRadius rIn-0.3
          .outerRadius rOut+0.3
          .startAngle @angle @props.min
          .endAngle Math.min (@angle (@props.model.get \value)), (@angle @props.max)

        d3.select @refs.gaugeItSelf.getDOMNode!
          .classed("gauge_fg", true)
          .attr "d", fgArc
        @

      componentDidMount: ->
        @renderSvg!



    widget.MinimalPlot = React.create-class do
      getDefaultProps: ->
        min: 0
        max: 1
        delta: Math.PI/7.5    # angle en plus de horizontal

      componentWillMount: ->
        @angle = d3.scale.linear!
          .domain [@props.min, @props.max] 
          .range [- @props.delta - Math.PI/2, @props.delta + Math.PI/2]
        @props.model.on \change, @modelChanged.bind @
        # the plot area (to compute plot path)
        @area = d3.svg.area()
          .interpolate("step-after") # bar plot
          #.interpolate("monotone");

      componentWillUnmount: ->
        @props.model.off \change, @modelChanged.bind @

      modelChanged: !->
        @renderSvg!

      render: ->
        div {className: 'ui center aligned segment swidget'},
          svg {ref: "plot"},
            g {},
              rect {ref: "background"}
              path {}

      renderSvg: ->
        parent = ($ @getDOMNode!).parent!
        w = parent.width!
        h = parent.height!
        rOut = 0.8 * Math.min w, h / 2
        rIn = 0.6 * rOut
        console.log w, h
        
        @x = d3.time.scale!
        @y = d3.scale.linear!

        svgg = d3.select @refs.plot.getDOMNode!
          .attr "width", w
          .attr "height", h
          .select "g"
          #.attr "transform", "translate(" + (w / 2) + "," + (h / 2) + ")"

        data = @props.model.get @props.plotAttr
        if data
          dmin = d3.min data, (d) -> d.date
          dmax = d3.max data, (d) -> d.date
          console.log "DATA"
          console.log dmin, dmax

          # update x and y scale range and domain

          @x.range [0, w]
            .domain [dmin, dmax]

          @y.range [h, 0]
            .domain [0, d3.max data, (d) -> d.value]

          # configure plot area
          @area.x ((d) -> @x d.date).bind @
            .y0 h
            .y1 ((d) -> @y d.value).bind @


          # plot the data area
          svgg.select "path"
            .datum data
            .attr "class", "area"
            .attr "d", @area

        @

      componentDidMount: ->
        @renderSvg!


    widget.TextGauge = React.create-class do
      componentWillMount: ->
        @props.model.on \change, @modelChanged

      componentWillUnmount: ->
        @props.model.off \change, @modelChanged

      modelChanged: !->
        @forceUpdate null

      render: ->
        varient = ""
        if @props.model.get \error
          varient = "error "
        segClass = "ui center aligned #varient segment swidget"
        div {className: segClass},
          div {className: "swidgetContent"},
            if @props.icon
              div {className: 'ui huge header'},
                i {className: 'huge icon ' + @props.icon}
            div {className: 'ui large header'},
              @props.model.get \value
              if @props.model.get \unit
                span {},
                  ' '
                  @props.model.get \unit
            if @props.label
              @props.label
          if @props.model.get \error
            div {className: 'floating ui red label'},
              @props.model.get \error


    widget.TimeDate = React.create-class do
      getInitialState: ->
        time: moment().format('HH:mm:ss')
        date: moment().format('dddd D MMMM')

      updateDate: ->
        @setState do
          time: moment().format('HH:mm:ss')
          date: moment().format('dddd D MMMM')
        clearTimeout(@timeout)
        @timeout = setTimeout @updateDate, 1000

      componentWillMount: ->
        @updateDate!

      componentWillUnmount: ->
        clearTimeout(@timeout)

      render: ->
        div {className: 'ui center aligned segment swidget'},
          div {className: 'ui huge header'},
            @state.time
          div {className: 'ui medium header'},
            @state.date


    widget.WeekNum = React.create-class do
      getInitialState: ->
        week: moment().format('W')

      updateDate: ->
        @setState do
          week: moment().format('W')
        clearTimeout(@timeout)
        @timeout = setTimeout @updateDate, 30*1000

      componentWillMount: ->
        @updateDate!

      componentWillUnmount: ->
        clearTimeout(@timeout)

      render: ->
        div {className: 'ui center aligned segment swidget'},
          div {className: 'ui medium header'},
            "semaine"
          div {className: 'ui huge header'},
            @state.week

    widget
