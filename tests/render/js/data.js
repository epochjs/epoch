window.data = (function() {
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

        values = [];
        for (var i = 0; i < entries; i++) {
            var x = (domain[1] - domain[0]) * Math.random() + domain[0],
                y = (range[1] - range[0]) * Math.random() + range[1];
            values.push({ x: x, y: y });
        }

        return [{ label: 'A', values: values }];
    };

    return function() {
        return new Data();
    };
})();


