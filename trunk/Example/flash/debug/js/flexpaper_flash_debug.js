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

if(window.addEventListener)
window.addEventListener('DOMMouseScroll', handleWheel, false);
window.onmousewheel = document.onmousewheel = handleWheel;

if (window.attachEvent) 
window.attachEvent("onmousewheel", handleWheel);



/**
 * Handles mouse wheel scrolling
 *
 */
function handleWheel(event){
	try{
		if(!getDocViewer().hasFocus()){return true;}
		getDocViewer().setViewerFocus(true);
		getDocViewer().focus();
		
		if(navigator.appName == "Netscape"){
			if (event.detail)
				delta = 0;
			if (event.preventDefault){
				event.preventDefault();
				event.returnValue = false;
				}
		}
		return false;	
	}catch(err){return true;}		
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