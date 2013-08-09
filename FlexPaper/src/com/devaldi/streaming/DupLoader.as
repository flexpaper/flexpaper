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
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
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