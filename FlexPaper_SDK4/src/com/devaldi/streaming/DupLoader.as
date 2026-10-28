/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.streaming
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class DupLoader extends flash.display.Loader
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
		
		public function resetURLStream():void{
			stream = new URLStream();
			stream.addEventListener(Event.COMPLETE, streamCompleteHandler,false,0,true);
		}
		
		private function streamCompleteHandler(event:Event):void{
			_inputBytes = new ByteArray();
			stream.readBytes(_inputBytes);
			stream.close();
			_inputBytes.endian = Endian.LITTLE_ENDIAN;
			
			parentLoader.touch(_inputBytes);
			
			flash.utils.setTimeout(function():void{
				loadBytes(_inputBytes,_ctx);
			},500);
		}
		
		public override function load(request:URLRequest, context:LoaderContext=null):void{
			if(stream==null){
				super.load(request,context);
			}else{
				_ctx = context;
				stream.load(request);
			}
		}
	}
}