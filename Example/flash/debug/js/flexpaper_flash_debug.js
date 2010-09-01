var docViewer;

function getDocViewer(){
    if(docViewer)
        return docViewer;
    else if(window.FlexPaperViewer)
        return window.FlexPaperViewer;
    else if(document.FlexPaperViewer)
	return document.FlexPaperViewer;
    else 
	return null;
}

/**
 * Handles the event of external links getting clicked in the document. 
 *
 * @example onExternalLinkClicked("http://www.google.com")
 *
 * @param String link
 */
function onExternalLinkClicked(link){
	$("#txt_eventlog").val('onExternalLinkClicked' + '\n' + $("#txt_eventlog").val());	
}

/**
 * Recieves progress information about the document being loaded
 *
 * @example onProgress( 100,10000 );
 *
 * @param int loaded
 * @param int total
 */
function onProgress(loadedBytes,totalBytes){
	$("#txt_progress").val('onProgress:' + loadedBytes + '/' + totalBytes + '\n');	
}

/**
 * Handles the event of a document is in progress of loading
 *
 */
function onDocumentLoading(){
	$("#txt_eventlog").val('onDocumentLoading' + '\n' + $("#txt_eventlog").val());	
}

/**
 * Receives messages about the current page being changed
 *
 * @example onCurrentPageChanged( 10 );
 *
 * @param int pagenum
 */
function onCurrentPageChanged(pagenum){
	$("#txt_eventlog").val('onCurrentPageChanged:' + pagenum + '\n' + $("#txt_eventlog").val());
}

/**
 * Receives messages about the document being loaded
 *
 * @example onDocumentLoaded( 20 );
 *
 * @param int totalPages
 */
function onDocumentLoaded(totalPages){
	$("#txt_eventlog").val('onDocumentLoaded:' + totalPages + '\n' + $("#txt_eventlog").val());
}

/**
 * Receives error messages when a document is not loading properly
 *
 * @example onDocumentLoadedError( "Network error" );
 *
 * @param String errorMessage
 */
function onDocumentLoadedError(errMessage){
	$("#txt_eventlog").val('onDocumentLoadedError:' + errMessage + '\n' + $("#txt_eventlog").val());
}