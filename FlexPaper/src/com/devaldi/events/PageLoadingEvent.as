package com.devaldi.events
{
	import flash.events.Event;
	
	public class PageLoadingEvent extends Event
	{
		public static const PAGE_LOADING:String = "onPageLoading";
		
		public var pageNumber:Number;
		
		public function PageLoadingEvent(type:String,p:Number){
			super(type);
			pageNumber=p;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new PageLoadingEvent(type, pageNumber);
		}
		
	}
}