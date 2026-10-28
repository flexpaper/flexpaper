/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.streaming
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import com.devaldi.controls.flexpaper.resources.MenuIcons;
	import flash.system.SecurityDomain;
	
	public class DupLoader extends flash.display.Loader implements ITextSelectableDisplayObject
	{
		public static var parentLoader:IDocumentLoader;
		public var stream:URLStream;
		public var loaded:Boolean = false;
		public var loadingFrames:int = 0;
		public var pageStartIndex:int = 0;
		public var loading:Boolean = false;
		public var callbackData:Object = null;
		private var _ctx:LoaderContext;
		private var _inputBytes:ByteArray;
		import com.devaldi.controls.flexpaper.utils.StreamUtil;
		
		public function DupLoader():void{
			
		}
		
		public function resetURLStream():void{
			if(com.devaldi.controls.flexpaper.resources.MenuIcons.PreviewMode!=true){
				stream = new URLStream();
				stream.addEventListener(Event.COMPLETE, streamCompleteHandler,false,0,true);
			}
		}
		
		private function streamCompleteHandler(event:Event):void{
			_inputBytes = new ByteArray();
			stream.readBytes(_inputBytes);
			stream.close();
			_inputBytes.endian = Endian.LITTLE_ENDIAN;
			
			parentLoader.touch(_inputBytes);
			
			flash.utils.setTimeout(function():void{
				loadBytes(_inputBytes,_ctx);
			},200);
		}
		
		public override function load(request:URLRequest, context:LoaderContext=null):void{
			
			// check for cross domain
			if((request.url.toLowerCase().indexOf("http://")>=0 ||
				request.url.toLowerCase().indexOf("https://")>=0) &&
				
				request.url.toLowerCase().indexOf(StreamUtil.loaderURL.toLowerCase())==-1){ 
				resetURLStream();
			}
			
			if(com.devaldi.controls.flexpaper.resources.MenuIcons.PreviewMode!=true)
				flash.system.Security.allowDomain(request.url);
			
			if(stream==null){
				super.load(request,context);
			}else{
				_ctx = context;
				stream.load(request);
			}
		}
		
		public function getMovieClip():MovieClip{
			return this.content as MovieClip;
		}
		
		public function getPageIndex():int{
			return this.pageStartIndex;
		}
		
		public function setTextSelectMode():void{
			
		}
		
		public function unSetTextSelectMode():void{
			
		}
	}
}