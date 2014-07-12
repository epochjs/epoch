$(function() {
    // Set the appropriate year in the footer
    $('#footer .year').text(new Date().getFullYear());

    // Add a copy button to each code block.
    $('.highlight').each(function() {
        $(this).before('<div class="btn-clipboard-container"><span class="btn-clipboard" title="Copy to clipboard">Copy</span></div>');
    });

    var client = new ZeroClipboard($('.btn-clipboard'));
    client.on('ready', function(readyEvent) {
        client.on('copy', function(event) {
            var text = $(event.target).parent().nextAll('.highlight').first().text();
            client.setText(text);
        });

        client.on('aftercopy', function(event) {
            var copyButton = $(event.target).text('Copied!');
            
            setTimeout(function() {
                copyButton.text('Copy');
            }, 2000);
        });
    });
});
