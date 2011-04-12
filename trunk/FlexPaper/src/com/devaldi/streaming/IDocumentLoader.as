package com.devaldi.streaming
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public interface IDocumentLoader extends IEventDispatcher
	{
		function get DocumentContainer():DisplayObject;
		function get LoaderList():Array;
		function set LoaderList(v:Array):void;
		function postProcessBytes(b:ByteArray):void;
		function load(request:URLRequest, loaderCtx:LoaderContext):void;
		function resetURLStream():void;
		function signFileHeader(bytes:ByteArray, ldr:Loader=null):void;
		function get InputBytes():ByteArray;
		function set InputBytes(b:ByteArray):void;
		function get Resigned():Boolean;
		function get stream():URLStream;	
	}
}