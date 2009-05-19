if( document.referrer ) {
    document.write(
        '<'+'img src="http://rome.purepistos.net:8016/track?' +
        'r=' + escape( document.referrer ) +
        '&l=' + escape( document.location ) +
        '" style="float:left;" width="1" height="1"/>'
    );
}