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
} );