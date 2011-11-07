/**
 * Functions for loading and displaying sheet music.
 */
if (!unleashd) { unleashd = {}; }

/**
 * Load sheet music.
 * actions.success and actions.failure will be called respectively.
 */
unleashd.loadSheetMusic = function(actions) {
    var LIST_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/music/list';
    $.ajax({
        type: 'GET', url: LIST_URL,
        success: function(response) {
            if (response) {
                actions.success(response);
            } else {
                actions.failure();
            }
        },
        error: function() {
            actions.failure();
        }
    });
};

/**
 * Insert the given list of sheet music into the document.
 */
unleashd.renderSheetMusic = function(pieces) {
    var BASE_GET_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/music/get/';
    var sheetMusic = $('#sheet-music').find('tbody');
    $.each(pieces, function(i, piece) {
        sheetMusic.append(
            $('<tr>').addClass(i % 2 == 0 ? 'even' : 'odd')
                .append($('<td>')
                    .append($('<a>').attr('href', BASE_GET_URL + piece.path)
                                    .text(piece.name)
                    )
                )
            );
    });
};
