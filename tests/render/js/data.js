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

    return function() {
        return new Data();
    };
})();


