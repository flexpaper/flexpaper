package com.devaldi.controls.flexpaper
{
	import com.devaldi.controls.flexpaper.IFlexPaperPluginControl;
	import com.devaldi.controls.flexpaper.ShapeMarker;

	public class LinkMarker extends ShapeMarker implements IFlexPaperPluginControl
	{
		public var linkX:Number=-1;
		public var linkY:Number=-1;
		public var linkEndX:Number=-1;
		public var linkEndY:Number=-1;
		public var href:String="";
		public var type:String="LinkMarker";
		public var allowinteractions:Boolean=true;
		
		private var _initialized:Boolean=false;
		public function get isInitialized():Boolean{
			return _initialized;
		}
		
		public function set isInitialized(b:Boolean):void{
			_initialized = b;
		}
		
	}
}