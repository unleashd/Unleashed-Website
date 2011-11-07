/**
 * Functions for loading and displaying members.
 */
if (!unleashd) { unleashd = {}; }

/**
 * Load members.
 * actions.success and actions.failure will be called respectively.
 */
unleashd.loadMembers = function(actions) {
    var LIST_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/users/list';
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
 * Insert the given list of members into the document.
 */
unleashd.renderMembers = function(members) {
    var BASE_GET_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/users/get/';
    var sheetMusic = $('#member-list').find('tbody');
    $.each(members, function(i, member) {
        var memberRow = $('<tr>')
                .addClass(i % 2 == 0 ? 'even' : 'odd')
                .click(function(){
                    if (!$(this).hasClass('editable')) {
                        $(this).addClass('editable');
                        $(this).find('.delete-link').hide();
                        $(this).find('.update-button').show();
                        
                        $.each(['username', 'given_name', 'surname', 'email'], function(i, value) {
                            $('#'+member.id+'-'+value).hide();
                            $('#'+member.id+'-'+value+'-input').val($('#'+member.id+'-'+value).text());
                            $('#'+member.id+'-'+value+'-input').show();
                        });
                        $(this).find('input[type=checkbox]').attr('disabled', false);
                        $(this).find('select').attr('disabled', false);
                    }
                });
        memberRow
            .append($('<td class="action-column">')
                .append($('<a class="delete-link">')
                    .attr('href', '#').text('X')
                    .click(function(e){
                        e.stopPropagation();
                        e.preventDefault();
                        
                        memberRow.find('.delete-link').hide();
                        memberRow.find('.throbber').show();
                        unleashd.deleteMember(member.id, {
                            success: function() {
                                memberRow.hide();
                                memberRow.find('.throbber').hide();
                            },
                            failure: function() {
                                memberRow.find('.delete-link').show();
                                memberRow.find('.throbber').hide();
                            }
                        });
                    })
                )
                .append($('<button class="update-button">')
                    .text('Save')
                    .click(function(e){
                        e.stopPropagation();
                        
                        memberRow.find('.update-button').hide();
                        memberRow.find('.throbber').show();
                        unleashd.updateMember(
                            member.id,
                            {
                                username: $('#'+member.id+'-username-input').val(),
                                given_name: $('#'+member.id+'-given_name-input').val(),
                                surname: $('#'+member.id+'-surname-input').val(),
                                email: $('#'+member.id+'-email-input').val(),
                                is_admin: $('#'+member.id+'-is_admin-input').val()
                            },
                            {
                                success: function() {
                                    memberRow.find('.throbber').hide();
                                    memberRow.find('.delete-link').show();
                                    memberRow.removeClass('editable');
                                    $.each(['username', 'given_name', 'surname', 'email'], function(i, value) {
                                        $('#'+member.id+'-'+value).show();
                                        $('#'+member.id+'-'+value).text($('#'+member.id+'-'+value+'-input').val());
                                        $('#'+member.id+'-'+value+'-input').hide();
                                    });
                                    memberRow.find('input[type=checkbox]').attr('disabled', true);
                                    $(this).find('select').attr('disabled', true);
                                },
                                failure: function() {
                                    memberRow.find('.throbber').hide();
                                    memberRow.find('.update-button').hide();
                                }
                            });
                    })
                    .hide()
                )
                .append($('<img class="throbber">')
                    .attr('src', '/unleashd/img/throbber.gif')
                    .hide())
            )
            .append($('<td>')
                .append($('<span class="value">')
                    .attr('id', member.id+'-username')
                    .text(member.username))
                .append($('<input class="value-input">')
                    .attr('id', member.id+'-username-input')
                    .hide())
            )
            .append($('<td>')
                .append($('<select>')
                    .attr('id', member.id+'-auth_type')
                    .attr('disabled', true)
                    .append($('<option value="uw">').text('UW').attr('selected', member.auth_type === 'uw'))
                    .append($('<option value="non-uw">').text('Non UW').attr('selected', member.auth_type === 'non-uw')))
            )
            .append($('<td>')
                .append($('<span class="value">')
                    .attr('id', member.id+'-given_name')
                    .text(member.given_name ? member.given_name : ''))
                .append($('<input class="value-input">')
                    .attr('id', member.id+'-given_name-input')
                    .hide())
            )
            .append($('<td>')
                .append($('<span class="value">')
                    .attr('id', member.id+'-surname')
                    .text(member.surname ? member.surname : ''))
                .append($('<input class="value-input">')
                    .attr('id', member.id+'-surname-input')
                    .hide())
            )
            .append($('<td>')
                .append($('<span class="value">')
                    .attr('id', member.id+'-email')
                    .text(member.email ? member.email : ''))
                .append($('<input class="value-input">')
                    .attr('id', member.id+'-email-input')
                    .hide())
            )
            .append($('<td>').append($('<input type="checkbox">')
                .attr('id', member.id+'-is_admin')
                .attr('checked', member.is_admin)
                .attr('disabled', true))
            );
        sheetMusic.append(memberRow);
    });
};

unleashd.deleteMember = function(id, actions) {
    var DELETE_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/users/'+id+'/delete';
    $.ajax({
        type: 'POST', url: DELETE_URL,
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

unleashd.updateMember = function(id, new_values, actions) {
    var UPDATE_URL = 'https://students.washington.edu/unleashd/ajax/do.cgi/users/'+id+'/update';
    $.ajax({
        type: 'POST', url: UPDATE_URL,
        data: new_values,
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
