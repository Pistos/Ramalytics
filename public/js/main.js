function hide_shortly( thing ) {
    setTimeout( function() {
        thing.slideUp();
    }, 5000 );
}

function show_result_messages( json ) {
    if( json.error ) {
        $( '#message-error' ).text( json.error ).slideDown();
        hide_shortly( $( '#message-error' ) );
    }
    if( json.success ) {
        $( '#message-success' ).text( json.success ).slideDown();
        hide_shortly( $( '#message-success' ) );
    }
}

function slideUp_tr( tr ) {
    tr.children( 'td' ).each( function() {
        var td = $(this);
        td.wrapInner("<div></div>").children( "div" ).slideUp();
        td.animate(
            { paddingTop: '0px', paddingBottom: '0px', },
            'normal',
            function() {
                if( $.browser.opera ) {
                    tr.remove();
                } else {
                    td.css( 'border', '0px' );
                }
            }
        );
    });
};

$( document ).ready( function() {
    $( 'textarea' ).focus( function() {
        this.select();
    } );

    $( '#site-picker' ).change( function() {
        window.location = '/stats/' + $('option:selected', this).eq(0).val();
    } );

    var a = /\/stats\/(\d+)/( window.location );
    if( a ) {
        $( '#site-picker' ).val( a[ 1 ] );
    }

    $( 'a.mark-seen-referrer' ).click( function() {
        var button = $(this);
        $.post(
            '/seen/referrer.json',
            { json: $.toJSON( { uri_id: button.attr( 'uri-id' ) } ) },
            function( response ) {
                if( response.success ) {
                    slideUp_tr( button.closest( 'tr' ) );
                }
                show_result_messages( response );
            },
            'json'
        );
        return false;
    } );
} );