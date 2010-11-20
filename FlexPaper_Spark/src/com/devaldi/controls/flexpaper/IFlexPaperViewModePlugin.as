package com.devaldi.controls.flexpaper
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
		
	public interface IFlexPaperViewModePlugin
	{
		function get Name():String;
		function get doZoom():Boolean;
		function get supportsTextSelect():Boolean;
		function initComponent(v:Viewer):Boolean;
		function initOnLoading():void;
		function setViewMode(s:String):void;
		function gotoPage(page:Number,adjGotoPage:int=0):void;
		function get currentPage():int;
		function renderPage(page:Number):void;
		function renderSelection(page:int,marker:ShapeMarker):void;
		function checkIsVisible(page:int):Boolean;
		function handleDoubleClick(event:MouseEvent):void;
		function get loaderListLength():int;
		function addChild(childindex:int,o:DisplayObject):void;
	}
}