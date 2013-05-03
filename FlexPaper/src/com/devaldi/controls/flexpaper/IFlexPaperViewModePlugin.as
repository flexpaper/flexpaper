package com.devaldi.controls.flexpaper
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextSnapshot;
	
	import mx.core.UIComponent;
		
	public interface IFlexPaperViewModePlugin
	{
		function get Name():String;
		function get doZoom():Boolean;
		function get doFitHeight():Boolean;
		function get doFitWidth():Boolean;
		function get supportsTextSelect():Boolean;
		function initComponent(v:Viewer):Boolean;
		function initOnLoading():void;
		function setViewMode(s:String, viewer:Viewer):void;
		function gotoPage(page:Number,adjGotoPage:int=0,interactive:Boolean=false):void;
		function get currentPage():int;
		function renderPage(page:Number):void;
		function renderSelection(page:int,marker:ShapeMarker):void;
		function checkIsVisible(page:int):Boolean;
		function handleDoubleClick(event:MouseEvent):void;
		function handleMouseDown(event:MouseEvent):void;
		function handleMouseUp(event:MouseEvent):void;
		function get loaderListLength():int;
		function addChild(childindex:int,o:DisplayObject):void;
		function get SaveScale():Number;
		function set SaveScale(n:Number):void;
		function mvNext(interactive:Boolean=false):void;
		function mvPrev(interactive:Boolean=false):void;
		function renderMark(sm:UIComponent,pageIndex:int):void;
		function translatePageNumber(pn:Number):Number;
		function getPageTextSnapshot(pn:Number):TextSnapshot;
		function setTextSelectMode(pn:Number):void;
		function unsetTextSelectMode(pn:Number):void;
		function clearSearch():void;
		function disposeViewMode():void;
		function getNormalizationHeight(pageIndex:Number):Number;
		function getNormalizationWidth(pageIndex:Number):Number;
	}
}