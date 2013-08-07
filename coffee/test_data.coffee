window.TEST_DATA = [
  {
    label: 'Layer 1'
    values: [
      { x: 0, y: 0 },
      { x: 1, y: 100 },
      { x: 2, y: 400 },
      { x: 3, y: 900 },
      { x: 4, y: 1100 },
      { x: 5, y: 2500 }
    ]
  },
  {
    label: 'Layer 2'
    values: [
      { x: 0, y: 340 },
      { x: 1, y: 10 },
      { x: 2, y: 1400 },
      { x: 3, y: 80 },
      { x: 4, y: 100 },
      { x: 5, y: 20 }
    ]
  },
  {
    label: 'Layer 3'
    values: [
      { x: 0, y: 940 },
      { x: 1, y: 1233 },
      { x: 2, y: 200 },
      { x: 3, y: 1976 },
      { x: 4, y: 1560 },
      { x: 5, y: 800 }
    ]
  }
]

window.TEST_DATA_2 = [
  {
    label: 'Layer 1'
    values: [
      { x: 0, y: 1200 },
      { x: 1, y: 0 },
      { x: 2, y: 300 },
      { x: 3, y: 170 },
      { x: 4, y: 1220 },
      { x: 5, y: 40 },
      { x: 6, y: 230}
    ]
  },
  {
    label: 'Layer 2'
    values: [
      { x: 0, y: 3400 },
      { x: 1, y: 523 },
      { x: 2, y: 190 },
      { x: 3, y: 803 },
      { x: 4, y: 1030 },
      { x: 5, y: 2042 },
      { x: 6, y: 820}
    ]
  }
]

window.TEST_DATA_3 = [
  {
    label: 'Layer 1'
    values: [
      { x: 0, y: 100 },
      { x: 1, y: 200 },
      { x: 2, y: 300 },
      { x: 3, y: 400 },
      { x: 4, y: 500 },
      { x: 5, y: 600 }
    ]
  },
  {
    label: 'Layer 2'
    values: [
      { x: 0, y: 600 },
      { x: 1, y: 500 },
      { x: 2, y: 400 },
      { x: 3, y: 300 },
      { x: 4, y: 200 },
      { x: 5, y: 100 }
    ]
  }
]

window.BAR_DATA = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 30 },
      { x: 'B', y: 10 },
      { x: 'C', y: 12 },
      { x: 'D', y: 32 },
      { x: 'E', y: 11 },
      { x: 'F', y: 25 }
    ]
  },
  {
    label: 'Beta'
    values: [
      { x: 'A', y: 34 },
      { x: 'B', y: 18 },
      { x: 'C', y: 14 },
      { x: 'D', y: 30 },
      { x: 'E', y: 19 },
      { x: 'F', y: 20 }
    ]
  },
  {
    label: 'Gamma'
    values: [
      { x: 'A', y: 13 },
      { x: 'B', y: 12 },
      { x: 'C', y: 20 },
      { x: 'D', y: 19 },
      { x: 'E', y: 15 },
      { x: 'F', y: 22 }
    ]
  }
]

window.BAR_DATA_2 = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 10 },
      { x: 'B', y: 19 },
      { x: 'C', y: 22 },
      { x: 'D', y: 18 },
      { x: 'E', y: 5 },
      { x: 'F', y: 16 },
      { x: 'G', y: 7 }
    ]
  },
  {
    label: 'Beta'
    values: [
      { x: 'A', y: 4 },
      { x: 'B', y: 10 },
      { x: 'C', y: 19 },
      { x: 'D', y: 33 },
      { x: 'E', y: 7 },
      { x: 'F', y: 16 },
      { x: 'G', y: 14 }
    ]
  }
]

window.BAR_DATA_SINGLE = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 30 },
      { x: 'B', y: 10 },
      { x: 'C', y: 12 },
      { x: 'D', y: 32 },
      { x: 'E', y: 11 },
      { x: 'F', y: 25 }
    ]
  }
]

window.BAR_DATA_SINGLE_2 = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 10 },
      { x: 'B', y: 40 },
      { x: 'C', y: 42 },
      { x: 'D', y: 12 },
      { x: 'E', y: 5 },
      { x: 'F', y: 17 }
    ]
  }
]

window.PIE_DATA = [
  { label: 'Alpha', value: 10 },
  { label: 'Beta', value: 20 },
  { label: 'Gamma', value: 40 },
  { label: 'Tau', value: 30 }
]

window.PIE_DATA_2 = [
  { label: 'Alpha', value: 15 },
  { label: 'Beta', value: 35 },
  { label: 'Gamma', value: 27 },
  { label: 'Tau', value: 23 }
]

CATEGORIES = ['Series A', 'Series B', 'Series C']
window.SCATTER_DATA = []
window.SCATTER_DATA_2 = []

for name in CATEGORIES
  SCATTER_DATA.push(layer = { label: name, values: [] })
  SCATTER_DATA_2.push(layer2 = { label: name, values: [] })
  for i in [1..20]
    layer.values.push { x: Math.random() * 1000, y: Math.random() * 1000 }
    layer2.values.push { x: Math.random() * 1000, y: Math.random() * 1000 }




startDate = new Date("Mon Jul 04 2013 4:30:00 GMT-0700 (PDT)")
elapsed = 0

nextTime = ->
  elapsed++
  d = new Date(startDate.toString())
  d.setSeconds d.getSeconds() + elapsed
  (d.getTime()/1000)|0

window.nextTimeEntry = ->
  t = nextTime()
  [
    { time: t, y: (Math.random() * 1000) + 1 },
    { time: t, y: (Math.random() * 1000) + 1 },
    { time: t, y: (Math.random() * 1000) + 1 }
  ]

window.TIME_DATA = [
  { label: 'Alpha', values: [] },
  { label: 'Beta', values: [] },
  { label: 'Gamma', values: [] }
]

window.TIME_DATA_2 = [
  { label: 'Alpha', values: [] },
  { label: 'Beta', values: [] }
]

window.TIME_DATA_SHORT = [
  { label: 'Alpha', values: [] },
  { label: 'Beta', values: [] },
  { label: 'Gamma', values: [] }
]

window.TIME_DATA_SHORT_2 = [
  { label: 'Alpha', values: [] },
  { label: 'Beta', values: [] },
  { label: 'Gamma', values: [] }
]

for i in [0...45]
  time = nextTime()
  for layer in TIME_DATA
    layer.values.push { time: time, y: (Math.random() * 1000) + 1 }
  for layer in TIME_DATA_2
    layer.values.push { time: time, y: (Math.random() * 1000) + 1 }

for i in [0...10]
  time = nextTime()
  for layer in TIME_DATA_SHORT
    layer.values.push { time: time, y: (Math.random() * 1000) + 1 }

for i in [0...35]
  time = nextTime()
  for layer in TIME_DATA_SHORT_2
    layer.values.push { time: time, y: (Math.random() * 1000) + 1 }

#
# Heatmap entries
#

hist_elapsed = 0

hist_nextTime = ->
  hist_elapsed++
  d = new Date(startDate.toString())
  d.setSeconds d.getSeconds() + elapsed
  (d.getTime()/1000)|0

window.HIST_DATA = [
  { label: 'Alpha', values: [] },
]

window.nextHistEntry = (hist_range=[0,100], time) ->
  time = hist_nextTime() unless time?
  entry = { time: time, histogram: {} }

  [a, b] = hist_range
  for k in [0...1500]
    r = ((Math.random() * (b-a))|0) + a
    entry.histogram[r] ?= 0
    entry.histogram[r]++
  return entry

window.nextHeatmapEntry = ->
  time = hist_nextTime()
  rv = []
  for layer in HIST_DATA
    rv.push nextHistEntry([0,100], time)
  return rv

for i in [0...30]
  entry = nextHeatmapEntry()
  for i in [0...entry.length]
    HIST_DATA[i].values.push entry[i]


# For multi-layer histograms
window.HIST_DATA_2 = [
  { label: 'Alpha', values: [] },
  { label: 'Beta', values: [] },
  { label: 'Gamma', values: [] }
]

hist_dist = [
  [0, 60],
  [30, 70],
  [40, 100]
]

window.nextMultiLayerHeatmapEntry = ->
  time = hist_nextTime()
  rv = []
  for i, layer of HIST_DATA_2
    rv.push nextHistEntry(hist_dist[i], time)
  return rv

for i in [0..120]
  entry = nextMultiLayerHeatmapEntry()
  for k in [0...entry.length]
    HIST_DATA_2[k].values.push entry[k]



console.log HIST_DATA_2




