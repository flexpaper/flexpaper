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

package com.devaldi.controls
{
	import caurina.transitions.Tweener;
	
	import com.devaldi.controls.flexpaper.IFlexPaperViewModePlugin;
	import com.devaldi.controls.flexpaper.ShapeMarker;
	import com.devaldi.controls.flexpaper.Viewer;
	import com.devaldi.controls.flexpaper.utils.StreamUtil;
	import com.devaldi.events.CurrentPageChangedEvent;
	import com.devaldi.events.PageLoadingEvent;
	import com.devaldi.streaming.DupImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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
	import flash.utils.setTimeout;
	
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.effects.Move;
	import mx.effects.Resize;
	import mx.events.EffectEvent;
	
	public class SinglePagePlugin implements IFlexPaperViewModePlugin, IEventDispatcher
	{
		private var dispatcher:IEventDispatcher = new EventDispatcher();
		private var viewer:Viewer;
		private var _saveScale:Number = 1;
		
		public function getPageTextSnapshot(pn:Number):TextSnapshot{
			return viewer.PageList[pn].textSnapshot as TextSnapshot;
		}
		
		public function getNormalizationHeight(pageIndex:Number):Number{
			return viewer.libMC.height;	
		}
		
		public function getNormalizationWidth(pageIndex:Number):Number{
			return viewer.libMC.width;
		}
		
		public function setTextSelectMode(pn:Number):void{
			
		}
		
		public function unsetTextSelectMode(pn:Number):void{
			
		}
		
		public function SinglePagePlugin()
		{
		}
		
		public function get Name():String{
			return "SinglePage";
		}
		
		public function translatePageNumber(pn:Number):Number{
			return pn;
		}
		
		public function initComponent(v:Viewer):Boolean{
			viewer = v;
			viewer.DisplayContainer = new Box();
			viewer.DisplayContainer.setStyle("horizontalAlign", "center");
			viewer.PaperContainer.addChild(viewer.DisplayContainer);
			viewer.PaperContainer.childrenDoDrag = true;
			viewer.DisplayContainer.percentWidth = 100;

			//viewer.PaperContainer.verticalScrollPolicy = "off";
			//viewer.PaperContainer.horizontalScrollPolicy = "off";
			//viewer.verticalScrollPolicy = "off";
			//viewer.horizontalScrollPolicy = "off";
			
			return true;
		}
		var move:Move;
		
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

		public function disposeViewMode():void{
			
		}
	}
}