/*
 * Epoch - Landing Page Scripting
 */


(function() {
    if ($(window).width() < 1000) {
        $('#banner .container .row .col-md-6:first-child')
            .removeClass('col-md-6')
            .addClass('col-md-12')
        $('#banner .container .row .col-md-6:last-child').remove()
        $('#social').css('width', '80px')
    }
})();


(function() {
    /*
     * Normal distribution random histogram data generator.
     */
    var NormalData = function(layers) {
        this.layers = layers;
        this.timestamp = ((new Date()).getTime() / 1000)|0;
    };

    var normal = function() {
        var U = Math.random(),
            V = Math.random();
        return Math.sqrt(-2*Math.log(U)) * Math.cos(2*Math.PI*V);
    };

    NormalData.prototype.sample = function() {
        return parseInt(normal() * 12.5 + 50);
    }

    NormalData.prototype.rand = function() {
        var histogram = {};

        for (var i = 0; i < 1000; i ++) {
            var r = this.sample();
            if (!histogram[r]) {
                histogram[r] = 1;
            }
            else {
                histogram[r]++;
            }
        }

        return histogram;
    };

    NormalData.prototype.history = function(entries) {
        if (typeof(entries) != 'number' || !entries) {
            entries = 60;
        }

        var history = [];
        for (var k = 0; k < this.layers; k++) {
            history.push({ label: String.fromCharCode(65+k), values: [] });
        }

        for (var i = 0; i < entries; i++) {
            for (var j = 0; j < this.layers; j++) {
                history[j].values.push({time: this.timestamp, histogram: this.rand()});
            }
            this.timestamp++;
        }

        return history;
    };

    NormalData.prototype.next = function() {
        var entry = [];
        for (var i = 0; i < this.layers; i++) {
            entry.push({ time: this.timestamp, histogram: this.rand() });
        }
        this.timestamp++;
        return entry;
    }

    window.NormalData = NormalData;


    /*
     * Beta distribution histogram data generator.
     */
    var BetaData = function(alpha, beta, layers) {
        this.alpha = alpha;
        this.beta = beta;
        this.layers = layers;
        this.timestamp = ((new Date()).getTime() / 1000)|0;
    };

    BetaData.prototype = new NormalData();

    BetaData.prototype.sample = function() {
        var X = 0,
            Y = 0;

        for (var j = 1; j <= this.alpha; j++)
            X += -Math.log(1 - Math.random());

        for (var j = 1; j <= this.beta; j++)
            Y += -Math.log(1 - Math.random());

        return parseInt(100 * X / (X + Y));
    }

    window.BetaData = BetaData;
})();


// $(function() {
//     $('[data-plot-hover=true]').each(function(i, el) {
//         $(el).on('mouseenter', function(e) {
//             $('.plot-hover', el).fadeIn(125).css('z-index', 20000);
//         }).on('mouseleave', function(e) {
//             $('.plot-hover', el).fadeOut(75);
//         });
//     });
// });


$(function() {
    var lineData = [],
        areaData = [],
        barData = [],
        scatterData = [],
        layers = 5,
        length = 128;

    for (var j = 0; j < layers; j++) {
        var layer = { label: String.fromCharCode(65+j), values: [] };
        for (var i = 0; i <= length; i++) {
            var x = i * 2 * Math.PI / length;
            layer.values.push({x: x, y: (j+1)*Math.sin(x)});
        }
        lineData.push(layer);
    }

    for (var j = 0; j < layers; j++) {
        var layer = { label: String.fromCharCode(65+j), values: [] },
            barLayer = { label: String.fromCharCode(65+j), values: [] };
        for (var i = 0; i <= length; i++) {
            var x = i * Math.PI / length;
            layer.values.push({x: x, y: Math.sin(x)});
            barLayer.values.push({x: x, y: Math.sin(x)});
        }
        areaData.push(layer);
        barData.push(barLayer);
    }

    for (var j = 0; j < 3; j++) {
        var layer = { label: String.fromCharCode(65+j), values: [] };
        for (var i = 0; i < length/2; i++) {
            layer.values.push({x: Math.random(), y: Math.random()});
        }
        scatterData.push(layer);
    }

    $('#line.epoch').epoch({ type: 'line', data: lineData, axes: [] });
    $('#area.epoch').epoch({ type: 'area', data: areaData, axes: [] });
    $('#bar.epoch').epoch({ type: 'time.bar', data: barData, axes: [] });
    $('#pie.epoch').epoch({
        type: 'pie',
        data: [
            {label: 'A', value: 70},
            {label: 'B', value: 20},
            {label: 'C', value: 10}
        ],
        inner: 45
    })
    $('#scatter.epoch').epoch({
        type: 'scatter',
        axes: [],
        data: scatterData
    });

    var rtAreaData = [
            {label: 'A', values: []},
            {label: 'B', values: []},
            {label: 'C', values: []},
            {label: 'D', values: []}
        ],
        rtLineData = [
            {label: 'A', values: []},
            {label: 'B', values: []},
            {label: 'C', values: []},
            {label: 'D', values: []}
        ],
        length = 120,
        time = parseInt(new Date().getTime() / 1000);

    for (var i = 0; i < length; i++) {
        rtAreaData[0].values.push({time: time, y: Math.random() * 25 + 25})
        rtAreaData[1].values.push({time: time, y: Math.random() * 25 + 50})
        rtAreaData[2].values.push({time: time, y: Math.random() * 25 + 75})
        rtAreaData[3].values.push({time: time, y: Math.random() * 25 + 100})

        rtLineData[0].values.push({time: time, y: Math.random() * 25 + 25})
        rtLineData[1].values.push({time: time, y: Math.random() * 25 + 50})
        rtLineData[2].values.push({time: time, y: Math.random() * 25 + 75})
        rtLineData[3].values.push({time: time++, y: Math.random() * 25 + 100})        
    }

    var rtArea = $('#rt-area').epoch({
        type: 'time.area',
        data: rtAreaData,
        axes: [],
        windowSize: 40
    });

    var rtBar = $('#rt-bar').epoch({
        type: 'time.bar',
        data: rtAreaData,
        axes: [],
        windowSize: 40
    });

    var rtHeatmapData = new BetaData(2, 5, 1);
    var rtHeatmap = $('#rt-heatmap').epoch({
        type: 'time.heatmap',
        data: rtHeatmapData.history(120),
        axes: [],
        bucketPadding: 2,
        windowSize: 30,
        buckets: 20
    })

    var rtLine = $('#rt-line').epoch({
        type: 'time.line',
        data: rtLineData,
        axes: []
    })

    setInterval(function() {
        var next = [
            {time: time, y: Math.random() * 25 + 25},
            {time: time, y: Math.random() * 25 + 50},
            {time: time, y: Math.random() * 25 + 75},
            {time: time++, y: Math.random() * 25 + 100}
        ];

        rtArea.push(next);
        rtBar.push(next);
        rtLine.push(next);
        rtHeatmap.push(rtHeatmapData.next());
    }, 1000);
});
