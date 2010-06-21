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
	import com.devaldi.controls.FlowVBox;
	import com.devaldi.controls.ZoomCanvas;
	import com.devaldi.streaming.AVM2Loader;
	import com.devaldi.streaming.DupImage;
	import com.devaldi.streaming.DupLoader;
	
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextSnapshot;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	[Event(name="onPapersLoaded", type="flash.events.Event")]
	[Event(name="onPapersLoading", type="flash.events.Event")]
	[Event(name="onNoMoreSearchResults", type="flash.events.Event")]
	[Event(name="onLoadingProgress", type="flash.events.ProgressEvent")]
	[Event(name="onScaleChanged", type="flash.events.Event")]
	
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
		private var _loaderList:Array;
		private var _zoomtransition:String = "easeOut";
		private var _zoomtime:Number = 0.6; 
		private var _fitPageOnLoad:Boolean = false;
		private var _fitWidthOnLoad:Boolean = false;
		private var _dupImageClicked:Boolean = false;
		private var _fLoader:AVM2Loader;
		private var _progressiveLoading:Boolean = false;
		private var _repaintTimer:Timer;
		private var _frameLoadCount:int = 0;
		private var loaderCtx:LoaderContext;
		private var _adjGotoPage:int = 0;
		private var _zoomInterval:Number = 0;
		private var _inputBytes:ByteArray;
		private var _textSelectEnabled:Boolean = false;
		
		[Embed(source="/../assets/grab.gif")]
		public var grabCursor:Class;	  
		
		[Embed(source="/../assets/grabbing.gif")]
		public var grabbingCursor:Class;	  	 
		
		[Embed(source="/../assets/textselectcursor.gif")]
		public var textSelectCursor:Class;	  	 
		
		private var grabCursorID:Number = 0;
		private var grabbingCursorID:Number = 0;
		
		public function Viewer(){
			super();
		}
		
		public function get BusyLoading():Boolean {
			return _bbusyloading;
		}	
		
		[Bindable]
		public function get ViewMode():String {
			return _viewMode;
		}	
		
		[Bindable]
		public function get FitMode():String {
			return _fitMode;
		}	
		
		public function set ViewMode(s:String):void {
			if(s!=_viewMode){
				_viewMode = s;
				if(_viewMode == ViewModeEnum.TILE){_pscale = _scale; _scale = 0.23;_paperContainer.verticalScrollPosition = 0;_fitMode = FitModeEnum.FITNONE;}else{_scale = _pscale;}
				if(_initialized && _swfLoaded){createDisplayContainer();if(this._progressiveLoading){this.addInLoadedPages(true);}else{reCreateAllPages();}_displayContainer.visible = true;}
			}
		}
		
		public function set FitMode(s:String):void {
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
		}
		
		[Bindable]
		public function get TextSelectEnabled():Boolean {
			return _textSelectEnabled;
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
		
		public function gotoPage(p:Number):void{
			if(p<1 || p-1 >_pageList.length)
				return;
			else{
				_paperContainer.verticalScrollPosition = _pageList[p-1].y-1 + _adjGotoPage;
				_adjGotoPage = 0;
				repositionPapers();
			}
		}
		
		public function switchMode():void{
			if(ViewMode == ViewModeEnum.PORTRAIT){ViewMode = ViewModeEnum.TILE;}
			else if(ViewMode == ViewModeEnum.TILE){_scale = _pscale; ViewMode = ViewModeEnum.PORTRAIT;}
		}
		
		public function get SwfFile():String {
			return _swfFile;
		}	
		
		public function set SwfFile(s:String):void {
			if(s.length!=0){
				
				if(_loaderptr!=null){if(_loaderptr.parent!=null){_loaderptr.removeChild(_loaderptr);}_loaderptr.unload();_loaderptr = null;}
				if(_loaderList!=null){for(var i:int=0;i<_loaderList.length;i++){_loaderList[i].unload();if(_loaderList[i].parent!=null){_loaderList[i].parent.removeChild(_loaderList[i]);}delete(_loaderList[i]);_loaderList[i]=null;}}_loaderList = null;
				if(_displayContainer!=null){_displayContainer.removeAllChildren();} 
				if(_pageList!=null){for(var pl:int=0;pl<_pageList.length;pl++){if(_pageList[pl].parent!=null){_pageList[pl].parent.removeChild(_pageList[pl]);_pageList[pl].removeAllChildren();_pageList[pl].source = null;}delete(_pageList[pl]);_pageList[pl]=null;}}
				if(_loader!=null){_loader.unload();}_fLoader = null;
				if(s!=_swfFile&&_libMC!=null){if(_libMC.parent!=null){_libMC.parent.removeChild(_libMC);}_libMC = null;_loader.unload();}
				
				_swfFileChanged = true;
				_swfFile = s;
				
				try{
					new flash.net.LocalConnection().connect('devaldiGCdummy');
					new flash.net.LocalConnection().connect('devaldiGCdummy');
				} catch (e:*) {}
				
				try{flash.system.System.gc();} catch (e:*) {}
			}
			
			_pageList = null;
			_paperContainer.verticalScrollPosition = 0;
			createDisplayContainer();
			
			// Changing the SWF file causes the component to invalidate.
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();			 
		}
		
		[Bindable]
		public function get Scale():String {
			return _scale.toString();
		}				
		
		public function Zoom(factor:Number):void{
			if(factor<0.10 || factor>5 || factor == _scale)
				return;
			
			if(_viewMode != ViewModeEnum.PORTRAIT){return;}
			
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
			
			dispatchEvent(new Event("onScaleChanged"));
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
			
			for(var i:int=0;i<_displayContainer.numChildren;i++){
				_target = _displayContainer.getChildAt(i);
				_target.filters = null;
				Tweener.addTween(_target, {scaleX:factor, scaleY:factor,time: 0, transition: 'easenone', onComplete: tweenComplete});
			}
			
			_fitMode = FitModeEnum.FITWIDTH;
			
			dispatchEvent(new Event("onScaleChanged"));
		}
		
		public function fitHeight():void{
			if(_displayContainer.numChildren == 0){return;}
			
			var _target:DisplayObject;
			_paperContainer.CenteringEnabled = (_paperContainer.height>0);
			var factor:Number = getFitHeightFactor(); 
			_scale = factor;
			
			for(var i:int=0;i<_displayContainer.numChildren;i++){
				_target = _displayContainer.getChildAt(i);
				_target.filters = null;
				Tweener.addTween(_target, {scaleX:factor, scaleY:factor,time: 0, transition: 'easenone', onComplete: tweenComplete});
			}			
			
			_fitMode = FitModeEnum.FITHEIGHT;
			
			dispatchEvent(new Event("onScaleChanged"));
		}
		
		private function tweenComplete():void{
			_tweencount--;
						
			if(_tweencount==0){
				repositionPapers();
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
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfComplete);
			addEventListener(Event.RESIZE, sizeChanged);
			systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			
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
				if(event.target.parent is DupImage && 
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
			if(!ProgressiveLoading){
				for(var i:int=0;i<_loaderList.length;i++){
					if(!_loaderList[i].loaded){
						_loaderList[i].loadBytes(_inputBytes,getExecutionContext());
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
			}			
		}
		
		
		private function repositionPapers():void{
			if(_loaderList==null||_libMC.framesLoaded==0){return;}
			
			{
				var loaderidx:int=0;
				var bFoundFirst:Boolean = false;
				var _thumb:Bitmap;
				var _thumbData:BitmapData;
				var uloaderidx:int=0;
				
				
				for(var i:int=0;i<_pageList.length;i++){
					if(!bFoundFirst)
					{
						var perH:int=0;
						if(_pageList.length>1)
						{
							perH=_pageList[1].y-_pageList[0].y;
							var nowP:Number=_paperContainer.verticalScrollPosition/(perH);
							if(0<nowP<0.5)
								currPage = 1;
							else if(nowP>=(_pageList.length-0.5)&&nowP<=_pageList.length)
								currPage=_pageList.length;
							else{
								
								currPage =Math.round(nowP)+1;
								if(_paperContainer.verticalScrollPosition<_pageList[currPage-1].y){
									currPage-=1;
								}
							}
							bFoundFirst = true;
						}
						else
						{
							bFoundFirst = true;
							currPage = 1;
						}
					}
										
					if(checkIsVisible(i)){
						if(_pageList[i].numChildren<4){
							if(ViewMode == ViewModeEnum.PORTRAIT){ 		
								uloaderidx = (i==_pageList.length-1&&loaderidx+3<_loaderList.length)?loaderidx+3:(loaderidx<_loaderList.length)?loaderidx:0;									
								
								if(!_bbusyloading && _loaderList!=null && _loaderList.length>0 && _viewMode == ViewModeEnum.PORTRAIT){
									if(_libMC!=null&&_libMC.framesLoaded>=_pageList[i].dupIndex && _loaderList[uloaderidx] != null && _loaderList[uloaderidx].content==null||(_loaderList[uloaderidx].content!=null&&_loaderList[uloaderidx].content.framesLoaded<_pageList[i].dupIndex)){
										_bbusyloading = true;
										_loaderList[uloaderidx].loadBytes(_inputBytes,getExecutionContext());
										flash.utils.setTimeout(repositionPapers,200);
									}
								}
								
								
								if((i<2||_pageList[i].numChildren==0||(_pageList[i]!=null&&_loaderList[uloaderidx]!=null&&_loaderList[uloaderidx].content!=null&&_loaderList[uloaderidx].content.currentFrame!=_pageList[i].dupIndex))
									&& _loaderList[uloaderidx] != null && _loaderList[uloaderidx].content != null){
									if(_libMC.framesLoaded >= _pageList[i].dupIndex){
										_loaderList[uloaderidx].content.gotoAndStop(_pageList[i].dupIndex);
										_pageList[i].addChild(_loaderList[uloaderidx]);
										
										_pageList[i].loadedIndex = _pageList[i].dupIndex;
									}
									
								}
							} else if(ViewMode == ViewModeEnum.TILE && _pageList[i].source == null && _libMC.framesLoaded >= _pageList[i].dupIndex){
								_libMC.gotoAndStop(_pageList[i].dupIndex);
								_thumbData = new BitmapData(_libMC.width*_scale, _libMC.height*_scale, false, 0xFFFFFF);
								_thumb = new Bitmap(_thumbData);
								_pageList[i].source = _thumb;
								_thumbData.draw(_libMC,new Matrix(_scale, 0, 0, _scale),null,null,null,true);
							}
							
							
						}
						
						if(_viewMode != ViewModeEnum.TILE && _selectionMarker != null){
							if(i+1 == searchPageIndex && _selectionMarker.parent != _pageList[i]){
								_pageList[i].addChildAt(_selectionMarker,_pageList[i].numChildren);
							}else if(i+1 == searchPageIndex && _selectionMarker.parent == _pageList[i]){
								_pageList[i].setChildIndex(_selectionMarker,_pageList[i].numChildren -1);
							}
						}
						
						loaderidx++;
					}else{
						if(_pageList[i].numChildren>0 || _pageList[i].source != null){
							_pageList[i].source = null;
							//_pageList[i].removeAllChildren();
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
				}else{
					return  ((pageIndex + 1) * (_pageList[pageIndex].getScaledHeight() + 6)) >= _paperContainer.verticalScrollPosition && 
						((pageIndex) * (_pageList[pageIndex].getScaledHeight() + 6)) < (_paperContainer.verticalScrollPosition + _paperContainer.height);
				}
			}catch(e:Error){
				return false;	
			}
			return false;
		}		
		
		private function createDisplayContainer():void{
			
			// Add the swf to the invisible container.
			_swfContainer.removeAllChildren();
			var uic:UIComponent = new UIComponent();
			_swfContainer.addChild(uic);
			uic.addChild(_loader);
			
			_paperContainer = new ZoomCanvas();
			_paperContainer.percentHeight = 100;
			_paperContainer.percentWidth = 100;
			_paperContainer.addEventListener(FlexEvent.UPDATE_COMPLETE,updComplete);
			_paperContainer.x = 2.5;
			_paperContainer.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			
			this.addChild(_paperContainer);				
			
			try{
				new flash.net.LocalConnection().connect('devaldiGCdummy');
				new flash.net.LocalConnection().connect('devaldiGCdummy');
			} catch (e:*) {}
			
			try{flash.system.System.gc();} catch (e:*) {}
			
			if(_paperContainer.numChildren>0){_paperContainer.removeAllChildren();}
			if(_displayContainer!=null){_displayContainer.removeAllChildren();}
			
			if(_viewMode == ViewModeEnum.TILE){
				_displayContainer = new FlowBox();
				_displayContainer.setStyle("horizontalAlign", "left");
				_scale = 0.243;
				_paperContainer.addChild(_displayContainer);
			}else{
				_displayContainer = new FlowVBox();
				_displayContainer.setStyle("horizontalAlign", "center");
				_paperContainer.addChild(_displayContainer);
			}
			_displayContainer.setStyle("verticalAlign", "center");
			_displayContainer.percentHeight = 100;
			_displayContainer.percentWidth = 96;
			_displayContainer.useHandCursor = true;
			_displayContainer.addEventListener(MouseEvent.ROLL_OVER,displayContainerrolloverHandler);
			_displayContainer.addEventListener(MouseEvent.ROLL_OUT,displayContainerrolloutHandler);
			_displayContainer.addEventListener(MouseEvent.MOUSE_DOWN,displayContainerMouseDownHandler);
			_displayContainer.addEventListener(MouseEvent.MOUSE_UP,displayContainerMouseUpHandler);
			_displayContainer.addEventListener(MouseEvent.DOUBLE_CLICK,displayContainerDoubleClickHandler);
			_displayContainer.doubleClickEnabled = true;
			
			_initialized=true;
			
		}
		
		private function displayContainerrolloverHandler(event:MouseEvent):void{
			if(_viewMode == ViewModeEnum.PORTRAIT){
				if(TextSelectEnabled){
					grabCursorID = CursorManager.setCursor(textSelectCursor);
				}else{
					grabCursorID = CursorManager.setCursor(grabCursor);
				}
			}
		}
		
		private function displayContainerMouseUpHandler(event:MouseEvent):void{
			if(_viewMode == ViewModeEnum.PORTRAIT){
				CursorManager.removeCursor(grabbingCursorID);
				if(TextSelectEnabled){
					grabCursorID = CursorManager.setCursor(textSelectCursor);
				}else{
					grabCursorID = CursorManager.setCursor(grabCursor);
				}
			}
		}
		
		private function displayContainerDoubleClickHandler(event:MouseEvent):void{
			if(TextSelectEnabled){return;}
			
			FitMode = (FitMode == FitModeEnum.FITWIDTH)?FitModeEnum.FITHEIGHT:FitModeEnum.FITWIDTH; 
		}
		
		private function displayContainerMouseDownHandler(event:MouseEvent):void{
			if(_viewMode == ViewModeEnum.PORTRAIT){
				CursorManager.removeCursor(grabCursorID);
				if(TextSelectEnabled){
					grabbingCursorID = CursorManager.setCursor(textSelectCursor);
				}else{
					grabbingCursorID = CursorManager.setCursor(grabbingCursor);
				}
			}
		}
		
		private function displayContainerrolloutHandler(event:Event):void{
			CursorManager.removeAllCursors();
		}		
		
		private function wheelHandler(evt:MouseEvent):void {
			_paperContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			
			var t:Timer = new Timer(1,1);
			t.addEventListener("timer", addMouseScrollListener);
			t.start();
			
			_paperContainer.dispatchEvent(evt.clone());
		}
		
		private function addMouseScrollListener(e:Event):void {
			_paperContainer.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
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
			/*if(event.keyCode == Keyboard.SPACE && stage.displayState == StageDisplayState.FULL_SCREEN){
			_paperContainer.verticalScrollPosition = _paperContainer.verticalScrollPosition + 300;
			}*/
		}
		
		private function sizeChanged(evt:Event):void{
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_swfFileChanged && _swfFile != null && _swfFile.length > 0){ // handler for when the Swf file has changed.
				
				dispatchEvent(new Event("onPapersLoading"));
				
				_fLoader = new AVM2Loader(_loader,getExecutionContext(),ProgressiveLoading);
				_fLoader.stream.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				_fLoader.load(new URLRequest(_swfFile),getExecutionContext());
				
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
		
		private function swfComplete(event:Event):void{
			if(!ProgressiveLoading){
				try{
					if(event.currentTarget.content != null && event.target.content is MovieClip)
						_libMC = event.currentTarget.content as MovieClip;
					DupImage.paperSource = _libMC;
				}catch(e:Error){
					if(!_fLoader.Resigned){_fLoader.resignFileAttributesTag(_fLoader.InputBytes,_loader);return;}
				}
				
				if(_libMC == null && !_fLoader.Resigned){_fLoader.resignFileAttributesTag(_fLoader.InputBytes,_loader);return;}

				_inputBytes = _fLoader.InputBytes;
					
				if(_libMC.height>0&&_loaderList==null){createLoaderList();}
				numPages = _libMC.totalFrames;
				_swfLoaded = true
				reCreateAllPages();
				
				dispatchEvent(new Event("onPapersLoaded"));
				_bbusyloading = false;
				repositionPapers();
				
			}else{
				if(event.currentTarget.content != null){
					var mobj:Object = event.currentTarget.content;
					var firstLoad:Boolean = false;
					
					if(mobj is AVM1Movie || _loaderptr != null){
						_inputBytes = _loader.contentLoaderInfo.bytes;
						
						if(_loaderptr==null){
							_fLoader.flagSWF9Bit(_inputBytes);
							_loaderptr = new Loader();
							_loaderptr.contentLoaderInfo.addEventListener(Event.COMPLETE, swfComplete);
						}
						
						_fLoader.resignFileAttributesTag(_inputBytes,_loaderptr);
						_loaderptr.loadBytes(_inputBytes);
					}
					
					if(mobj is MovieClip){
						_libMC = mobj as MovieClip;
						if(_libMC.height>0&&_loaderList==null){createLoaderList();}
						DupImage.paperSource = _libMC;
						numPages = _libMC.totalFrames;
						firstLoad = _pageList == null || (_pageList.length == 0 && numPages > 0);
						
						if(_loaderptr==null){_inputBytes = _fLoader.InputBytes;}else{_inputBytes = _loaderptr.contentLoaderInfo.bytes;}
						
						if(_libMC.framesLoaded > 0)
							addInLoadedPages();
						
						if(_libMC.framesLoaded == _libMC.totalFrames){	
							dispatchEvent(new Event("onPapersLoaded"));
						}
												
						if(_libMC.framesLoaded>_frameLoadCount){
							flash.utils.setTimeout(repositionPapers,500);
							_frameLoadCount = _libMC.framesLoaded;
						}
						
						_bbusyloading = false;
						_swfLoaded = true
						
					}
				}
			}
		}	
		
		private function addInLoadedPages(recreate:Boolean = false):void{
			if(recreate){
				_displayContainer.removeAllChildren(); _pageList = null;
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
				
				if(_fitWidthOnLoad){_scale = getFitWidthFactor();}
				if(_fitPageOnLoad){_scale = getFitHeightFactor();}
			}	
			
			flash.utils.setTimeout(repositionPapers,500);
		}	
		
		private function reCreateAllPages():void{
			if(!_swfLoaded){return;}
			
			_displayContainer.visible = false;
			_displayContainer.removeAllChildren();
			_pageList = new Array(numPages);			
			
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
			if(_loaderList.length>0 && _viewMode == ViewModeEnum.PORTRAIT){_bbusyloading = true; _loaderList[0].loadBytes(_libMC.loaderInfo.bytes,getExecutionContext());}			
		}	
		
		private function createLoaderList():void
		{
			_loaderList = new Array(Math.round(getCalculatedHeight(_paperContainer)/(_libMC.height*0.1))+1);
			
			if(_viewMode == ViewModeEnum.PORTRAIT){
				for(var li:int=0;li<_loaderList.length;li++){
					_loaderList[li] = new DupLoader();
					_loaderList[li].contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoaded);
					_loaderList[li].addEventListener(Event.ENTER_FRAME,onframeenter);
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
		
		private var snap:TextSnapshot;
		private var searchIndex:int = -1;		
		private var searchPageIndex:int = -1;
		private var _selectionMarker:ShapeMarker;
		private var prevSearchText:String = "";
		private var prevYsave:Number=-1;
		
		public function searchText(text:String):void{
			var tri:Array;
			
			if(text.length==0){return;}
			
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
			
			while((searchPageIndex -1) < _libMC.framesLoaded){
				snap = _libMC.textSnapshot;
				searchIndex = snap.findText((searchIndex==-1?0:searchIndex),text,false);
				
				if(searchIndex > 0){ // found a new match
					_selectionMarker = new ShapeMarker();
					
					_selectionMarker.graphics.beginFill(0x0095f7,0.3);
					
					for(var ti:int=0;ti<text.length;ti++){
						tri = snap.getTextRunInfo(searchIndex+ti,searchIndex+ti+1);
						
						// only draw the "selected" rect if fonts are embedded otherwise draw a line thingy
						if(tri.length>1){
							prevYsave = tri[0].matrix_ty;
							
							if((tri[0].corner1x-tri[0].corner3x)>0 && (tri[0].corner3y-tri[0].corner1y)>0){
								_selectionMarker.graphics.drawRect(tri[0].corner3x,tri[0].corner1y,((tri[1].corner1y==tri[0].corner1y)?tri[1].corner3x:tri[0].corner1x)-tri[0].corner3x,tri[0].corner3y-tri[0].corner1y);
							}else{
								_selectionMarker.graphics.drawRect(tri[0].matrix_tx,tri[0].matrix_ty+1,tri[1].matrix_tx-tri[0].matrix_tx,4);
							}
						}
					}
					
					if(prevYsave>0){
						_selectionMarker.graphics.endFill();
						_adjGotoPage = (prevYsave) * _scale - 50;
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
			di.addEventListener(MouseEvent.MOUSE_OVER,dupImageMoverHandler);
			di.addEventListener(MouseEvent.MOUSE_OUT,dupImageMoutHandler);
			di.addEventListener(MouseEvent.CLICK,dupImageClickHandler);
			//di.addEventListener(MouseEvent.MOUSE_DOWN,textSelectorMouseDownHandler);
			_pageList[index-1] = di;
		}	
		
		private function textSelectorMouseDownHandler(event:MouseEvent):void{
			if(!TextSelectEnabled){return;}
			
			_currentlySelectedText = "";
			_firstHitIndex = -1;
			_lastHitIndex = -1;
			
			if(_selectionMarker!=null&&_selectionMarker.parent!=null){_selectionMarker.parent.removeChild(_selectionMarker);}
			
			systemManager.addEventListener(
				MouseEvent.MOUSE_MOVE, textSelectorMoveHandler, true);
			
			systemManager.addEventListener(
				MouseEvent.MOUSE_UP, textSelectorMouseUpHandler, true);
			
			systemManager.stage.removeEventListener(
				Event.MOUSE_LEAVE, textSelectorMouseLeaveHandler);
		}
		
		private var _firstHitIndex:int = -1;
		private var _lastHitIndex:int = -1;
		private var _currentlySelectedText:String = "";
		private var _tri:Array;
		
		private function textSelectorMoveHandler(event:MouseEvent):void{
			event.stopImmediatePropagation();

			if(!(event.target is DupLoader)){return;}
			
			var mc:MovieClip = (event.target.content as MovieClip);
			var ts:TextSnapshot = mc.textSnapshot;
			var hitIndex:int = ts.hitTestTextNearPos(event.target.parent.mouseX,event.target.parent.mouseY,10);
			
			if(hitIndex>0){
				if(_firstHitIndex==-1){_firstHitIndex=hitIndex;}
				_lastHitIndex = hitIndex; 
			}
			
			snap = _libMC.textSnapshot;
			if(_firstHitIndex<=_lastHitIndex){
				_tri = snap.getTextRunInfo(_firstHitIndex,_lastHitIndex);
			}else{
				_tri = snap.getTextRunInfo(_lastHitIndex,_firstHitIndex);
			}
			
			if(_selectionMarker!=null&&_selectionMarker.parent!=null){_selectionMarker.parent.removeChild(_selectionMarker);}
			
			_selectionMarker = new ShapeMarker();
			var ly:Number=-1;
			var li:int;
			
			for(var i:int=0;i<_tri.length-1;i++){
				if(ly==-1){ly=_tri[i].corner1y;li=0;}
				
				if(ly!=_tri[i+1].corner1y||i==_tri.length-2){
					_selectionMarker.graphics.beginFill(0x0095f7,0.3);
					_selectionMarker.graphics.drawRect(_tri[li].corner3x,_tri[i].corner1y,((i==_tri.length-2)?_tri[i+1].corner1x:_tri[i].corner1x)-_tri[li].corner3x,_tri[i].corner3y-_tri[i].corner1y);
					_selectionMarker.graphics.endFill();
					
					ly=_tri[i+1].corner1y;li=i+1;
				}
			}

			_pageList[mc.currentFrame-1].addChildAt(_selectionMarker,_pageList[mc.currentFrame-1].numChildren);
			searchPageIndex = mc.currentFrame;
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
			
			snap = _libMC.textSnapshot;
			_currentlySelectedText = snap.getText(_firstHitIndex,_lastHitIndex);
			_tri = snap.getTextRunInfo(_firstHitIndex,_lastHitIndex);
		}
		
		private function dupImageClickHandler(event:MouseEvent):void{
			if((_viewMode == ViewModeEnum.TILE) && event.target != null && event.target is DupImage){
				ViewMode = 'Portrait';
				_scrollToPage = (event.target as DupImage).dupIndex;
			}else{
				_dupImageClicked = true;
				var t:Timer = new Timer(100,1);
				t.addEventListener("timer", resetClickHandler);
				t.start();				
			}
		}
		
		private function resetClickHandler(e:Event):void {
			_dupImageClicked = false;
		}
		
		private function dupImageMoverHandler(event:MouseEvent):void{
			if(_viewMode == ViewModeEnum.TILE && event.target != null && event.target is DupImage){
				addGlowFilter(event.target as DupImage);
			}else{
				if(event.target is flash.display.SimpleButton){
					CursorManager.removeAllCursors();
				}else{
					if(TextSelectEnabled){
						grabCursorID = CursorManager.setCursor(textSelectCursor);	
					}else{
						grabCursorID = CursorManager.setCursor(grabCursor);
					}
				}
			}
		}
		
		private function dupImageMoutHandler(event:MouseEvent):void{
			if(_viewMode == ViewModeEnum.TILE && event.target != null && event.target is DupImage){
				(event.target as DupImage).filters = null;
			}
		}
		
		private function addPages():void{
			for(var pi:int=0;pi<_pageList.length;pi++){
				_displayContainer.addChild(_pageList[pi]);
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
				
				for(var i:int=0;i<_libMC.framesLoaded;i++){
					_libMC.gotoAndStop(i+1);
					pj.addPage(_swfContainer,null,options);
				}			
				
				pj.send();
			}
			
			_libMC.scaleX = _libMC.scaleY = 1;
			_libMC.alpha = 0;
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
				
				for(var ip:int=0;ip<_libMC.framesLoaded;ip++){
					if(pageNumList[ip+1] != null){
						_libMC.gotoAndStop(ip+1);
						pj.addPage(_swfContainer,null,options);
					}
				}			
				
				pj.send();
			}
			
			_libMC.scaleX = _libMC.scaleY = 1;
			_libMC.alpha = 0;
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
				
				if(loaderCtx.hasOwnProperty("allowLoadBytesCodeExecution")){
					loaderCtx["allowLoadBytesCodeExecution"] = true;
				}
				
			}
			return loaderCtx; 
		} 
	}
}