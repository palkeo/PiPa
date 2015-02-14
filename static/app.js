// Generated by LiveScript 1.3.1
(function(){
  define(['jquery', 'react', 'prelude-ls', 'backbone', 'moment', 'dboard', 'widget'], function($, React, Prelude, Backbone, moment, dboard, widget){
    var ref$, map, filter, slice, lines, any, fold, Str, i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, thead, tbody, label, nav, p, ruby, rt, DEBUG, defineDashboards, app;
    ref$ = require('prelude-ls'), map = ref$.map, filter = ref$.filter, slice = ref$.slice, lines = ref$.lines, any = ref$.any, fold = ref$.fold, Str = ref$.Str;
    ref$ = React.DOM, i = ref$.i, div = ref$.div, tr = ref$.tr, td = ref$.td, span = ref$.span, kbd = ref$.kbd, button = ref$.button, ul = ref$.ul, li = ref$.li, a = ref$.a, h1 = ref$.h1, h2 = ref$.h2, h3 = ref$.h3, input = ref$.input, form = ref$.form, table = ref$.table, th = ref$.th, tr = ref$.tr, td = ref$.td, thead = ref$.thead, tbody = ref$.tbody, label = ref$.label, nav = ref$.nav, p = ref$.p, ruby = ref$.ruby, rt = ref$.rt;
    DEBUG = true;
    moment.locale("fr");
    defineDashboards = function(sources, dashboards){
      var MainDashboard, SecondDashboard;
      console.log("Create dashboards !");
      MainDashboard = React.createClass({
        mixins: [dboard.AbstractGridDashboard],
        render: function(){
          return div({
            className: 'gridster'
          }, ul({
            ref: 'maingrid'
          }, li({
            'data-row': 1,
            'data-col': 1,
            'data-sizex': 3,
            'data-sizey': 1
          }, div({
            className: 'ui segment grid swidget'
          }, div({
            className: 'ui ten wide column'
          }, widget.TimeDate({})), div({
            className: 'ui six wide column'
          }, widget.WeekNum({})))), li({
            'data-row': 1,
            'data-col': 4,
            'data-sizex': 1,
            'data-sizey': 1
          }, widget.TextGauge({
            model: sources.get('count'),
            label: "count"
          })), li({
            'data-row': 1,
            'data-col': 5,
            'data-sizex': 1,
            'data-sizey': 1
          }, widget.TextGauge({
            model: sources.get('extTemp'),
            label: span({
              className: 'ui small header'
            }, "Temp. ext.")
          })), li({
            'data-row': 1,
            'data-col': 6,
            'data-sizex': 1,
            'data-sizey': 1
          }, widget.TextGauge({
            model: sources.get('extHum'),
            label: span({
              className: 'ui small header'
            }, "Hum. ext.")
          })), li({
            'data-row': 1,
            'data-col': 7,
            'data-sizex': 1,
            'data-sizey': 1
          }, widget.TextGauge({
            model: sources.get('grangeTemp'),
            label: span({
              className: 'ui small header'
            }, "Temp. grange")
          })), li({
            'data-row': 1,
            'data-col': 8,
            'data-sizex': 1,
            'data-sizey': 1
          }, widget.TextGauge({
            model: sources.get('cpu'),
            icon: "dashboard"
          })), li({
            'data-row': 2,
            'data-col': 1,
            'data-sizex': 2,
            'data-sizey': 2
          }, widget.CircleGauge({
            model: sources.get('cpu'),
            min: 0,
            max: 100
          })), li({
            'data-row': 2,
            'data-col': 1,
            'data-sizex': 2,
            'data-sizey': 2
          }, widget.CircleGauge({
            model: sources.get('consoPc'),
            format_value: function(tval){
              return tval.toFixed(1);
            },
            min: 0,
            max: 300
          }))));
        }
      });
      SecondDashboard = React.createClass({
        mixins: [dboard.AbstractGridDashboard],
        render: function(){
          return div({
            className: 'gridster'
          }, ul({
            ref: 'maingrid'
          }, li({
            'data-row': 1,
            'data-col': 4,
            'data-sizex': 3,
            'data-sizey': 1
          }, div({
            className: 'ui segment grid swidget'
          }, div({
            className: 'ui ten wide column'
          }, widget.TimeDate({})), div({
            className: 'ui six wide column'
          }, widget.WeekNum({})))), li({
            'data-row': 1,
            'data-col': 1,
            'data-sizex': 3,
            'data-sizey': 3
          }, widget.CircleGauge({
            model: sources.get('consoPc'),
            icon: "dashboard",
            min: 0,
            max: 300
          }))));
        }
      });
      dashboards["main"] = MainDashboard({});
      dashboards["second"] = SecondDashboard({});
      return 'main';
    };
    app = React.createElement(dboard.DBoardApp, {
      dboardBuilder: defineDashboards,
      debug: DEBUG
    });
    if (DEBUG) {
      window.app = app;
    }
    return app;
  });
}).call(this);
