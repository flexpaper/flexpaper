package com.devaldi.controls.flexpaper
{
	import com.devaldi.controls.flexpaper.IFlexPaperPluginControl;
	import com.devaldi.controls.flexpaper.ShapeMarker;
	import com.devaldi.events.CursorModeChangedEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	public class ImageMarker extends ShapeMarker implements IFlexPaperPluginControl
	{
		public var imageX:Number=-1;
		public var imageY:Number=-1;
		public var imageEndX:Number=-1;
		public var imageEndY:Number=-1;
		public var src:String="";
		public var type:String="ImageMarker";
		public var keepaspect:Boolean = true;
		public var bitmap:Bitmap;
		public var loading:Boolean = false;
		
		public var dragging:Boolean = false;
		public var resizing:Boolean = false;
		
		public var resizeRight:Boolean = false;
		public var resizeLeft:Boolean = false;
		public var resizeBottom:Boolean = false;
		public var resizeTop:Boolean = false;
		public var resizeRightBottom:Boolean = false;
		
		public var bitmapScaleX:Number=1;
		public var bitmapScaleY:Number=1;
		
		public var RightPanel:Sprite;
		public var LeftPanel:Sprite;
		public var TopPanel:Sprite;
		public var BottomPanel:Sprite;
		public var RightBottomPanel:Sprite;
		
		public var xmlNode:XML;
		
		private var _initialized:Boolean=false;
		public function get isInitialized():Boolean{
			return _initialized;
		}
		
		public function set isInitialized(b:Boolean):void{
			_initialized = b;
		}
		
		public function drawImage(clear:Boolean=true):void{
			if(clear)
				graphics.clear();
			
			if(resizing || dragging){
				graphics.beginFill(0x72e6ff,0.4);
				graphics.drawRect(-5,-5,imageEndX-imageX+10,imageEndY-imageY+10);
			}
			
			var matrix:Matrix = new Matrix();
			bitmapScaleX = (imageEndX-imageX)/bitmap.width;
			bitmapScaleY = (imageEndY-imageY)/bitmap.height;
			
			matrix.scale(bitmapScaleX,bitmapScaleY);
			matrix.tx = imageEndX-imageX;
			matrix.ty = imageEndY-imageY;
			
			graphics.beginBitmapFill(bitmap.bitmapData,matrix,true);
			graphics.drawRect(0,0,imageEndX-imageX-1,imageEndY-imageY-1);
			graphics.endFill();
			
			
			if(RightPanel==null){
				RightPanel = new Sprite();
				addChild(RightPanel);
			}
			
			RightPanel.x = imageEndX-imageX+3;
			RightPanel.y = 0;
			RightPanel.graphics.clear();
			RightPanel.graphics.beginFill(0x72e6ff,0);
			RightPanel.graphics.drawRect(0,0,10,imageEndY-imageY);
			
			
			if(LeftPanel==null){
				LeftPanel = new Sprite();
				addChild(LeftPanel);
			}
			
			LeftPanel.x = 0;
			LeftPanel.y = 0;
			LeftPanel.graphics.clear();
			LeftPanel.graphics.beginFill(0x72e6ff,0);
			LeftPanel.graphics.drawRect(-5,0,10,imageEndY-imageY);
			LeftPanel.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void{
				
			});
			
			if(TopPanel==null){
				TopPanel = new Sprite();
				addChild(TopPanel);
			}
			
			TopPanel.x = 0;
			TopPanel.y = 0;
			TopPanel.graphics.clear();
			TopPanel.graphics.beginFill(0x72e6ff,0);
			TopPanel.graphics.drawRect(0,0,imageEndX-imageX,10);
			TopPanel.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void{
				
			});
			
			if(BottomPanel==null){
				BottomPanel = new Sprite();
				addChild(BottomPanel);
			}
			
			BottomPanel.x = 0; 
			BottomPanel.y = 0;
			BottomPanel.graphics.clear();
			BottomPanel.graphics.beginFill(0x72e6ff,0);
			BottomPanel.graphics.drawRect(0,imageEndY-imageY,imageEndX-imageX,10);
			BottomPanel.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void{
				
			});
			
			if(RightBottomPanel==null){
				RightBottomPanel = new Sprite();
				addChild(RightBottomPanel);
			}
			
			RightBottomPanel.x = 0;
			RightBottomPanel.y = 0;
			RightBottomPanel.graphics.clear();
			RightBottomPanel.graphics.beginFill(0xff0000,0);
			RightBottomPanel.graphics.drawRect(imageEndX-imageX-7,imageEndY-imageY-7,15,15);
			RightBottomPanel.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void{
				
			});
		}
		
	}
}