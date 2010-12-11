/* 
Copyright 2009 Erik Engström

This file is part of FlexPaper.

FlexPaper is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

FlexPaper is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FlexPaper.  If not, see <http://www.gnu.org/licenses/>.	
*/

package com.devaldi.controls.flexpaper
{
	import caurina.transitions.Tweener;
	
	import com.devaldi.controls.FlowBox;
	import com.devaldi.controls.FlowTwoPage;
	import com.devaldi.controls.FlowVBox;
	import com.devaldi.controls.MatrixTransformer;
	import com.devaldi.controls.ZoomCanvas;
	import com.devaldi.controls.flexpaper.utils.TextMapUtil;
	import com.devaldi.events.CurrentPageChangedEvent;
	import com.devaldi.events.CursorModeChangedEvent;
	import com.devaldi.events.DocumentLoadedEvent;
	import com.devaldi.events.ExternalLinkClickedEvent;
	import com.devaldi.events.DocumentPrintedEvent;
	import com.devaldi.events.FitModeChangedEvent;
	import com.devaldi.events.ScaleChangedEvent;
	import com.devaldi.events.SelectionCreatedEvent;
	import com.devaldi.events.ViewModeChangedEvent;
	import com.devaldi.streaming.AVM2Loader;
	import com.devaldi.streaming.DupImage;
	import com.devaldi.streaming.DupLoader;
	
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextSnapshot;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.core.Container;
	import mx.core.SpriteAsset;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.managers.CursorManager;
	
	[Event(name="onDocumentLoaded", type="com.devaldi.events.DocumentLoadedEvent")]
	[Event(name="onDocumentLoading", type="flash.events.Event")]
	[Event(name="onNoMoreSearchResults", type="flash.events.Event")]
	[Event(name="onLoadingProgress", type="flash.events.ProgressEvent")]
	[Event(name="onScaleChanged", type="com.devaldi.events.ScaleChangedEvent")]
	[Event(name="onExternalLinkClicked", type="com.devaldi.events.ExternalLinkClickedEvent")]
	[Event(name="onCurrPageChanged", type="com.devaldi.events.CurrentPageChangedEvent")]
	[Event(name="onViewModeChanged", type="com.devaldi.events.ViewModeChangedEvent")]
	[Event(name="onFitModeChanged", type="com.devaldi.events.FitModeChangedEvent")]
	[Event(name="onCursorModeChanged", type="com.devaldi.events.CursorModeChangedEvent")]
	[Event(name="onDocumentLoadedError", type="flash.events.ErrorEvent")]
	[Event(name="onLogoClicked", type="flash.events.Event")]
	[Event(name="onSelectionCreated", type="com.devaldi.events.SelectionCreatedEvent")]
	[Event(name="onDocumentPrinted", type="com.devaldi.events.DocumentPrintedEvent")]
	
	public class Viewer extends Canvas
	{
		private var _swfFile:String = "";
		private var _swfFileChanged:Boolean = false;
		private var _initialized:Boolean = false;
		private var _loader:Loader = new Loader();
		private var _loaderptr:Loader;
		private var _libMC:MovieClip;
		private var _displayContainer:Container;
		private var _paperContainer:ZoomCanvas;
		private var _swfContainer:Canvas; 
		private var _scale:Number = 1;
		private var _pscale:Number = 1;
		private var _swfLoaded:Boolean  = false;
		private var _pageList:Array;
		private var _viewMode:String = ViewModeEnum.PORTRAIT;
		private var _fitMode:String = FitModeEnum.FITNONE; 
		private var _scrollToPage:Number = 0;
		private var _numPages:Number = 0;
		private var _currPage:Number = 0;
		private var _tweencount:Number = 0;
		private var _bbusyloading:Boolean = true;
		private var _zoomtransition:String = "easeOut";
		private var _zoomtime:Number = 0.6; 
		private var _fitPageOnLoad:Boolean = false;
		private var _fitWidthOnLoad:Boolean = false;
		private var _dupImageClicked:Boolean = false;
		private var _docLoader:AVM2Loader;
		private var _progressiveLoading:Boolean = false;
		private var _repaintTimer:Timer;
		private var _frameLoadCount:int = 0;
		private var loaderCtx:LoaderContext;
		private var _adjGotoPage:int = 0;
		private var _zoomInterval:Number = 0;
		private var _inputBytes:ByteArray;
		private var _textSelectEnabled:Boolean = false;
		private var _cursorsEnabled:Boolean = true;
		private var _grabCursorID:Number = 0;
		private var _grabbingCursorID:Number = 0;
		private var _savePaddingTwoPage:Number = -1;
		private var _pluginList:Array;
		public static var ViewModeExtList:Array;
		private var _currentExtViewMode:IFlexPaperViewModePlugin;
		
		[Embed(source="/../assets/grab.gif")]
		private var grabCursor:Class;	  
		
		[Embed(source="/../assets/grabbing.gif")]
		private var grabbingCursor:Class;	  	 
		
		[Embed(source="/../assets/textselectcursor.gif")]
		private var textSelectCursor:Class;	  	 
		
		[Embed(source="/../assets/logosmall-trans.png")]
		private var skinImg:Class
		
		[Embed(source="/../assets/logosmall-transc.png")]
		private var skinImgc:Class
		
		private var _skinImg:Bitmap = new skinImg();
		private var _skinImgc:Bitmap = new skinImgc();
		private var _skinImgDo:Image;
		
		public function Viewer(){
			super();
		}
		
		public function get BusyLoading():Boolean {
			return _bbusyloading;
		}	
		
		public function set BusyLoading(b:Boolean):void {
			_bbusyloading = b;
		}	
		
		public function get libMC():MovieClip {
			return _libMC;
		}
		
		public function get IsInitialized():Boolean{
			return _initialized;
		}
		
		public function get SwfLoaded():Boolean{
			return _swfLoaded;
		}
		
		public function get DisplayContainer():Container{
			return _displayContainer;
		}
		
		public function set DisplayContainer(c:Container):void{
			_displayContainer = c;
		}
		
		public function get PaperContainer():ZoomCanvas{
			return _paperContainer;
		}
		
		public function get PageList():Array {
			return _pageList;
		}
		
		public function get DocLoader():AVM2Loader{
			return _docLoader;
		}
		
		[Bindable]
		public function get ViewMode():String {
			return _viewMode;
		}	
		
		[Bindable]
		public function get FitMode():String {
			return _fitMode;
		}	
		
		public function set InitViewMode(s:String):void{
			_viewMode = s;
		}
		
		public function set ViewMode(s:String):void {
			if(s!=_viewMode){
				
				for each (var vme:IFlexPaperViewModePlugin in ViewModeExtList){
					if(s == vme.Name){
						_currentExtViewMode = vme;
					}
				}
				
				if(!UsingExtViewMode){
					if((s == ViewModeEnum.TILE||s == ViewModeEnum.TWOPAGE)&&ViewMode==ViewModeEnum.PORTRAIT){_pscale = _scale; _scale = 0.23;_paperContainer.verticalScrollPosition = 0;_fitMode = FitModeEnum.FITNONE;}else{_scale = _pscale;}
					_paperContainer.x = (s==ViewModeEnum.PORTRAIT||s==ViewModeEnum.TILE)?2.5:0;
					
					_viewMode = s;
					if(_initialized && _swfLoaded){createDisplayContainer();if(this._progressiveLoading){this.addInLoadedPages(true);}else{reCreateAllPages();}_displayContainer.visible = true;}
					FitMode = FitModeEnum.FITNONE;
				}else{
					CurrExtViewMode.setViewMode(s);
					_viewMode = s;
				}
				
				dispatchEvent(new ViewModeChangedEvent(ViewModeChangedEvent.VIEWMODE_CHANGED,_viewMode));
				dispatchEvent(new ScaleChangedEvent(ScaleChangedEvent.SCALE_CHANGED,_scale));
				dispatchEvent(new FitModeChangedEvent(FitModeChangedEvent.FITMODE_CHANGED,_fitMode));
			}
		}
		
		public function set FitMode(s:String):void {
			if(_viewMode == ViewModeEnum.TILE){_fitMode = FitModeEnum.FITNONE;return}
			
			if(s!=_fitMode){
				_fitMode = s;
				
				switch(s){					
					case FitModeEnum.FITWIDTH:
						fitWidth();
						break;
					
					case FitModeEnum.FITHEIGHT:
						fitHeight();
						break;										
				}
				
				dispatchEvent(new FitModeChangedEvent(FitModeChangedEvent.FITMODE_CHANGED,_fitMode));
			}
		}
		
		public function set ProgressiveLoading(b1:Boolean):void {
			_progressiveLoading = b1;
		}
		
		[Bindable]
		public function get ProgressiveLoading():Boolean {
			return _progressiveLoading;
		}	
		
		public function set TextSelectEnabled(b1:Boolean):void {
			_textSelectEnabled = b1;
			
			if(_textSelectEnabled && CursorsEnabled)	
				dispatchEvent(new CursorModeChangedEvent(CursorModeChangedEvent.CURSORMODE_CHANGED,"TextSelectorCursor"));
			else
				dispatchEvent(new CursorModeChangedEvent(CursorModeChangedEvent.CURSORMODE_CHANGED,"ArrowCursor"));
		}
		
		[Bindable]
		public function get TextSelectEnabled():Boolean {
			return _textSelectEnabled;
		}	
		
		[Bindable]
		public function get CursorsEnabled():Boolean {
			return _cursorsEnabled;
		}	

		public function set CursorsEnabled(b:Boolean):void {
			 _cursorsEnabled = b;
		}	
				
		public function setPaperFocus():void{
			_paperContainer.setFocus();
		}
		
		public function get ZoomTransition():String {
			return _zoomtransition;
		}	
		
		public function set ZoomTransition(s:String):void {
			_zoomtransition = s;
		}
		
		public function get ZoomTime():Number {
			return _zoomtime;
		}	
		
		public function set ZoomTime(n:Number):void {
			_zoomtime = n;
		}		
		
		public function get PluginList():Array{
			return _pluginList;
		}
		
		public function set PluginList(p:Array):void{
			_pluginList = p;
		}

		public function get CurrExtViewMode():IFlexPaperViewModePlugin{
			if(_currentExtViewMode != null && _currentExtViewMode.Name == ViewMode)
				return _currentExtViewMode;
			else{
				for each (var vme:IFlexPaperViewModePlugin in ViewModeExtList){
					if(ViewMode == vme.Name){
						_currentExtViewMode = vme;
					}
				}
			}
			
			return _currentExtViewMode;
		}
		
		public function get UsingExtViewMode():Boolean{
			if(ViewMode == ViewModeEnum.PORTRAIT || ViewMode == ViewModeEnum.TILE)
				return false;
			else
				return (CurrExtViewMode!=null && ViewMode == CurrExtViewMode.Name);	
		}
		
		public function get ZoomInterval():Number {
			return _zoomInterval;
		}	
		
		public function set ZoomInterval(n:Number):void {
			_zoomInterval = n;
		}				
		
		[Bindable]
		public function get numPages():Number {
			return _numPages;
		}	
		
		private function set numPages(n:Number):void {
			_numPages = n;
		}
		
		[Bindable]
		public function get numPagesLoaded():Number {
			return (_libMC!=null)?_libMC.framesLoaded:0;
		}	
		
		private function set numPagesLoaded(n:Number):void {
			
		}
		
		[Bindable]
		public function get currPage():Number {
			return _currPage;
		}	
		
		private function set currPage(n:Number):void {
			_currPage = n;
		}		
		
		public function get FitWidthOnLoad():Boolean {
			return _fitWidthOnLoad;
		}	
		
		public function set FitWidthOnLoad(b1:Boolean):void {
			_fitWidthOnLoad = b1;
		}
		
		public function get FitPageOnLoad():Boolean {
			return _fitPageOnLoad;
		}	
		
		public function set FitPageOnLoad(b2:Boolean):void {
			_fitPageOnLoad = b2;
		}			
		
		public function gotoPage(p:Number, adjGotoPage:int=0):void{
			if(adjGotoPage!=0){_adjGotoPage=adjGotoPage;}
			
			if(p<1 || p-1 >_pageList.length || (ViewMode == ViewModeEnum.TWOPAGE && p-1 >= _pageList.length))
				return;
			else{
				if(ViewMode == ViewModeEnum.PORTRAIT){
					_paperContainer.verticalScrollPosition = _pageList[p-1].y+3 + _adjGotoPage;
				}else if(ViewMode == ViewModeEnum.TWOPAGE){
					_paperContainer.verticalScrollPosition = _pageList[p-1].parent.y + _adjGotoPage - 10;
				}
				
				if(UsingExtViewMode)
					CurrExtViewMode.gotoPage(p,adjGotoPage);	
			
				// retry if y is not set
				if(ViewMode != ViewModeEnum.TWOPAGE && p>1 && _pageList[p-1].y ==0)
				{ 
					flash.utils.setTimeout(gotoPage,200,p);
				}
				else
					_adjGotoPage = 0;
				
				repositionPapers();
			}
		}
		
		public function switchMode(mode:String=null):void{
			if(mode==null){ // no mode passed, just 
				if(ViewMode == ViewModeEnum.PORTRAIT){ViewMode = ViewModeEnum.TILE;}
				else if(ViewMode == ViewModeEnum.TILE){_scale = _pscale; ViewMode = ViewModeEnum.PORTRAIT;}
			}else{
				if(ViewMode == mode && ViewMode != ViewModeEnum.PORTRAIT){
					ViewMode = ViewModeEnum.PORTRAIT;
				}
				else
					ViewMode = mode;				
			}
		}
		
		public function get PaperVisible():Boolean {
			return _paperContainer.visible;
		}

		public function set PaperVisible(b:Boolean):void {
			_paperContainer.visible = b;
		}
		
		public function get SwfFile():String {
			return _swfFile;
		}	
		
		public function set SwfFile(s:String):void {
			if(s.length!=0){
				clearPlugins();
				deleteDisplayContainer(); 
				deletePageList();
				deleteLoaderPtr();
				deleteLoaderList();
				deleteFLoader();
				deleteSelectionMarker();
				TextMapUtil.totalFragments = "";
				
				if(s!=_swfFile)
					deleteLibMC();
				
				_swfFileChanged = true;
				_frameLoadCount = 0;
				_swfFile = encodeURI(s);
				
				try{
					new flash.net.LocalConnection().connect('devaldiGCdummy');
					new flash.net.LocalConnection().connect('devaldiGCdummy');
				} catch (e:*) {}
				
				try{flash.system.System.gc();} catch (e:*) {}
				
				_paperContainer.verticalScrollPosition = 0;
				_savePaddingTwoPage = -1;
				
				createDisplayContainer();
				
				// Changing the SWF file causes the component to invalidate.
				invalidateProperties();
				invalidateSize();
				invalidateDisplayList();		
			}
		}
		
		[Bindable]
		public function get Scale():String {
			return _scale.toString();
		}		
		
		public function get CurrentlySelectedText():String {
			return _currentlySelectedText;
		}
		
		public function Zoom(factor:Number):void{
			if(factor<0.10 || factor>5 || factor == _scale)
				return;
			
			if(_viewMode != ViewModeEnum.PORTRAIT && _viewMode != ViewModeEnum.TWOPAGE){return;}
			
			if(UsingExtViewMode && !CurrExtViewMode.doZoom)
				return;	
			
			var _target:DisplayObject;
			_paperContainer.CenteringEnabled = (_paperContainer.width>0);
			
			_tweencount = _displayContainer.numChildren;
			
			for(var i:int=0;i<_displayContainer.numChildren;i++){
				_target = _displayContainer.getChildAt(i);
				_target.filters = null;
				Tweener.addTween(_target, {scaleX: factor, scaleY: factor, time: _zoomtime, transition: _zoomtransition, onComplete: tweenComplete});
			}
			
			FitMode = FitModeEnum.FITNONE;
			_scale = factor;
			
			dispatchEvent(new ScaleChangedEvent(ScaleChangedEvent.SCALE_CHANGED,_scale));
		}
		
		// rotate not finished.
		public function rotate():void{
			var counter:int=0;
			//Tweener.addTween(_displayContainer.getChildAt(currPage-1), {x:_displayContainer.getChildAt(currPage-1).parent.width/2+_displayContainer.getChildAt(currPage-1).height/2, y:((_displayContainer.getChildAt(currPage-1).height/2)-_displayContainer.getChildAt(currPage-1).width/2),rotation:90, time: 0.3, transition: 'easenone', onComplete: tweenComplete});
		}
		
		private function getFitWidthFactor():Number{
			_libMC.gotoAndStop(1);
			return (_paperContainer.width / _libMC.width) - 0.032; //- 0.03;
		}
		
		private function getFitHeightFactor():Number{
			_libMC.gotoAndStop(1);
			return  (_paperContainer.height / _libMC.height);
		}
		
		public function fitWidth():void{
			if(_displayContainer.numChildren == 0){return;}
			
			var _target:DisplayObject;
			_paperContainer.CenteringEnabled = (_paperContainer.width>0);
			var factor:Number = getFitWidthFactor();
			_scale = factor;
			_tweencount = _displayContainer.numChildren;
			
			for(var i:int=0;i<_displayContainer.numChildren;i++){
				_target = _displayContainer.getChildAt(i);
				_target.filters = null;
				Tweener.addTween(_target, {scaleX:factor, scaleY:factor,time: 0, transition: 'easenone', onComplete: tweenComplete});
			}
			
			FitMode = FitModeEnum.FITWIDTH;
			
			dispatchEvent(new ScaleChangedEvent(ScaleChangedEvent.SCALE_CHANGED,_scale));
		}
		
		public function fitHeight():void{
			if(_displayContainer.numChildren == 0){return;}
			
			var _target:DisplayObject;
			_paperContainer.CenteringEnabled = (_paperContainer.height>0);
			var factor:Number = getFitHeightFactor(); 
			_scale = factor;
			_tweencount = _displayContainer.numChildren;
			
			for(var i:int=0;i<_displayContainer.numChildren;i++){
				_target = _displayContainer.getChildAt(i);
				_target.filters = null;
				Tweener.addTween(_target, {scaleX:factor, scaleY:factor,time: 0, transition: 'easenone', onComplete: tweenComplete});
			}			
			
			FitMode = FitModeEnum.FITHEIGHT;
			
			dispatchEvent(new ScaleChangedEvent(ScaleChangedEvent.SCALE_CHANGED,_scale));
		}
		
		private function tweenComplete():void{
			_tweencount--;
						
			if(_tweencount==0){
				repositionPapers();
			}
			
			if(_tweencount < numPagesLoaded - 2 || _tweencount == 0){
				PaperVisible = true;
			}
		}
		
		private function reScaleComplete():void{
			_tweencount--;

			if(_tweencount==0){
				if(_displayContainer.numChildren>0){
					_paperContainer.verticalScrollPosition = 0;
					repositionPapers();
				}				
				
				if(_tweencount < numPagesLoaded - 2 || _tweencount == 0){
					PaperVisible = true;
				}
			}	
		}
		
		public function set Scale(s:String):void {
			var diff:Number = _scale - new Number(s);
			_scale = new Number(s);
		}		
		
		override protected function createChildren():void {
			// Call the createChildren() method of the superclass.
			super.createChildren();
			this.styleName = "viewerBackground";
			
			// Bind events
			//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfComplete);
			addEventListener(Event.RESIZE, sizeChanged,false,0,true);
			systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler,false,0,true);
			
			// Create a visible container for the swf
			_swfContainer = new Canvas();
			_swfContainer.visible = false;
			this.addChild(_swfContainer);
			
			// Create a timer to use for repainting
			_repaintTimer = new Timer(5,0);
			_repaintTimer.addEventListener("timer", repaintHandler);
			createDisplayContainer();
		}
		
		private function onframeenter(event:Event):void{
			if(!_dupImageClicked){return;}
			
			if(event.target.content != null){
				if (event.target.parent is DupImage &&
					event.target.content.currentFrame!=(event.target.parent as DupImage).dupIndex 
					&& _dupImageClicked){
					var np:int = event.target.content.currentFrame;
					event.target.content.gotoAndStop((event.target.parent as DupImage).dupIndex);
					gotoPage(np);
				}
			}
		}
		
		private function updComplete(event:Event):void	{
			if(_scrollToPage>0){
				_paperContainer.verticalScrollPosition = _pageList[_scrollToPage-1].y;
				_paperContainer.horizontalScrollPosition = 0;
				_scrollToPage = 0;
			}
						
			_repaintTimer.reset();_repaintTimer.start();
			//repositionPapers();
		}
		
		private function repaintHandler(e:Event):void {
			repositionPapers();
			_repaintTimer.stop();
			_repaintTimer.delay = 5;
		}
		
		private function bytesLoaded(event:Event):void{
			event.target.loader.loaded = true;
			if(event.target.loader.content!=null){event.target.loader.content.stop();}
			
			var bFound:Boolean=false;
			if(!ProgressiveLoading || (ProgressiveLoading && _libMC.framesLoaded == _libMC.totalFrames)){
				for(var i:int=0;i<_docLoader.LoaderList.length;i++){
					if(!_docLoader.LoaderList[i].loaded && !(_docLoader.LoaderList[i].parent is DupImage)){
						_docLoader.LoaderList[i].loadBytes(_inputBytes,getExecutionContext());
						bFound = true;
						break;
					}
				}
			}
			
			if(!bFound){
				_bbusyloading = false;
				if(_fitPageOnLoad){FitMode = FitModeEnum.FITHEIGHT;_fitPageOnLoad=false;_scrollToPage=1;}
				if(_fitWidthOnLoad){FitMode = FitModeEnum.FITWIDTH;_fitWidthOnLoad=false;_scrollToPage=1;}
				_displayContainer.visible = true;

				if(	_libMC.framesLoaded == _libMC.totalFrames  && _frameLoadCount != _libMC.framesLoaded){
					dispatchEvent(new DocumentLoadedEvent(DocumentLoadedEvent.DOCUMENT_LOADED,numPages));
					_frameLoadCount = _libMC.framesLoaded;
				}	
			}
		}
		
		public function repositionPapers():void{
			if(_docLoader==null){return;}
			if(_docLoader!=null&&_docLoader.LoaderList==null||numPagesLoaded==0){return;}
			
			{
				var loaderidx:int=0;
				var bFoundFirst:Boolean = false;
				var _thumb:Bitmap;
				var _thumbData:BitmapData;
				var uloaderidx:int=0;
				var p:int=-1;
				var pl:int=0;
				
				for(var i:int=0;i<_pageList.length;i++){
					if(ViewMode == ViewModeEnum.TILE){
						if(!bFoundFirst && ((i) * (_pageList[i].height + 6)) >= _paperContainer.verticalScrollPosition){
							bFoundFirst = true;
							p = i + 1;
						}
					}
					else if(ViewMode == ViewModeEnum.TWOPAGE){
						if(!bFoundFirst && _pageList[i].parent.y >= _paperContainer.verticalScrollPosition - _pageList[i].getScaledHeight()){
							bFoundFirst = true;
							p = (i==_pageList.length-1||(i<_pageList.length-1&&_pageList[i+1].parent.y!=_pageList[i].parent.y))?i + 1:i+2;
						}
					}
					else if(ViewMode == ViewModeEnum.PORTRAIT){
						if(!bFoundFirst)
						{
							var perH:int=0;
							if(_pageList.length>1)
							{
								perH=_pageList[1].y-_pageList[0].y;
								var nowP:Number=_paperContainer.verticalScrollPosition/(perH);
								if(0<nowP<0.5)
									p = 1;
								else if(nowP>=(_pageList.length-0.5)&&nowP<=_pageList.length)
									p = _pageList.length;
								else{
									p = Math.round(nowP)+1;
									if(_pageList.length>p-1&&_paperContainer.verticalScrollPosition<_pageList[p-1].y && p!=_pageList.length){
										p-=1;
									}
								}
								bFoundFirst = true;
							}
							else
							{
								bFoundFirst = true;
								p = 1;
							}
						}
					}
					
					if(p>numPages)
						return;
					
					if(UsingExtViewMode){
						if(currPage != CurrExtViewMode.currentPage)
							dispatchEvent(new CurrentPageChangedEvent(CurrentPageChangedEvent.PAGE_CHANGED,CurrExtViewMode.currentPage));
						
						p = CurrExtViewMode.currentPage;
						currPage = p;
					}
					
					if(p>0&&p!=_currPage){
						currPage = p;
						dispatchEvent(new CurrentPageChangedEvent(CurrentPageChangedEvent.PAGE_CHANGED,p));
					}
					
					if(checkIsVisible(i)){
						if(_pageList[i].numChildren<4){
							if(ViewMode == ViewModeEnum.PORTRAIT||ViewMode == ViewModeEnum.TWOPAGE){ 		
								uloaderidx = (i==_pageList.length-1&&loaderidx+3<_docLoader.LoaderList.length)?loaderidx+3:(loaderidx<_docLoader.LoaderList.length)?loaderidx:0;									
								
								if(!_bbusyloading && _docLoader.LoaderList!=null && _docLoader.LoaderList.length>0){
									if(_libMC!=null&&numPagesLoaded>=_pageList[i].dupIndex && _docLoader.LoaderList[uloaderidx] != null && _docLoader.LoaderList[uloaderidx].content==null||(_docLoader.LoaderList[uloaderidx].content!=null&&_docLoader.LoaderList[uloaderidx].content.framesLoaded<_pageList[i].dupIndex)){
										_bbusyloading = true;
										_docLoader.LoaderList[uloaderidx].loadBytes(_inputBytes,getExecutionContext());
										flash.utils.setTimeout(repositionPapers,200);
									}
								}
								
								if((i<2||_pageList[i].numChildren==0||(_pageList[i]!=null&&_docLoader.LoaderList[uloaderidx]!=null&&_docLoader.LoaderList[uloaderidx].content!=null&&_docLoader.LoaderList[uloaderidx].content.currentFrame!=_pageList[i].dupIndex))
									&& _docLoader.LoaderList[uloaderidx] != null && _docLoader.LoaderList[uloaderidx].content != null){
									if(numPagesLoaded >= _pageList[i].dupIndex){
										_docLoader.LoaderList[uloaderidx].content.gotoAndStop(_pageList[i].dupIndex);
										_pageList[i].addChild(_docLoader.LoaderList[uloaderidx]);
										_pageList[i].loadedIndex = _pageList[i].dupIndex;
										/* if(_libMC.width*_scale>0&&_libMC.height*_scale>0){
											_libMC.gotoAndStop(_pageList[i].dupIndex);
											_thumbData = new BitmapData(_libMC.width*_scale, _libMC.height*_scale, false, 0xFFFFFF);
											_thumb = new Bitmap(_thumbData);
											_pageList[i].source = _thumb;
											_thumbData.draw(_libMC,new Matrix(_scale, 0, 0, _scale),null,null,null,true);
										} */
									}	
								}
								
							}else if(ViewMode == ViewModeEnum.TILE && _pageList[i].source == null && numPagesLoaded >= _pageList[i].dupIndex){
								_libMC.gotoAndStop(_pageList[i].dupIndex);
								_thumbData = new BitmapData(_libMC.width*_scale, _libMC.height*_scale, false, 0xFFFFFF);
								_thumb = new Bitmap(_thumbData);
								_pageList[i].source = _thumb;
								_thumbData.draw(_libMC,new Matrix(_scale, 0, 0, _scale),null,null,null,true);
								
								if(_pluginList!=null){
									for(pl=0;pl<_pluginList.length;pl++){
										_pluginList[pl].drawSelf(i,_thumbData,_scale);
									}
								}
							}
						}
						
						if(UsingExtViewMode){
							CurrExtViewMode.renderPage(i);
							CurrExtViewMode.renderSelection(i,_selectionMarker);
						}
						
						if((_viewMode == ViewModeEnum.PORTRAIT||_viewMode == ViewModeEnum.TWOPAGE) && _selectionMarker != null){
							if(i+1 == searchPageIndex && _selectionMarker.parent != _pageList[i]){
								_pageList[i].addChildAt(_selectionMarker,_pageList[i].numChildren);
							}else if(i+1 == searchPageIndex && _selectionMarker.parent == _pageList[i]){
								_pageList[i].setChildIndex(_selectionMarker,_pageList[i].numChildren -1);
							}
						}
						
						if(_viewMode != ViewModeEnum.TILE){
							if(_pluginList!=null){
								for(pl=0;pl<_pluginList.length;pl++){
									_pluginList[pl].drawSelf(i,_pageList[i],_scale);
								}
							}
						}

						
						loaderidx++;
					}else{
						if(_pageList[i].numChildren>0 || _pageList[i].source != null){
							_pageList[i].source = null;
							_pageList[i].removeAllChildren();
							_pageList[i].loadedIndex = -1;
						}					
					}
				}
			}			
		}
		
		private function checkIsVisible(pageIndex:int):Boolean{
			try{
				if(ViewMode == ViewModeEnum.TILE){
					return  _pageList[pageIndex].parent.y + _pageList[pageIndex].height >= _paperContainer.verticalScrollPosition && 
						(_pageList[pageIndex].parent.y - _pageList[pageIndex].height) < (_paperContainer.verticalScrollPosition + _paperContainer.height);
				}
				else if(ViewMode == ViewModeEnum.TWOPAGE){
					return  (_pageList[pageIndex].parent.y + (_pageList[pageIndex].getScaledHeight() + 6)) >= _paperContainer.verticalScrollPosition && 
						(_pageList[pageIndex].parent.y - (_pageList[pageIndex].getScaledHeight() + 6)) < (_paperContainer.verticalScrollPosition + _paperContainer.height);	
				}
				else{
					return  (_pageList[pageIndex].y + (_pageList[pageIndex].getScaledHeight() + 6)) >= _paperContainer.verticalScrollPosition && 
						(_pageList[pageIndex].y - (_pageList[pageIndex].getScaledHeight() + 6)) < (_paperContainer.verticalScrollPosition + _paperContainer.height);
				}
				
				if(UsingExtViewMode)
					return CurrExtViewMode.checkIsVisible(pageIndex);	

			}catch(e:Error){
				return false;	
			}
			return false;
		}		
		
		public function createDisplayContainer():void{
			if(_skinImgDo != null && _skinImgDo.parent == this){
				removeChild(_skinImgDo);
				_skinImgDo.removeEventListener(MouseEvent.MOUSE_OVER,skinMouseOver);
				_skinImgDo.removeEventListener(MouseEvent.MOUSE_OUT,skinMouseOut);
				_skinImgDo.removeEventListener(MouseEvent.MOUSE_DOWN,skinMouseDown);
			}
			
			_skinImgDo = new Image();
			_skinImgDo.source = _skinImg;
			_skinImgDo.x = this.width-_skinImg.width - 27; _skinImgDo.y = this.height-_skinImg.height - 10;
			_skinImgDo.addEventListener(MouseEvent.MOUSE_OVER,skinMouseOver,false,0,true);
			_skinImgDo.addEventListener(MouseEvent.MOUSE_OUT,skinMouseOut,false,0,true);
			_skinImgDo.addEventListener(MouseEvent.MOUSE_DOWN,skinMouseDown,false,0,true);
			_skinImgDo.buttonMode = true;
			addChild(_skinImgDo); 
			
			// Add the swf to the invisible container.
			_swfContainer.removeAllChildren();
			var uic:UIComponent = new UIComponent();
			_swfContainer.addChild(uic);
			uic.addChild(_loader);
			
			if(_paperContainer !=null && _paperContainer.parent == this){
				removeChild(_paperContainer);
				_paperContainer.removeEventListener(FlexEvent.UPDATE_COMPLETE,updComplete);
				
				_paperContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			}
			
			_paperContainer = new ZoomCanvas();
			_paperContainer.percentHeight = 100;
			_paperContainer.percentWidth = 100;
			_paperContainer.addEventListener(FlexEvent.UPDATE_COMPLETE,updComplete,false,0,true);
			_paperContainer.x = (ViewMode==ViewModeEnum.PORTRAIT||ViewMode==ViewModeEnum.TILE)?2.5:0;
			_paperContainer.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler,false,0,true);
			_paperContainer.setStyle("horizontalGap",1);
			_paperContainer.setStyle("verticalGap",0);
			
			addChildAt(_paperContainer,getChildIndex(_skinImgDo)-1);
			
			try{
				new flash.net.LocalConnection().connect('devaldiGCdummy');
				new flash.net.LocalConnection().connect('devaldiGCdummy');
			} catch (e:*) {}
			
			try{flash.system.System.gc();} catch (e:*) {}
			
			if(_paperContainer.numChildren>0){_paperContainer.removeAllChildren();}
			
			deleteDisplayContainer();
			
			if(_viewMode == ViewModeEnum.TILE){
				_displayContainer = new FlowBox();
				_displayContainer.setStyle("horizontalAlign", "left");
				_paperContainer.horizontalScrollPolicy = "off";
				_scale = 0.243;
				_paperContainer.addChild(_displayContainer);
				_paperContainer.childrenDoDrag = true;
				_initialized=true;
			}else if(_viewMode == ViewModeEnum.TWOPAGE){
				_displayContainer = new FlowTwoPage();
				_displayContainer.setStyle("horizontalGap",1);
				_displayContainer.setStyle("verticalGap",800);
				_displayContainer.setStyle("horizontalAlign", "center");
				_displayContainer.setStyle("verticalAlign", "middle");
				_displayContainer.setStyle("paddingLeft", 10);
				_displayContainer.setStyle("paddingTop", 10);
				_displayContainer.setStyle("paddingRight", 10);
				_paperContainer.verticalScrollPolicy = "off";
				_paperContainer.horizontalScrollPolicy = "off";
				_paperContainer.addChild(_displayContainer);
				_paperContainer.childrenDoDrag = false;
				
				if(_libMC!=null)
					reScaleTwoPage();
			}
			else{
				_displayContainer = new FlowVBox();
				_displayContainer.setStyle("horizontalAlign", "center");
				_paperContainer.addChild(_displayContainer);
				_paperContainer.childrenDoDrag = true;
				_initialized=true;
			}
			
			if(UsingExtViewMode)
				_initialized = CurrExtViewMode.initComponent(this);	
			
			_displayContainer.verticalScrollPolicy = "off";
			_displayContainer.horizontalScrollPolicy = "off";	
			_displayContainer.setStyle("verticalAlign", "center");
			_displayContainer.percentHeight = 100;
			_displayContainer.percentWidth = (ViewMode==ViewModeEnum.PORTRAIT)?96:100;
			_displayContainer.useHandCursor = true;
			_displayContainer.addEventListener(MouseEvent.ROLL_OVER,displayContainerrolloverHandler,false,0,true);
			_displayContainer.addEventListener(MouseEvent.ROLL_OUT,displayContainerrolloutHandler,false,0,true);
			_displayContainer.addEventListener(MouseEvent.MOUSE_DOWN,displayContainerMouseDownHandler,false,0,true);
			_displayContainer.addEventListener(MouseEvent.MOUSE_UP,displayContainerMouseUpHandler,false,0,true);
			_displayContainer.addEventListener(MouseEvent.DOUBLE_CLICK,displayContainerDoubleClickHandler,false,0,true);
			//_displayContainer.mouseChildren = false;
			_displayContainer.doubleClickEnabled = true;
		}
		
		public function reScaleTwoPage(resetPadding:Boolean=false):void{
			_displayContainer.setStyle("paddingBottom", (libMC.totalFrames>2)?40:10);
			
			_scale = (((_paperContainer.parent.width - 21) / _libMC.width) / 2) - 0.0020;
			
			if((_libMC.height * _scale + 20 )> _paperContainer.parent.height){
				_scale = (((_paperContainer.parent.height - 20) / _libMC.height));
				_displayContainer.setStyle("paddingLeft", (_paperContainer.parent.width - (_libMC.width * _scale) * 2) / 2);
			}
			
			var _target:DisplayObject;

			_tweencount = _libMC.totalFrames;
			
			for(var i:int=0;i<_displayContainer.numChildren;i++){
				for(var ii:int=0;ii<(_displayContainer.getChildAt(i) as Box).numChildren;ii++){
					_target = (_displayContainer.getChildAt(i) as Box).getChildAt(ii);
					_target.filters = null;
					Tweener.addTween(_target, {scaleX: _scale, scaleY: _scale,time: 0, transition: 'easenone', onComplete: reScaleComplete});
				}
			}
			
			_displayContainer.width = _displayContainer.parent.width;
			
			if(resetPadding){
				_displayContainer.setStyle("paddingLeft", _savePaddingTwoPage);
				_displayContainer.setStyle("paddingRight", 10);
			}else if(_savePaddingTwoPage==-1){
				_savePaddingTwoPage = _displayContainer.getStyle("paddingLeft");
			}
			
			initialized = true;
		}
		
		private function displayContainerrolloverHandler(event:MouseEvent):void{
			
			if(_viewMode==ViewModeEnum.PORTRAIT||(UsingExtViewMode && CurrExtViewMode.supportsTextSelect)){
				if(TextSelectEnabled && CursorsEnabled){
					_grabCursorID = CursorManager.setCursor(textSelectCursor);
				}else if(CursorsEnabled){
					resetCursor();
				}
			}
		}
		
		private function displayContainerMouseUpHandler(event:MouseEvent):void{
			if(_viewMode==ViewModeEnum.PORTRAIT||(UsingExtViewMode && CurrExtViewMode.supportsTextSelect)){
				
				if(CursorsEnabled)
					CursorManager.removeCursor(_grabbingCursorID);
				
				if(TextSelectEnabled && CursorsEnabled){
					_grabCursorID = CursorManager.setCursor(textSelectCursor);
				}else if(CursorsEnabled && !(event.target is IFlexPaperPluginControl) || (event.target.parent !=null && event.target.parent.parent !=null && event.target.parent.parent is IFlexPaperPluginControl)){
					resetCursor();
				}
			}
		}
		
		private function displayContainerDoubleClickHandler(event:MouseEvent):void{
			if(TextSelectEnabled){return;}
			if(ViewMode == ViewModeEnum.PORTRAIT)
				FitMode = (FitMode == FitModeEnum.FITWIDTH)?FitModeEnum.FITHEIGHT:FitModeEnum.FITWIDTH;
			
			if(UsingExtViewMode)
				CurrExtViewMode.handleDoubleClick(event);
		}
		
		private function displayContainerMouseDownHandler(event:MouseEvent):void{
			if(_viewMode==ViewModeEnum.PORTRAIT||(UsingExtViewMode && CurrExtViewMode.supportsTextSelect)){
				
				if(CursorsEnabled)
					CursorManager.removeCursor(_grabCursorID);
				
				if(TextSelectEnabled && CursorsEnabled){
					_grabbingCursorID = CursorManager.setCursor(textSelectCursor);
				}else if(CursorsEnabled){
					_grabbingCursorID = CursorManager.setCursor(grabbingCursor);
				}
			}
		}
		
		private function displayContainerrolloutHandler(event:Event):void{
			if(CursorsEnabled)
				CursorManager.removeAllCursors();
		}		
		
		private function wheelHandler(evt:MouseEvent):void {
			_paperContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			
			var t:Timer = new Timer(1,1);
			t.addEventListener("timer", addMouseScrollListener,false,0,true);
			t.start();
			
			_paperContainer.dispatchEvent(evt.clone());
		}
		
		private function addMouseScrollListener(e:Event):void {
			_paperContainer.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler,false,0,true);
		}		
		
		private function keyboardHandler(event:KeyboardEvent):void{
			if(event.keyCode == Keyboard.DOWN){
				_paperContainer.verticalScrollPosition = _paperContainer.verticalScrollPosition + 10;	
			}
			
			if(event.keyCode == Keyboard.UP){
				_paperContainer.verticalScrollPosition = _paperContainer.verticalScrollPosition - 10;
			}
			
			if(event.keyCode == Keyboard.PAGE_DOWN){
				_paperContainer.verticalScrollPosition = _paperContainer.verticalScrollPosition + 300;  
			}
			if(event.keyCode == Keyboard.PAGE_UP){
				_paperContainer.verticalScrollPosition = _paperContainer.verticalScrollPosition - 300;  
			}
			if(event.keyCode == Keyboard.HOME){
				_paperContainer.verticalScrollPosition = 0;
			}
			if(event.keyCode == Keyboard.END){
				_paperContainer.verticalScrollPosition = _paperContainer.maxVerticalScrollPosition;
			}
		}
		
		private function sizeChanged(evt:Event):void{
			_skinImgDo.source = _skinImg;
			_skinImgDo.x = this.width-_skinImg.width - 27; _skinImgDo.y = this.height-_skinImg.height - 10;
		}
		
		private function skinMouseOver(evt:MouseEvent):void{
			_skinImgDo.addChild(_skinImgc);
		}
	
		private function skinMouseOut(evt:MouseEvent):void{
			if(_skinImgc.parent==_skinImgDo){_skinImgDo.removeChild(_skinImgc);}
		}

		private function skinMouseDown(evt:MouseEvent):void{
			dispatchEvent(new Event("onLogoClicked"));
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_swfFileChanged && _swfFile != null && _swfFile.length > 0){ // handler for when the Swf file has changed.
				
				dispatchEvent(new Event("onDocumentLoading"));
				
				_docLoader = new AVM2Loader(_loader,getExecutionContext(),ProgressiveLoading);
				_docLoader.stream.addEventListener(ProgressEvent.PROGRESS, onLoadProgress,false,0,true);
				_docLoader.load(new URLRequest(_swfFile),getExecutionContext());
				_docLoader.addEventListener("onDocumentLoadedError", onDocumentLoadedErrorHandler,false,0,true);
				
				_swfFileChanged = false;
			}
			
		}
		
		private function resizeMc(mc:MovieClip, maxW:Number, maxH:Number=0, constrainProportions:Boolean=true):void{
			maxH = maxH == 0 ? maxW : maxH;
			mc.width = maxW;
			mc.height = maxH;
			if (constrainProportions) {
				mc.scaleX < mc.scaleY ? mc.scaleY = mc.scaleX : mc.scaleX = mc.scaleY;
			}
		}		
		
		private function onLoadProgress(event:ProgressEvent):void{
			var e:ProgressEvent = new ProgressEvent("onLoadingProgress")
			e.bytesTotal = event.bytesTotal;
			e.bytesLoaded = event.bytesLoaded;
			dispatchEvent(e);
		}
		
		private function onDocumentLoadedErrorHandler(event:Event):void{
			dispatchEvent(event);
		}
				
		private function swfComplete(event:Event):void{
			if(!ProgressiveLoading){
				try{
					if(event.currentTarget.content != null && event.target.content is MovieClip)
						_libMC = event.currentTarget.content as MovieClip;
					DupImage.paperSource = _libMC;
				}catch(e:Error){
					if(!_docLoader.Resigned){_docLoader.resignFileAttributesTag(_docLoader.InputBytes,_loader);return;}
				}
				
				if((_libMC == null || (event.currentTarget!=null && event.currentTarget.content != null && event.currentTarget.content is AVM1Movie)) && !_docLoader.Resigned){_docLoader.resignFileAttributesTag(_docLoader.InputBytes,_loader);return;}

				_inputBytes = _docLoader.InputBytes;
					
				if(_libMC.height>0&&_docLoader.LoaderList==null){createLoaderList();}
				numPages = _libMC.totalFrames;
				_swfLoaded = true
				reCreateAllPages();
				
				_bbusyloading = false;
				repositionPapers();
				//dispatchEvent(new DocumentLoadedEvent(DocumentLoadedEvent.DOCUMENT_LOADED,numPages));
				
			}else{
				if(event.currentTarget.content != null){
					var mobj:Object = event.currentTarget.content;
					var firstLoad:Boolean = false;
					
					if(mobj is AVM1Movie || _loaderptr != null){
						_inputBytes = _loader.contentLoaderInfo.bytes;
						
						if(_loaderptr==null){
							_docLoader.flagSWF9Bit(_inputBytes);
							_loaderptr = new Loader();
							_loaderptr.contentLoaderInfo.addEventListener(Event.COMPLETE, swfComplete,false,0,true);
						}
						
						_docLoader.resignFileAttributesTag(_inputBytes,_loaderptr);
						_loaderptr.loadBytes(_inputBytes);
					}
					
					if(mobj is MovieClip){
						_libMC = mobj as MovieClip;
						if(_libMC.height>0&&_docLoader.LoaderList==null){createLoaderList();}
						DupImage.paperSource = _libMC;
						numPages = _libMC.totalFrames;
						firstLoad = _pageList == null || (_pageList.length == 0 && numPages > 0);
						
						if(_loaderptr==null){_inputBytes = _docLoader.InputBytes;}else{_inputBytes = _loaderptr.contentLoaderInfo.bytes;}
						
						if(_libMC.framesLoaded > 0)
							addInLoadedPages();
						
						if(ViewMode == ViewModeEnum.TWOPAGE && !_initialized){
							reScaleTwoPage();
						}
						
						flash.utils.setTimeout(function():void{
							try{
							var bDocLoaded:Boolean=(_libMC.framesLoaded == _libMC.totalFrames && _frameLoadCount != _libMC.framesLoaded);	
							
							if(_libMC.framesLoaded>_frameLoadCount){
								repositionPapers();
							if(_docLoader.LoaderList.length>0 && (_viewMode == ViewModeEnum.PORTRAIT||_viewMode == ViewModeEnum.TWOPAGE)){_bbusyloading = true; _docLoader.LoaderList[_docLoader.LoaderList.length-1].loadBytes(_libMC.loaderInfo.bytes,getExecutionContext());}
								_frameLoadCount = _libMC.framesLoaded;
							}
							
							if(bDocLoaded)
								dispatchEvent(new DocumentLoadedEvent(DocumentLoadedEvent.DOCUMENT_LOADED,numPages));
							} catch (e:*) {}
						},500);
							
						
						_bbusyloading = false;
						_swfLoaded = true
					}
				}
			}
		}	
		
		private function deleteDisplayContainer():void{
			if(_displayContainer!=null){
				_displayContainer.removeAllChildren();
				_displayContainer.removeEventListener(MouseEvent.ROLL_OVER,displayContainerrolloverHandler);
				_displayContainer.removeEventListener(MouseEvent.ROLL_OUT,displayContainerrolloutHandler);
				_displayContainer.removeEventListener(MouseEvent.MOUSE_DOWN,displayContainerMouseDownHandler);
				_displayContainer.removeEventListener(MouseEvent.MOUSE_UP,displayContainerMouseUpHandler);
				_displayContainer.removeEventListener(MouseEvent.DOUBLE_CLICK,displayContainerDoubleClickHandler);
			}
		}
		
		private function deleteLoaderList():void{
			if(_docLoader==null){return;}
			if(_docLoader.LoaderList!=null){
				for(var i:int=0;i<_docLoader.LoaderList.length;i++){
					if(_docLoader.LoaderList[i].parent!=null){
						_docLoader.LoaderList[i].parent.removeChild(_docLoader.LoaderList[i]);
					}
					
					if(_docLoader.LoaderList[i].contentLoaderInfo!=null){
						_docLoader.LoaderList[i].contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesLoaded);	
					}
					
					_docLoader.LoaderList[i].removeEventListener(Event.ENTER_FRAME,onframeenter);
					_docLoader.LoaderList[i].unloadAndStop(true);
					
					delete(_docLoader.LoaderList[i]);
					_docLoader.LoaderList[i]=null;
				}
			}
			
			_docLoader.LoaderList = null;
		}
		
		public function deleteSelectionMarker():void{
			if(_selectionMarker!=null&&_selectionMarker.parent!=null){
				_selectionMarker.parent.removeChild(_selectionMarker);

				_selectionMarker = null;
			}
		}
		
		private function deleteLibMC():void{
			if(_libMC!=null){
				if(_libMC.parent!=null){
					_libMC.parent.removeChild(_libMC);
				}
				
				_libMC = null;
			}
		}
		
		private function deleteLoaderPtr():void{
			if(_loaderptr!=null){
				if(_loaderptr.parent!=null){
					_loaderptr.removeChild(_loaderptr);
				}
				
				if(_loaderptr.contentLoaderInfo !=null){
					_loaderptr.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfComplete);
				}
				
				_loaderptr.unloadAndStop(true);
				_loaderptr = null;
			}
		}
		
		private function clearPlugins():void{
			if(_pluginList==null){return;}
			
			for(var pl:int=0;pl<_pluginList.length;pl++){
				_pluginList[pl].clear();
			}
		}
		
		private function deletePageList():void{
			if(_pageList!=null){
				for(var pl:int=0;pl<_pageList.length;pl++){

					_pageList[pl].removeEventListener(MouseEvent.MOUSE_OVER,dupImageMoverHandler);
					_pageList[pl].removeEventListener(MouseEvent.MOUSE_OUT,dupImageMoutHandler);
					_pageList[pl].removeEventListener(MouseEvent.CLICK,dupImageClickHandler);
					_pageList[pl].removeEventListener(MouseEvent.MOUSE_DOWN,textSelectorMouseDownHandler);
					
					if(_pageList[pl].parent!=null){
						_pageList[pl].removeAllChildren();
						_pageList[pl].source = null;
						_pageList[pl].parent.removeChild(_pageList[pl]);
					}
					
					delete(_pageList[pl]);
					_pageList[pl]=null;}
			}
			
			DupImage.paperSource = null;
			
			_pageList = null;
		}
		
		private function deleteFLoader():void{
			if(_docLoader!=null){
				_docLoader.stream.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				_docLoader.resetURLStream();
			}
			
			if(_loader!=null){
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfComplete);
				_loader.unloadAndStop(true);
				_loader = null;
			}
			
			_docLoader = null;
			
			_loader = new Loader();
			if(!_loader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfComplete,false,0,true);
		}
		
		public function addInLoadedPages(recreate:Boolean = false):void{
			if(recreate){
				_displayContainer.removeAllChildren(); deletePageList();
			}
			
			if(_pageList==null || (_pageList != null && _pageList.length != numPages)){
				_pageList = new Array(numPages);
				
				_displayContainer.visible = false;
				_libMC.stop();
				
				var w:Number=0; var h:Number=0;
				_libMC.gotoAndStop(1);
				w = _libMC.width; h=_libMC.height;
				
				for(var i:int=0;i<numPages;i++){
					_libMC.gotoAndStop(i+1);
					createPaper(i+1,(_libMC.width>0)?_libMC.width:w,(_libMC.height>0)?_libMC.height:h);
				}		
				
				addPages();
				
				if(_pluginList!=null){
					for(var p:int=0;p<_pluginList.length;p++){
						_pluginList[p].init();
					}
				}
				
				if(_fitWidthOnLoad){_scale = getFitWidthFactor();}
				if(_fitPageOnLoad){_scale = getFitHeightFactor();}
			}	
			
			flash.utils.setTimeout(repositionPapers,500);
		}	
		
		public function reCreateAllPages():void{
			if(!_swfLoaded){return;}
			
			_displayContainer.visible = false;
			_displayContainer.removeAllChildren();
			
			deletePageList();
			_pageList = new Array(numPages);
			
			if(_pluginList!=null){
				for(var p:int=0;p<_pluginList.length;p++){
					_pluginList[p].init();
				}
			}
			
			_libMC.stop();
			
			var w:Number=0; var h:Number=0;
			_libMC.gotoAndStop(1);
			w = _libMC.width; h=_libMC.height;
			
			for(var i:int=0;i<numPages;i++){
				_libMC.gotoAndStop(i+1);
				createPaper(i+1,(_libMC.width>0)?_libMC.width:w,(_libMC.height>0)?_libMC.height:h);
			}		
			
			addPages();
			
			// kick off the first page to load
			if(_docLoader.LoaderList.length>0 && (_viewMode == ViewModeEnum.PORTRAIT||_viewMode == ViewModeEnum.TWOPAGE)){_bbusyloading = true; _docLoader.LoaderList[0].loadBytes(_libMC.loaderInfo.bytes,getExecutionContext());}
			if(_docLoader.LoaderList.length>0 && UsingExtViewMode){CurrExtViewMode.initOnLoading();}
		}	
		
		private function createLoaderList():void
		{
			if(!UsingExtViewMode)
				_docLoader.LoaderList = new Array(Math.round(getCalculatedHeight(_paperContainer)/(_libMC.height*0.1))+1);
			else
				_docLoader.LoaderList = new Array(CurrExtViewMode.loaderListLength);
			
			if(_viewMode == ViewModeEnum.PORTRAIT||_viewMode == ViewModeEnum.TWOPAGE||UsingExtViewMode){
				for(var li:int=0;li<_docLoader.LoaderList.length;li++){
					_docLoader.LoaderList[li] = new DupLoader();
					_docLoader.LoaderList[li].contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoaded,false,0,true);
					_docLoader.LoaderList[li].addEventListener(Event.ENTER_FRAME,onframeenter,false,0,true);
				}
			}			
		}		
		
		private function getCalculatedHeight(obj:DisplayObject):Number{
			var pHeight:Number = 0;
			var oPercHeight:Number = 0;
			
			pHeight = obj.height;
			if(pHeight>0){return pHeight;}
			if((obj as Container).percentHeight>0){oPercHeight=(obj as Container).percentHeight;}
			
			while(obj.parent != null){
				if(obj.parent.height>0){pHeight = obj.parent.height * (oPercHeight/100);break;}
				obj = obj.parent;
			}
			
			return pHeight;
		}
		
		public var snap:TextSnapshot;
		private var searchIndex:int = -1;		
		private var searchPageIndex:int = -1;
		private var _selectionMarker:ShapeMarker;
		private var prevSearchText:String = "";
		private var prevYsave:Number=-1;
		
		public function get SearchPageIndex():int {
			return searchPageIndex;
		}	
		
		public function set SearchPageIndex(s:int):void {
			searchPageIndex = s; 
		}	

		public function searchText(text:String):void{
			if(text==null){return;}
			
			var tri:Array;
			if(text.length==0){return;}
			text = text.toLowerCase();
			
			if(prevSearchText != text){
				searchIndex = -1;
				//searchPageIndex = -1;
				prevSearchText = text;
			}
			
			
			if(_selectionMarker!=null && _selectionMarker.parent != null){_selectionMarker.parent.removeChild(_selectionMarker);}
			
			// start searching from the current page
			if(searchPageIndex == -1){
				searchPageIndex = currPage;
			}else{
				searchIndex = searchIndex + text.length;
			}
			
			_libMC.gotoAndStop(searchPageIndex);
			
			while((searchPageIndex -1) < numPagesLoaded){
				snap = _libMC.textSnapshot;
				searchIndex = snap.findText((searchIndex==-1?0:searchIndex),text,false);
				//searchIndex = TextMapUtil.checkUnicodeIntegrity(snap.getText(0,snap.charCount),text,_libMC).toLowerCase().indexOf(text,(searchIndex==-1?0:searchIndex));
				
				if(searchIndex > 0){ // found a new match
					_selectionMarker = new ShapeMarker();
					_selectionMarker.graphics.beginFill(0x0095f7,0.3);
					
					tri = snap.getTextRunInfo(searchIndex,searchIndex+text.length-1);
					if(tri.length>0){
						prevYsave = tri[0].matrix_ty;
						drawCurrentSelection(0x0095f7,_selectionMarker,tri);
					}
					
					if(prevYsave>0){
						_selectionMarker.graphics.endFill();
						_adjGotoPage = (ViewMode==ViewModeEnum.PORTRAIT)?(prevYsave) * _scale - 50:0;
						gotoPage(searchPageIndex);
						break;
					}
					
				}
				
				searchPageIndex++;
				searchIndex = -1;
				_libMC.gotoAndStop(searchPageIndex);
			}
			
			if(searchIndex == -1){ // searched the end of the doc.
				dispatchEvent(new Event("onNoMoreSearchResults"));
				searchPageIndex = 1;
			}
		}
		
		private function createPaper(index:int, w:Number, h:Number):void {
			var di:DupImage = new DupImage(); 
			di.scaleX = di.scaleY = _scale;
			di.dupIndex = index;
			di.width = w;
			di.height = h;
			//di.mouseChildren = false;
			di.addEventListener(MouseEvent.MOUSE_OVER,dupImageMoverHandler,false,0,true);
			di.addEventListener(MouseEvent.MOUSE_OUT,dupImageMoutHandler,false,0,true);
			di.addEventListener(MouseEvent.CLICK,dupImageClickHandler,false,0,true);
			di.addEventListener(MouseEvent.MOUSE_DOWN,textSelectorMouseDownHandler,false,0,true);
			
			if(_pluginList!=null)
				for(var pl:int=0;pl<_pluginList.length;pl++)
					_pluginList[pl].bindPaperEventHandler(di);	

			_pageList[index-1] = di;
		}	
		
		private function textSelectorMouseDownHandler(event:MouseEvent):void{
			if(!TextSelectEnabled){return;}
			if(_selectionMarker!=null&&_selectionMarker.parent!=null){_selectionMarker.parent.removeChild(_selectionMarker);_selectionMarker=null;}
			
			try{if(!(event.target.content is MovieClip)){return;}}catch (e:*) {return;}
			
			_currentlySelectedText = "";
			_firstHitIndex = -1;
			_lastHitIndex = -1;
			_currentSelectionPage = -1;
			_selectionMc = (event.target.content as MovieClip);
			snap = _selectionMc.textSnapshot;
						
			systemManager.addEventListener(
				MouseEvent.MOUSE_MOVE, textSelectorMoveHandler, true,0,true);
			
			systemManager.addEventListener(
				MouseEvent.MOUSE_UP, textSelectorMouseUpHandler, true,0,true);
			
			systemManager.stage.removeEventListener(
				Event.MOUSE_LEAVE, textSelectorMouseLeaveHandler);
		}
		
		private var _firstHitIndex:int = -1;
		private var _lastHitIndex:int = -1;
		private var _currentlySelectedText:String = "";
		private var _tri:Array;
		private var _currentSelectionPage:int = -1;
		private var _selectionMc:MovieClip
		private var _selecting:Boolean = false;
		public static var DefaultMarkerColor:uint = 0xb5deff;
		private var _markerColor:uint = 0xb5deff;
		public static var DefaultSelectionColor:uint = 0x0095f7;
		private var _selectionColor:uint = 0x0095f7;
		
		public function get MarkerColor():uint {
			return _markerColor;
		}
		
		public function set MarkerColor(c:uint):void {
			_markerColor = c;
		}
		
		public function get SelectionColor():uint {
			return _selectionColor;
		}
		
		public function set SelectionColor(c:uint):void {
			_selectionColor = c;
		}
		
		public function get CurrentSelectionPage():int {
			return _currentSelectionPage;
		}

		public function get FirstHitIndex():int {
			return _firstHitIndex;
		}	
		
		public function get LastHitIndex():int {
			return _lastHitIndex;
		}	

		public function get TextRunInfo():Array {
			return _tri;
		}	
		
		public function set TextRunInfo(a:Array):void {
			_tri = a;
		}
		
		private function textSelectorMoveHandler(event:MouseEvent):void{
			event.stopImmediatePropagation();
			
			var hitIndex:int = snap.hitTestTextNearPos(event.target.parent.mouseX,event.target.parent.mouseY,10)+((_firstHitIndex==-1)?0:1);
			
			if(hitIndex==_lastHitIndex||hitIndex<0){return;}
			if(!(event.target is DupLoader)){return;}
			
			if(_firstHitIndex==-1){_firstHitIndex=hitIndex;}
			_currentSelectionPage = _selectionMc.currentFrame;
			
			snap.setSelectColor(_markerColor);
			snap.setSelected(0,snap.charCount,false);
			
			if(_firstHitIndex<=hitIndex){	
				snap.setSelected(_firstHitIndex,hitIndex,true);
			}else{
				snap.setSelected(hitIndex,_firstHitIndex,true);
			}
			
			if(_selectionMarker!=null&&_selectionMarker.parent!=null){_selectionMarker.parent.removeChild(_selectionMarker);}
			
			searchPageIndex = _selectionMc.currentFrame;
			_lastHitIndex = hitIndex;
		}
		
		public function drawCurrentSelection(color:uint, shape:Sprite, tri:Array, strikeout:Boolean=false):void{
			var ly:Number=-1;
			var li:int;var lx:int;
			var miny:int=-1;
			var minx:int=-1;
			var maxy:int=-1;
			var maxx:int=-1;
			snap.setSelected(1,snap.charCount,false);
			
			shape.graphics.beginFill(color,(strikeout)?0.5:0.3);
			var rect_commands:Vector.<int>;
			rect_commands = new Vector.<int>((tri.length) * 5, true);
			
			var rect_coords:Vector.<Number>;
			rect_coords = new Vector.<Number>((tri.length) * 10, true);
			
			for(var i:int=0;i<tri.length-1;i++){
				if(miny==-1||miny>tri[i].corner1y){miny=tri[i].corner1y;}
				if(minx==-1||minx>tri[li].corner3x){minx=tri[li].corner3x;}
				if(maxy==-1||maxy<tri[i].corner3y){maxy=tri[i].corner3y;}
				if(maxx==-1||maxx<tri[i].corner1x){maxx=tri[i].corner1x;}
				
				if(ly==-1){ly=tri[i].corner1y;li=0;}
				
				rect_commands[i*5] = 1;
				rect_commands[i*5 + 1] = 2;
				rect_commands[i*5 + 2] = 2;
				rect_commands[i*5 + 3] = 2;
				rect_commands[i*5 + 4] = 2;

				rect_coords[i*10] = tri[li].corner3x;
				rect_coords[i*10 + 1] = tri[i].corner1y + (strikeout?(tri[i].corner3y-tri[i].corner1y)/3:0);
				
				rect_coords[i*10 + 5] = rect_coords[i*10 + 1] + (tri[i].corner3y-tri[i].corner1y) / ((strikeout)?5:1); //h
				
				if(i!=tri.length-2 && tri[i].corner1x>tri[li].corner3x)
					rect_coords[i*10 + 2] = rect_coords[i * 10] + tri[i].corner1x-tri[li].corner3x;
				else if(i==tri.length-2 && tri[i+1].corner1x > tri[li].corner3x)
					rect_coords[i*10 + 2] = rect_coords[i * 10] + tri[i+1].corner1x-tri[li].corner3x;
				else if(i==tri.length-2 && tri[i+1].corner1x < tri[li].corner3x){
					rect_coords[i*10 + 2] = rect_coords[i * 10] + tri[li].corner1x-tri[li].corner3x;
					rect_coords[i*10] = tri[li].corner3x;	
					
					/* add an extra struct for the last char*/
					rect_commands[(i+1)*5] = 1;
					rect_commands[(i+1)*5 + 1] = 2;
					rect_commands[(i+1)*5 + 2] = 2;
					rect_commands[(i+1)*5 + 3] = 2;
					rect_commands[(i+1)*5 + 4] = 2;
					
					rect_coords[(i+1)*10] = tri[(i+1)].corner3x;
					rect_coords[(i+1)*10 + 1] = tri[(i+1)].corner1y;
					rect_coords[(i+1)*10 + 2] = rect_coords[(i+1) * 10] + tri[i+1].corner1x-tri[i+1].corner3x;
					rect_coords[(i+1)*10 + 3] = rect_coords[(i+1)*10 + 1];
					rect_coords[(i+1)*10 + 4] = rect_coords[(i+1)*10 + 2];
					rect_coords[(i+1)*10 + 5] = rect_coords[(i+1)*10 + 1] + tri[i+1].corner3y-tri[i+1].corner1y;
					rect_coords[(i+1)*10 + 6] = rect_coords[(i+1)*10];
					rect_coords[(i+1)*10 + 7] = rect_coords[(i+1)*10 + 5];
					rect_coords[(i+1)*10 + 8] = rect_coords[(i+1)*10];
					rect_coords[(i+1)*10 + 9] = rect_coords[(i+1)*10 + 1]; 
				}
					
				rect_coords[i*10 + 3] = rect_coords[i*10 + 1]; 
				rect_coords[i*10 + 4] = rect_coords[i*10 + 2];
				rect_coords[i*10 + 6] = rect_coords[i*10];
				rect_coords[i*10 + 7] = rect_coords[i*10 + 5];
				rect_coords[i*10 + 8] = rect_coords[i*10];
				rect_coords[i*10 + 9] = rect_coords[i*10 + 1];
				
				ly=tri[i+1].corner1y;lx=tri[i+1].corner3x;li=i+1;
			}
			shape.graphics.drawPath(rect_commands,rect_coords,"nonZero");
			shape.graphics.endFill();
			
			// draw a transparent box covering the whole area to increase hitTest accuracy on mousedown
			shape.graphics.beginFill(0xffffff,0);
			shape.graphics.drawRect(minx,miny,maxx-minx,maxy-miny);
			shape.graphics.endFill();
		}
		
		private function textSelectorMouseUpHandler(event:MouseEvent):void{
			stopSelecting();	
		}
		
		private function textSelectorMouseLeaveHandler(event:MouseEvent):void{
			stopSelecting();	
		}
		
		private function stopSelecting():void{		
			systemManager.removeEventListener(
				MouseEvent.MOUSE_MOVE, textSelectorMoveHandler, true);
			
			systemManager.removeEventListener(
				MouseEvent.MOUSE_UP, textSelectorMouseUpHandler, true);
			
			systemManager.stage.removeEventListener(
				Event.MOUSE_LEAVE, textSelectorMouseLeaveHandler);
			
			var rev:int;
			if(_firstHitIndex>_lastHitIndex){rev=_firstHitIndex;_firstHitIndex=_lastHitIndex;_lastHitIndex=rev;}
			
			//var totaltext:String = snap.getText(0,snap.charCount,false);
			
			if(_firstHitIndex>=0 && _lastHitIndex>0)
				_currentlySelectedText = snap.getText(_firstHitIndex,_lastHitIndex-1,false);
			else
				_currentlySelectedText = "";
			
			
			if(_currentlySelectedText.length==0 && _firstHitIndex>=0 && _lastHitIndex>0){
				_currentlySelectedText = snap.getText(_firstHitIndex,_lastHitIndex-1,true);
			}
			
			_currentlySelectedText = TextMapUtil.checkUnicodeIntegrity(_currentlySelectedText,null,_libMC);
			
			/* trace(_currentlySelectedText.charCodeAt(0)+"|");
			trace(_currentlySelectedText.charCodeAt(1)+"|");
			trace(_currentlySelectedText.charCodeAt(2)+"|");
			trace(_currentlySelectedText.charCodeAt(3)+"|"); 
			*/
			

			_tri = snap.getTextRunInfo(_firstHitIndex,_lastHitIndex-1);
			
			if(_currentSelectionPage>0){
				if(_selectionMarker!=null&&_selectionMarker.parent!=null){_selectionMarker.parent.removeChild(_selectionMarker);}
				
				_selectionMarker = new ShapeMarker();
				_selectionMarker.PageIndex = _currentSelectionPage;
				drawCurrentSelection(_selectionColor,_selectionMarker,_tri);
				snap.setSelected(_firstHitIndex,_lastHitIndex,false);
				_pageList[_currentSelectionPage-1].addChildAt(_selectionMarker,_pageList[_selectionMc.currentFrame-1].numChildren);
			}
			
			dispatchEvent(new SelectionCreatedEvent(SelectionCreatedEvent.SELECTION_CREATED,_currentlySelectedText));

			_selectionMc = null;
		}
		
		private function dupImageClickHandler(event:MouseEvent):void{
			stage.stageFocusRect = false;
			stage.focus = event.target as InteractiveObject;
			
			if((_viewMode == ViewModeEnum.TILE) && event.target != null && event.target is DupImage){
				ViewMode = 'Portrait';
				_scrollToPage = (event.target as DupImage).dupIndex;
			}else{
				_dupImageClicked = true;
				var t:Timer = new Timer(100,1);
				t.addEventListener("timer", resetClickHandler,false,0,true);
				t.start();				
				
				if(event.target is SimpleButton && (event.target as SimpleButton).name.indexOf("http")>=0){
					dispatchEvent(new ExternalLinkClickedEvent(ExternalLinkClickedEvent.EXTERNALLINK_CLICKED,
								 (event.target as SimpleButton).name.substring((event.target as SimpleButton).name.indexOf("http"))));	
				}else if(event.target is SimpleButton && (event.target as SimpleButton).name.indexOf("url:")>=0){
					dispatchEvent(new ExternalLinkClickedEvent(ExternalLinkClickedEvent.EXTERNALLINK_CLICKED,
						(event.target as SimpleButton).name.substring((event.target as SimpleButton).name.indexOf("url:"))));	
				}

			}
		}
		
		private function resetClickHandler(e:Event):void {
			_dupImageClicked = false;
		}
		
		private function dupImageMoverHandler(event:MouseEvent):void{
			
			if(_viewMode == ViewModeEnum.TILE && event.target != null && event.target is DupImage){
				addGlowFilter(event.target as DupImage);
			}else{
				if(event.target is flash.display.SimpleButton || event.target is SpriteAsset || (event.target is IFlexPaperPluginControl) || (event.target.parent !=null && event.target.parent.parent !=null && event.target.parent.parent is IFlexPaperPluginControl)){
					CursorManager.removeAllCursors();
				}else{
					if(TextSelectEnabled && CursorsEnabled){
						_grabCursorID = CursorManager.setCursor(textSelectCursor);	
					}else if(CursorsEnabled){
						resetCursor();
					}
				}
			}
		}
		
		public function resetCursor():void{
			if(CursorsEnabled)
				_grabCursorID = CursorManager.setCursor(grabCursor);
		}
		
		private function dupImageMoutHandler(event:MouseEvent):void{
			if(_viewMode == ViewModeEnum.TILE && event.target != null && event.target is DupImage){
				(event.target as DupImage).filters = null;
				(event.target as DupImage).addDropShadow();
			}
		}
		
		private function addPages():void{
			for(var pi:int=0;pi<_pageList.length;pi++){
				if(!UsingExtViewMode)
					_displayContainer.addChild(_pageList[pi]);
				else
					CurrExtViewMode.addChild(pi,_pageList[pi]);
			}
		}
		
		public function printPaper():void{
			if(_libMC.parent is DupImage){(_swfContainer.getChildAt(0) as UIComponent).addChild(_libMC);}
			_libMC.alpha = 1;
			
			var pj:PrintJob = new PrintJob();
			if(pj.start()){
				_libMC.stop();
				
				if((pj.pageHeight/_libMC.height) < 1 && (pj.pageHeight/_libMC.height) < (pj.pageWidth/_libMC.width))
					_libMC.scaleX = _libMC.scaleY = (pj.pageHeight/_libMC.height);
				else if((pj.pageWidth/_libMC.width) < 1)
					_libMC.scaleX = _libMC.scaleY = (pj.pageWidth/_libMC.width);
				
				var options:PrintJobOptions = new PrintJobOptions();
				//options.printAsBitmap = true;
				
				var i:int=0;
				_libMC.gotoAndStop(i+1);
				while(_libMC.totalFrames > _libMC.currentFrame){
					if(_libMC.currentFrame==i+1){
						pj.addPage(_swfContainer,null,options);
						i++;
					}
					
					_libMC.gotoAndStop(_libMC.currentFrame+1);
				}
				pj.addPage(_swfContainer,null,options);
				pj.send();
			}
			
			_libMC.scaleX = _libMC.scaleY = 1;
			_libMC.alpha = 0;
			
			dispatchEvent(new DocumentPrintedEvent(DocumentPrintedEvent.DOCUMENT_PRINTED));
		}
		
		public function printPaperRange(range:String):void{
			if(_libMC.parent is DupImage){(_swfContainer.getChildAt(0) as UIComponent).addChild(_libMC);}
			_libMC.alpha = 1;
			
			var pageNumList:Array = new Array();
			
			if(range == "Current"){
				pageNumList[currPage] = true;
			}else{
				var splitPageNumList:Array = range.split(",");
				for(var i:int=0;i<splitPageNumList.length;i++){
					if(splitPageNumList[i].toString().indexOf("-")>-1){
						var rs:int = Number(splitPageNumList[i].toString().substr(0,splitPageNumList[i].toString().indexOf("-")));
						var re:int = Number(splitPageNumList[i].toString().substr(splitPageNumList[i].toString().indexOf("-")+1));
						for(var irs:int=rs;irs<re+1;irs++){
							pageNumList[irs] = true;
						}
					}else{
						pageNumList[int(Number(splitPageNumList[i].toString()))] = true;
					}
				}
			}
			
			var pj:PrintJob = new PrintJob();
			var options:PrintJobOptions = new PrintJobOptions();
			//options.printAsBitmap = true;
			
			if(pj.start()){
				_libMC.stop();
				
				if((pj.pageHeight/_libMC.height) < 1 && (pj.pageHeight/_libMC.height) < (pj.pageWidth/_libMC.width))
					_libMC.scaleX = _libMC.scaleY = (pj.pageHeight/_libMC.height);
				else if((pj.pageWidth/_libMC.width) < 1)
					_libMC.scaleX = _libMC.scaleY = (pj.pageWidth/_libMC.width);
				
				
				var i:int=0;
				_libMC.gotoAndStop(i+1);
				while(_libMC.totalFrames > _libMC.currentFrame){
					if(_libMC.currentFrame==i+1){
						if(pageNumList[i+1] != null)
							pj.addPage(_swfContainer,null,options);
						
						i++;
					}
					
					_libMC.gotoAndStop(_libMC.currentFrame+1);
				}
				
				if(pageNumList[_libMC.totalFrames] != null)
					pj.addPage(_swfContainer,null,options);
				
				pj.send();
				
			}
			
			_libMC.scaleX = _libMC.scaleY = 1;
			_libMC.alpha = 0;
			
			dispatchEvent(new DocumentPrintedEvent(DocumentPrintedEvent.DOCUMENT_PRINTED));
		}
		
		private function addGlowFilter(img:Image):void{
			var filter : flash.filters.GlowFilter = new flash.filters.GlowFilter(0x111111, 1, 5, 5, 2, 1, false, false);
			img.filters = [ filter ];   
		}
		
		
		private function addDropShadow(img:Image):void
		{
			var filter : DropShadowFilter = new DropShadowFilter();
			filter.blurX = 4;
			filter.blurY = 4;
			filter.quality = 2;
			filter.alpha = 0.5;
			filter.angle = 45;
			filter.color = 0x202020;
			filter.distance = 6;
			filter.inner = false;
			img.filters = [ filter ];           
		}	
		
		public function getExecutionContext():LoaderContext{
			if(loaderCtx == null){
				loaderCtx = new LoaderContext();
				loaderCtx.applicationDomain = ApplicationDomain.currentDomain;
				
				if(loaderCtx.hasOwnProperty("allowLoadBytesCodeExecution")){
					loaderCtx["allowLoadBytesCodeExecution"] = true;
				}
				
			}
			return loaderCtx; 
		}
				
	}
}