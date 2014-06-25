// Affix for the docs page navigation
(function() {

    if ($(window).width() < 1000) {
      $('body.docs #nav').remove()
      return;
    }

    var el = $('body.docs #nav'),
        dummy = $('body.docs #nav-dummy'),
        offset = null;

    var affix = $('body.docs #nav').affix({
        offset: {
          top: 92,
          left: function() { return offset; },
          bottom: function () {
            return (this.bottom = $('.footer').outerHeight(true))
          }
        }
    });

    affix.on('affix.bs.affix', function() { 
        offset = el.offset().left;
        dummy.show();
    });
    affix.on('affix-top.bs.affix', function() { dummy.hide(); })
})();

// Scrollspy for docs page navigation
$('body.docs').scrollspy({ target: '#nav' });
