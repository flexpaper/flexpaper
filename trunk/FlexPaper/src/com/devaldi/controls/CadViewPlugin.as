package com.devaldi.controls
{
	import caurina.transitions.Tweener;
	
	import com.devaldi.controls.flexpaper.FitModeEnum;
	import com.devaldi.controls.flexpaper.IFlexPaperViewModePlugin;
	import com.devaldi.controls.flexpaper.ShapeMarker;
	import com.devaldi.controls.flexpaper.ViewModeEnum;
	import com.devaldi.controls.flexpaper.Viewer;
	import com.devaldi.controls.flexpaper.utils.StreamUtil;
	import com.devaldi.events.CurrentPageChangedEvent;
	import com.devaldi.events.PageLoadingEvent;
	import com.devaldi.streaming.DupImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextSnapshot;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;
	
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.effects.Move;
	import mx.effects.Resize;
	import mx.events.EffectEvent;
	
	public class CadViewPlugin implements IFlexPaperViewModePlugin, IEventDispatcher
	{
		private var dispatcher:IEventDispatcher = new EventDispatcher();
		private var viewer:Viewer;
		private var _saveScale:Number = 1;
		
		public function getPageTextSnapshot(pn:Number):TextSnapshot{
			return viewer.PageList[pn].textSnapshot as TextSnapshot;
		}
		
		public function setTextSelectMode(pn:Number):void{
			
		}
		
		public function getNormalizationHeight(pageIndex:Number):Number{
			return viewer.libMC.height;	
		}
		
		public function getNormalizationWidth(pageIndex:Number):Number{
			return viewer.libMC.width;
		}
		
		public function unsetTextSelectMode(pn:Number):void{
			
		}
		
		public function CadViewPlugin()
		{
		}
		
		public function get Name():String{
			return "CADView";
		}
		
		public function translatePageNumber(pn:Number):Number{
			return pn;
		}
		
		var _imgPreview:Image;
		
		public function initComponent(v:Viewer):Boolean{
			viewer = v;
			viewer.DisplayContainer = new Box();
			viewer.DisplayContainer.setStyle("horizontalAlign", "center");
			viewer.PaperContainer.addChild(viewer.DisplayContainer);
			viewer.PaperContainer.childrenDoDrag = true;
			viewer.DisplayContainer.percentWidth = 100;
			
			if(_imgPreview!=null){
				_imgPreview.parent.removeChild(_imgPreview);
			}
			
			_imgPreview = new Image();
			_imgPreview.width = 150; _imgPreview.height = 150;
			_imgPreview.x = viewer.width-_imgPreview.width - 22; _imgPreview.y = viewer.height-_imgPreview.height - 22;
			viewer.addChildAt(_imgPreview,viewer.numChildren-1);
			viewer.addEventListener(Event.RESIZE, viewerSizeChanged,false,0,true);
			viewer.addEventListener(MouseEvent.DOUBLE_CLICK,displayContainerDoubleClickHandler,false,0,true);
			
			return true;
		}
		
		private function viewerSizeChanged(evt:Event):void{
			if(_imgPreview!=null && viewer!=null){
				_imgPreview.width = viewer.width/5; _imgPreview.height = _imgPreview.width / (viewer.width/viewer.height);
				_imgPreview.x = viewer.width-_imgPreview.width - 22; _imgPreview.y = viewer.height-_imgPreview.height - 22;
			}
		}
		
		var move:Move;
		
		private function displayContainerDoubleClickHandler(event:MouseEvent):void{
			if(viewer.TextSelectEnabled){
				return;
			}
			if(viewer.ViewMode == this.Name)
				viewer.FitMode = (viewer.FitMode == FitModeEnum.FITWIDTH)?FitModeEnum.FITHEIGHT:FitModeEnum.FITWIDTH;
		}
		
		public function moveOutLeft():void{
			move = new Move(viewer.PaperContainer);
			move.xFrom = 0;
			move.duration = 200;
			move.xTo = 800;
			move.addEventListener(EffectEvent.EFFECT_END,onMoveOutLeftEnd);
			move.play();
			
		}
		
		private function onMoveOutLeftEnd(event:EffectEvent):void{
			viewer.addEventListener("onCurrPageChanged",moveLeftPageChangedEvent);
			viewer.mvPrev();
		}
		
		private function moveLeftPageChangedEvent(e:CurrentPageChangedEvent):void{
			if(Number(viewer.Scale) > viewer.getFitHeightFactor()){
				viewer.fitHeight();
			}
			
			flash.utils.setTimeout(function():void{
				viewer.removeEventListener("onCurrPageChanged",moveLeftPageChangedEvent);
				move = new Move(viewer.PaperContainer);
				move.xFrom = -800;
				move.duration = 200;
				move.xTo = 0;
				move.play();
			},300);
		}
		
		public function moveOutRight():void{
			move = new Move(viewer.PaperContainer);
			move.xFrom = 0;
			move.duration = 200;
			move.xTo = -800;
			move.addEventListener(EffectEvent.EFFECT_END,onMoveOutRightEnd);
			move.play();
			
		}
		
		private function onMoveOutRightEnd(event:EffectEvent):void{
			viewer.addEventListener(CurrentPageChangedEvent.PAGE_CHANGED,moveRightPageChangedEvent);
			viewer.mvNext();
		}
		
		private function moveRightPageChangedEvent(e:CurrentPageChangedEvent):void{
			if(Number(viewer.Scale) > viewer.getFitHeightFactor()){
				viewer.fitHeight();
			}
			
			flash.utils.setTimeout(function():void{
				viewer.removeEventListener(CurrentPageChangedEvent.PAGE_CHANGED,moveRightPageChangedEvent);
				move = new Move(viewer.PaperContainer);
				move.xFrom = 800;
				move.duration = 200;
				move.xTo = 0;
				move.play();			
			},300);
		}
		
		public function initOnLoading():void{
			viewer.BusyLoading = true; 
			viewer.DocLoader.LoaderList[0].loadBytes(viewer.libMC.loaderInfo.bytes,StreamUtil.getExecutionContext());
		}
		
		public function mvPrev(interactive:Boolean=false):void{
			if(viewer.currPage>1){viewer.gotoPage(viewer.currPage-1);}
		}
		
		public function mvNext(interactive:Boolean=false):void{
			if(viewer.currPage<viewer.numPages){viewer.gotoPage(viewer.currPage+1);}
		}
		
		public function renderSelection(i:int,marker:ShapeMarker):void{
			if(i+1 == viewer.SearchPageIndex && marker.parent != viewer.PageList[0]){
				viewer.PageList[0].addChildAt(marker,viewer.PageList[0].numChildren);
			}else if(i+1 == viewer.SearchPageIndex && marker.parent == viewer.PageList[0]){
				viewer.PageList[0].setChildIndex(marker,viewer.PageList[0].numChildren -1);
			}
		}
		
		public function renderPage(i:Number):void{
			if((!viewer.BusyLoading||viewer.DocLoader.IsSplit) && viewer.DocLoader.LoaderList!=null && viewer.DocLoader.LoaderList.length>0){
				var uloaderidx:int = 0;
				
				if(!viewer.DocLoader.IsSplit&&(viewer.libMC!=null&&viewer.numPagesLoaded>=viewer.PageList[i].dupIndex && 
					viewer.DocLoader.LoaderList[uloaderidx] != null && 
					viewer.DocLoader.LoaderList[uloaderidx].content==null||(viewer.DocLoader.LoaderList[uloaderidx].content!=null&&viewer.DocLoader.LoaderList[uloaderidx].content.framesLoaded<viewer.PageList[0].dupIndex))){
					
					viewer.BusyLoading = true;
					viewer.DocLoader.LoaderList[uloaderidx].loadBytes(viewer.DocLoader.InputBytes,StreamUtil.getExecutionContext());
					flash.utils.setTimeout(viewer.repositionPapers,200);
				}else if(viewer.DocLoader.IsSplit&&viewer.DocLoader.LoaderList[uloaderidx].pageStartIndex != i+1){
					viewer.dispatchEvent(new PageLoadingEvent(PageLoadingEvent.PAGE_LOADING,i+1));
					try{
						viewer.DocLoader.LoaderList[uloaderidx].unloadAndStop(true);
						viewer.DocLoader.LoaderList[uloaderidx].loaded = false;
						viewer.DocLoader.LoaderList[uloaderidx].loading = true;
						viewer.DocLoader.LoaderList[uloaderidx].load(new URLRequest(viewer.getSwfFilePerPage(viewer.SwfFile,i+1)),StreamUtil.getExecutionContext());
						viewer.DocLoader.LoaderList[uloaderidx].pageStartIndex = i+1;
					}catch(err:IOErrorEvent){
						
					}
					
					viewer.repaint();
				}
			}
			
			if(viewer.PageList[0]!=null && viewer.DocLoader.LoaderList[uloaderidx]!=null&&viewer.DocLoader.LoaderList[uloaderidx].content!=null){
				viewer.DocLoader.LoaderList[uloaderidx].content.gotoAndStop(viewer.currPage);
				viewer.PageList[0].addChild(viewer.DocLoader.LoaderList[uloaderidx]);
				viewer.PageList[0].loadedIndex = viewer.currPage;
				viewer.PageList[0].dupIndex = viewer.currPage; 
			}
			
			redrawPreview(i);
		}
		
		// draws the preview in the bottom right corner
		var _rectSprite:Sprite = new Sprite();
		var _highlightRectSprite:Sprite = new Sprite();
		var _highlightBitmap:Bitmap;
		
		private function redrawPreview(i:Number):void{
			if(_draggingThumbnail){return;}
			
			while(_imgPreview.numChildren > 0)
				delete(_imgPreview.removeChildAt(0));
			
			_imgPreview.graphics.clear();
			_imgPreview.graphics.beginFill(0xdddddd,1);
			_imgPreview.graphics.drawRect(0,0,_imgPreview.width,_imgPreview.height);
			_imgPreview.graphics.endFill();
			
			var bmd:BitmapData;
			var bmdscale:Number;
			
			if(viewer.libMC.height>viewer.libMC.width){
				bmd = new BitmapData((viewer.libMC.width/viewer.libMC.height)*_imgPreview.height, _imgPreview.height, false, 0xFFFFFF);
				bmdscale = bmd.height/viewer.libMC.height;
			}else{
				bmd = new BitmapData(_imgPreview.width, (viewer.libMC.height/viewer.libMC.width) * _imgPreview.width, false, 0xFFFFFF);
				bmdscale = bmd.width/viewer.libMC.width;
			}
			
			bmd.draw(viewer.PageList[0],new Matrix(bmdscale, 0, 0, bmdscale),null,null,null,true);
			_highlightBitmap = new Bitmap(bmd);
			_highlightBitmap.x = (_highlightBitmap.width<_imgPreview.width)?(_imgPreview.width-_highlightBitmap.width)/2:0;
			_highlightBitmap.y = (_highlightBitmap.height<_imgPreview.height)?(_imgPreview.height-_highlightBitmap.height)/2:0;
			
			_imgPreview.addChild(_highlightBitmap);
			
			var rectPosXAdj:Number = _imgPreview.width * ((viewer.DisplayContainer.width * 0.96 - viewer.PageList[0].width) / viewer.DisplayContainer.width);rectPosXAdj = (rectPosXAdj<0)?0:rectPosXAdj/2;
			var rectPosYAdj:Number = _imgPreview.height * ((viewer.DisplayContainer.height - viewer.PageList[0].height) / viewer.DisplayContainer.height);rectPosYAdj = (rectPosYAdj<0)?0:rectPosYAdj/2;
			var rectSizeWidth:Number = _highlightBitmap.width * (viewer.PaperContainer.width / viewer.DisplayContainer.width); // ok
			var rectSizeHeight:Number = _highlightBitmap.height * (viewer.PaperContainer.height / viewer.DisplayContainer.height); // ok
			
			var rectPosX:Number = ((_highlightBitmap.width - rectSizeWidth) * (viewer.PaperContainer.horizontalScrollPosition / viewer.PaperContainer.maxHorizontalScrollPosition));
			var rectPosY:Number = ((_highlightBitmap.height - rectSizeHeight) * (viewer.PaperContainer.verticalScrollPosition / viewer.PaperContainer.maxVerticalScrollPosition));
			
			rectPosX = _highlightBitmap.x + rectPosX - rectPosXAdj;
			
			if(rectPosX<0 || isNaN(rectPosX)){
				rectPosX = _highlightBitmap.x - rectPosXAdj;
			}
			
			rectPosY = _highlightBitmap.y + rectPosY - rectPosYAdj;
			
			if(rectPosY<0 || isNaN(rectPosY)){
				rectPosY = _highlightBitmap.y - rectPosYAdj;
			}
			
			rectSizeWidth = rectSizeWidth + rectPosXAdj*2;
			if(rectSizeWidth > _imgPreview.width){
				rectSizeWidth = _imgPreview.width;
			}
			
			rectSizeHeight = rectSizeHeight + rectPosYAdj*2;
			if(rectSizeHeight > _imgPreview.height){
				rectSizeHeight = _imgPreview.height;
			}
			
			if(rectPosX<0){rectPosX = 0;}if(rectPosY<0){rectPosY = 0;}
			
			if(rectSizeWidth > 0 && rectSizeHeight > 0){
				_rectSprite.graphics.clear();
				
				_rectSprite.graphics.lineStyle(1, 1, 1);
				_rectSprite.graphics.drawRect(0,0,_imgPreview.width,_imgPreview.height);
				if(_rectSprite.parent != _imgPreview)
					_imgPreview.addChild(_rectSprite);
				
				_highlightRectSprite.graphics.clear();
				_highlightRectSprite.graphics.beginFill(0xffffff,0);
				_highlightRectSprite.graphics.drawRect(0, 0, rectSizeWidth, rectSizeHeight);
				_highlightRectSprite.graphics.endFill();
				
				_highlightRectSprite.graphics.beginFill(0xb4d4f8,0.3);
				_highlightRectSprite.x = rectPosX;
				_highlightRectSprite.y = rectPosY;
				_highlightRectSprite.graphics.drawRect(0, 0, rectSizeWidth, rectSizeHeight);
				_highlightRectSprite.graphics.endFill();
				
				_highlightRectSprite.graphics.lineStyle(1, 0x0000ff, 1);
				_highlightRectSprite.x = rectPosX;
				_highlightRectSprite.y = rectPosY;
				_highlightRectSprite.graphics.drawRect(0, 0, rectSizeWidth, rectSizeHeight);
				
				if(_highlightRectSprite.parent != _imgPreview){
					_imgPreview.addChild(_highlightRectSprite);
					
					if(!_highlightRectSprite.hasEventListener(MouseEvent.MOUSE_MOVE)){
						_highlightRectSprite.addEventListener(MouseEvent.MOUSE_MOVE, thumbMouseMoveHandler);
						_highlightRectSprite.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
						_highlightRectSprite.addEventListener(MouseEvent.MOUSE_UP, thumbMouseUpHandler);
						_highlightRectSprite.buttonMode = true;
					}
				}
			}
		}
		
		private var _draggingThumbnail:Boolean = false;
		protected function thumbMouseDownHandler (e:MouseEvent):void{
			var r:Rectangle = new Rectangle(_highlightBitmap.x,_highlightBitmap.y,_highlightBitmap.width-_highlightRectSprite.width+1,_highlightBitmap.height-_highlightRectSprite.height+2);
			
			e.target.startDrag(false,r);
			_draggingThumbnail = true;
		}
		
		protected function thumbMouseMoveHandler (e:MouseEvent):void{
			if(_draggingThumbnail){
				var pctX:Number = (e.target.x-_highlightBitmap.x)/(_highlightBitmap.width-e.target.width);
				var pctY:Number = (e.target.y-_highlightBitmap.y)/(_highlightBitmap.height-e.target.height);
				viewer.PaperContainer.horizontalScrollPosition = viewer.PaperContainer.maxHorizontalScrollPosition * pctX;
				viewer.PaperContainer.verticalScrollPosition = viewer.PaperContainer.maxVerticalScrollPosition * pctY;
			}
		}
		
		protected function thumbMouseUpHandler (e:MouseEvent):void{
			e.target.stopDrag();
			_draggingThumbnail = false;
			redrawPreview(-1);
		}
		
		
		public function setViewMode(s:String, viewer:Viewer):void{
			viewer.PaperContainer.x = 0;
			if (viewer.IsInitialized && viewer.SwfLoaded){
				viewer.createDisplayContainer();
				if(viewer.ProgressiveLoading){
					viewer.addInLoadedPages(true);
				}else{
					viewer.reCreateAllPages();
				}
				viewer.DisplayContainer.visible = true;
			} 
			
		}
		
		public function disposeViewMode():void{
			if(_imgPreview!=null){
				_imgPreview.parent.removeChild(_imgPreview);
				_imgPreview = null;
			}
		}
		
		public function renderMark(sm:UIComponent,pageIndex:int):void{
			viewer.PageList[pageIndex].addChildAt(sm,viewer.PageList[pageIndex].numChildren);
		}
		
		public function addChild(i:int,o:DisplayObject):void{
			if(i==0){
				viewer.DisplayContainer.addChild(o);
			}
		}
		
		public function get currentPage():int{
			if(viewer==null)
				return 0;
			
			if(viewer.currPage==0)
				viewer.currPage = 1;
			
			return viewer.currPage;
		}
		
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		
		public function get doFitHeight():Boolean{
			return true;
		}
		
		public function get doFitWidth():Boolean{
			return true;
		}
		
		public function get doZoom():Boolean{
			return true;
		}
		
		public function get supportsTextSelect():Boolean{
			return true;
		}
		
		public function get loaderListLength():int{
			return 1;
		}
		
		public function get SaveScale():Number{
			return _saveScale;
		}
		
		public function set SaveScale(n:Number):void{
			_saveScale = n;
		}
		
		public function gotoPage(page:Number,adjGotoPage:int=0,interactive:Boolean=false):void{
			var prevPage = viewer.currPage;
			viewer.currPage = page;
			viewer.dispatchEvent(new CurrentPageChangedEvent(CurrentPageChangedEvent.PAGE_CHANGED,page,prevPage));
		}
		
		public function handleDoubleClick(event:MouseEvent):void{
			
		}
		
		public function handleMouseDown(event:MouseEvent):void{
			
		}
		
		public function handleMouseUp(event:MouseEvent):void{
			
		}
		
		public function clearSearch():void{
			
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function checkIsVisible(pageIndex:int):Boolean{
			return pageIndex==viewer.currPage -1;
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
	}
}