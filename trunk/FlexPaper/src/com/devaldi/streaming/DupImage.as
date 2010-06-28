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

package com.devaldi.streaming
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.setTimeout;
	
	import mx.controls.Image;
	
	public class DupImage extends Image
	{
		public var dupIndex:int = 0;
		public var dupScale:Number = 0;
		public var scaleWidth:int;
		public var scaleHeight:int;
		public var loadedIndex:int = -1;
		
		public static var paperSource:MovieClip; 
		
		public function DupImage(){}
		
		override public function set source(value:Object):void{
			if(this.source != null && this.source is Bitmap && this.source.bitmapData != null){
				this.source.bitmapData.dispose();
			}
			
			super.source = value;
			
			if(value!=null){
				if(this.filters.length==0){addDropShadow();}
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			addEventListener(MouseEvent.ROLL_OVER,dupImageMoverHandler,false,0,true);
		}
		
		private function dupImageMoverHandler(event:MouseEvent):void{
		    if(!contains(paperSource)){
				paperSource.gotoAndStop(dupIndex);
				paperSource.alpha = 0;
				addChild(paperSource);
			}
		}
				
		public function addDropShadow():void
		{
			if(this.filters.length==0){
			this.filters = null;
			 var filter : DropShadowFilter = new DropShadowFilter();
			 filter.blurX = 4;
			 filter.blurY = 4;
			 filter.quality = 2;
			 filter.alpha = 0.5;
			 filter.angle = 45;
			 filter.color = 0x202020;
			 filter.distance = 4;
			 filter.inner = false;
			 this.filters = [ filter ];
			}
		}			
		
		public function addGlowFilter():void{
			var filter : flash.filters.GlowFilter = new flash.filters.GlowFilter(0x111111, 1, 5, 5, 2, 1, false, false);
			filters = [ filter ];
		}
		
		
		public function removeAllChildren():void{
			while(numChildren > 0)
				delete(removeChildAt(0));
			
			this.filters = null;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject{
			//flash.utils.setTimeout(addDropShadow,200);
			return super.addChild(child);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			if(w>0&&h>0){
			try{
			graphics.beginFill(0xffffff,1);
			graphics.drawRect(0,0,w,h);
			super.updateDisplayList(w,h);}catch (e:*) {}}
		}	 
		
		public function addGlowShadow():void
		{
			
		}
		
		public function getScaledHeight():Number
		{
			return scaleX>0? unscaledHeight * this.scaleX:height;
		}		
	}
}