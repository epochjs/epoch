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
  { label: 'Alpha', values: [] }
]

window.nextHistEntry = (hist_range=[0,100], time) ->
  time = hist_nextTime() unless time?
  entry = { time: time, histogram: {} }
  for k in [0...1500]
    r = (Math.random() * hist_range[1])|0 + hist_range[0]
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
  HIST_DATA[0].values.push nextHistEntry()


# 
# Yay, recursion
#

original = {0: 16, 1: 11, 2: 10, 3: 17, 4: 17, 5: 15, 6: 11, 7: 22, 8: 8, 9: 18, 10: 8, 11: 18, 12: 20, 13: 17, 14: 22, 15: 11, 16: 9, 17: 11, 18: 9, 19: 17, 20: 14, 21: 14, 22: 15, 23: 18, 24: 14, 25: 12, 26: 8, 27: 18, 28: 18, 29: 14, 30: 18, 31: 8, 32: 17, 33: 15, 34: 23, 35: 9, 36: 25, 37: 14, 38: 15, 39: 13, 40: 17, 41: 24, 42: 20, 43: 13, 44: 13, 45: 20, 46: 17, 47: 19, 48: 20, 49: 18, 50: 13, 51: 17, 52: 16, 53: 16, 54: 18, 55: 19, 56: 21, 57: 12, 58: 14, 59: 22, 60: 8, 61: 16, 62: 11, 63: 8, 64: 12, 65: 8, 66: 14, 67: 25, 68: 17, 69: 5, 70: 15, 71: 22, 72: 17, 73: 11, 74: 9, 75: 15, 76: 13, 77: 17, 78: 19, 79: 11, 80: 18, 81: 11, 82: 19, 83: 9, 84: 13, 85: 16, 86: 16, 87: 13, 88: 9, 89: 17, 90: 16, 91: 13, 92: 13, 93: 16, 94: 18, 95: 14, 96: 14, 97: 21, 98: 14, 99: 9}
bucketed = {5: 17, 10: 18, 15: 22, 20: 17, 25: 14, 30: 14, 35: 23, 40: 13, 45: 13, 50: 18, 55: 18, 60: 22, 65: 12, 70: 5, 75: 9, 80: 11, 85: 13, 90: 17, 95: 18, 100: 9, 1.6666666666666667: 27, 3.3333333333333335: 27, 6.666666666666667: 26, 8.333333333333334: 30, 11.666666666666668: 26, 13.333333333333334: 37, 16.666666666666668: 20, 18.333333333333336: 20, 21.666666666666668: 28, 23.333333333333336: 33, 26.666666666666668: 20, 28.333333333333336: 36, 31.666666666666668: 26, 33.333333333333336: 32, 36.66666666666667: 34, 38.333333333333336: 29, 41.66666666666667: 41, 43.333333333333336: 33, 46.66666666666667: 37, 48.333333333333336: 39, 51.66666666666667: 30, 53.333333333333336: 32, 56.66666666666667: 40, 58.333333333333336: 26, 61.66666666666667: 24, 63.333333333333336: 19, 66.66666666666667: 22, 68.33333333333334: 42, 71.66666666666667: 37, 73.33333333333334: 28, 76.66666666666667: 28, 78.33333333333334: 36, 81.66666666666667: 29, 83.33333333333334: 28, 86.66666666666667: 32, 88.33333333333334: 22, 91.66666666666667: 29, 93.33333333333334: 29, 96.66666666666667: 28, 98.33333333333334: 35}


window.ORIGINAL = [{ name: 'layer1', values: [] }]
for k, v of original
  ORIGINAL[0].values.push { x: k, y: v }

window.BUCKETED = [{ name: 'layer1', values: [] }]
for k, v of bucketed
  BUCKETED[0].values.push { x: k, y: v }







