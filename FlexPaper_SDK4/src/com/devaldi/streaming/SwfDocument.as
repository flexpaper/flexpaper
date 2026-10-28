/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/
package com.devaldi.streaming
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.text.TextSnapshot;
	
	public class SwfDocument implements IGenericDocument{
		private var _mc:MovieClip;
		
		public function  SwfDocument(mc:DisplayObject){
			if(mc is MovieClip)
				_mc = mc as MovieClip;
			else if(mc is Bitmap){
				_mc = new MovieClip();
				_mc.addChild(mc);
			}
		}
		
		public function gotoAndStop(pagNumber:int):void{
			_mc.gotoAndStop(pagNumber);
		}
		
		public function nextFrame():void{
			_mc.nextFrame();
			_mc.stop();
		}
		
		public function stop():void{
			_mc.stop();
		}
		
		public function getDocument():DisplayObject{
			return _mc;
		}
		
		public function get parent():DisplayObject{
			return _mc.parent;
		}
		
		public function get totalFrames():int{
			return _mc.totalFrames;
		}
		
		public function get framesLoaded():int{
			return _mc.framesLoaded;
		}
		
		public function get textSnapshot():TextSnapshot{
			return _mc.textSnapshot;
		}
		
		public function set alpha(value:Number):void{
			_mc.alpha = value;
		}
		
		public function get currentFrame():int{
			return _mc.currentFrame;
		}
		
		public function get height():Number{
			return _mc.height;
		}
		
		public function get width():Number{
			return _mc.width;
		}
		
		public function get loaderInfo():LoaderInfo{
			return _mc.loaderInfo;
		}
		
		public function set scaleX(n:Number):void{
			_mc.scaleX = n;
		}
		
		public function set scaleY(n:Number):void{
			_mc.scaleY = n;
		}
	}
}