package com.devaldi.streaming
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.text.TextSnapshot;

	public interface IGenericDocument
	{
		function gotoAndStop(pagNumber:int):void;
		function stop():void;
		function getDocument():DisplayObject;
		function get parent():DisplayObject;
		function get totalFrames():int;
		function get framesLoaded():int;
		function get textSnapshot():TextSnapshot;
		function set alpha(value:Number):void;
		function get currentFrame():int;
		function get height():Number;
		function get width():Number;
		function get loaderInfo():LoaderInfo;
		function set scaleX(n:Number):void;
		function set scaleY(n:Number):void;
	}
}