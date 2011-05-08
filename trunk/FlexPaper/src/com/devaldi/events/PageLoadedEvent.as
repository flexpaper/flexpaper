package com.devaldi.events
{
	import flash.events.Event;
	
	public class PageLoadedEvent extends Event
	{
		public static const PAGE_LOADED:String = "onPageLoaded";
		
		public var pageNumber:Number;
		
		public function PageLoadedEvent(type:String,p:Number){
			super(type);
			pageNumber=p;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new PageLoadedEvent(type, pageNumber);
		}
		
	}
}