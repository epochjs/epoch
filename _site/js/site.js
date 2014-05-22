/*
 * Epoch Site-wide JS
 */


// Set the appropriate year in the footer
$(function() {
    $('#footer .year').text(new Date().getFullYear());
});


// Affix for the docs page navigation
$('body.docs #nav').affix({
    offset: {
      top: 0,
      bottom: function () {
        return (this.bottom = $('.footer').outerHeight(true))
      }
    }
});

// Scrollspy for docs page navigation
$('body.docs').scrollspy({ target: '#nav' });
