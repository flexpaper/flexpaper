package com.devaldi.controls.flexpaper
{
	import com.devaldi.controls.flexpaper.IFlexPaperPluginControl;
	import com.devaldi.controls.flexpaper.ShapeMarker;
	import com.devaldi.events.CursorModeChangedEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	public class VideoMarker extends ImageMarker
	{
		public var VideoUrl:String = "";
		
		public function VideoMarker(){
			type = "VideoMarker"; 
		}
	}
}