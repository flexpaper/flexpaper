package com.devaldi.streaming
{
	import flash.display.MovieClip;

	public interface ITextSelectableDisplayObject
	{
		function getMovieClip():MovieClip;	
		function getPageIndex():int;
		function setTextSelectMode():void;
		function unSetTextSelectMode():void;
	}
}