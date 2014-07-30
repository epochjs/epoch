(function() {

    // Quick data generator
    Data = function() {
        this.layers = []
    };

    Data.prototype.add = function(fn) {
        fn = fn ? fn : function(x) { return x; };
        this.layers.push(fn);
        return this;
    };

    Data.prototype.get = function(domain, step) {
        domain = domain ? domain : [0, 10];
        step = step ? step : 1;

        var data = []
        for (var i = 0; i < this.layers.length; i++) {
            layer = { label: String.fromCharCode(i + 65), values: [] };
            for (var x = domain[0]; x < domain[1]; x += step) {
                layer.values.push({ x: x, y: this.layers[i](x) });
            }
            data.push(layer);
        }
        return data;
    };

    Data.prototype.random = function(entries, domain, range) {
        entries = entries ? entries : 50;
        domain = domain ? domain : [0, 100];
        range = range ? range : [0, 100];

        var values = [];
        for (var i = 0; i < entries; i++) {
            var x = (domain[1] - domain[0]) * Math.random() + domain[0],
                y = (range[1] - range[0]) * Math.random() + range[1];
            values.push({ x: x, y: y });
        }

        return [{ label: 'A', values: values }];
    };

    Data.prototype.multiRandom = function(numSeries, entries, domain, range) {
        numSeries = numSeries ? numSeries : 3;
        entries = entries ? entries : 50;
        domain = domain ? domain : [0, 100];
        range = range ? range : [0, 100];

        var data = [];

        for (var j = 0; j < numSeries; j++) {
            var layer = { label: String.fromCharCode(65 + j), values: [] };
            for (var i = 0; i < entries; i++) {
                var x = (domain[1] - domain[0]) * Math.random() + domain[0],
                    y = (range[1] - range[0]) * Math.random() + range[1];
                layer.values.push({ x: x, y: y });
            }
            data.push(layer);
        }

        return data;
    };

    window.data = function() { return new Data(); };


    // Quick real-time data generator
    Time = function() {
        Data.call(this);
    };

    Time.prototype = new Data()

    Time.prototype.get = function(domain, step) {
        var data = Data.prototype.get.apply(this, arguments),
            time = parseInt(new Date().getTime() / 1000);

        for (var i = 0; i < data[0].values.length; i++) {
            for (var j = 0; j < this.layers.length; j++) {
                delete data[j].values[i].x;
                data[j].values[i].time = time + i;
            }
        }

        this.currentTime = time;
        this.lastX = domain[1];

        return data;
    };

    Time.prototype.next = function(step) {
        this.currentTime++;
        this.lastX += (step ? step : 1);

        var data = [];
        for (var j = 0; j < this.layers.length; j++) {
            data.push({ time: this.currentTime, y: this.layers[j](this.lastX) })
        }

        return data;
    }

    window.time = function() { return new Time(); };




    window.nextTime = (function() {
        var currentTime = parseInt(new Date().getTime() / 1000);
        return function() { return currentTime++; }
    })();


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


