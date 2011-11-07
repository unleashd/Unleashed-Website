/**
 * Javscript code for user authentication.
 */
unleashd = {};
/**
 * Perform actions based on whether or not the user is authenticated.
 * actions.yes({method: "...", username: "..."}) or actions.no() will be
 * called appropriately.
 */
unleashd.ifAuthenticated = function (actions) {
    var CHECK_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/check';
    $.ajax({
        type: 'GET', url: CHECK_URL,
        success: function(response) {
            if (response) {
                actions.yes(response);
            } else {
                actions.no();
            }
        },
        error: function(error) {
            console.log(error);
        }
    });
};

/**
 * Attempt to log the user in using the given username and password
 * for both UW NetId and Non-UW authentication.
 * handlers.success(method) and handlers.error() will be called appropriately.
 */
unleashd.login = function (username, password, handlers) {
    var LOGIN_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/login';
    
    $.ajax({
        type: 'POST', url: LOGIN_URL,
        data: { username: username, password: password },
        success: function(response) {
            if (response) {
                $.each(response.cookies, function(key, value) {
                    $.cookie(key, value, {path: '/', secure: true});
                });
                $.cookie('unleashd-authtoken', response.authtoken, {path: '/unleashd/', secure: true});
                handlers.success(response);
            } else {
                handlers.failure()
            }
        },
        error: function(error) {
            console.log(error);
        }
    });
};
