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
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.events.MouseEvent;
	import mx.controls.Image;
	
	public class DupImage extends Image
	{
		public var dupIndex:int = 0;
		public var dupScale:Number = 0;
		public var scaleWidth:int;
		public var scaleHeight:int;
		
		public static var paperSource:MovieClip; 
		
		public function DupImage(){}
		
		override public function set source(value:Object):void{
			if(value!=null){super.source = value;}
			
			if(value!=null){
				if(this.filters.length==0){addDropShadow();}
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			addEventListener(MouseEvent.ROLL_OVER,dupImageMoverHandler);
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
		
		public function addGlowFilter():void{
			var filter : flash.filters.GlowFilter = new flash.filters.GlowFilter(0x111111, 1, 5, 5, 2, 1, false, false);
			filters = [ filter ];   
		}
		
		
		public function removeAllChildren():void{
			while(numChildren > 0)
				delete(removeChildAt(0));
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			graphics.beginFill(0xffffff,1);
			graphics.drawRect(0,0,w,h);
			super.updateDisplayList(w,h);
		}	
		
		public function addGlowShadow():void
		{
			
		}
	}
}