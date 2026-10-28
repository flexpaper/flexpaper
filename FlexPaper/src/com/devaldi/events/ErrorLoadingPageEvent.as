/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/
package com.devaldi.events
{
	import flash.events.Event;
	
	public class ErrorLoadingPageEvent extends Event
	{
		public static const ERROR_LOADING_PAGE:String = "onErrorLoadingPage";
		
		public var pageNumber:Number;
		
		public function ErrorLoadingPageEvent(type:String,p:Number){
			super(type);
			pageNumber=p;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new ErrorLoadingPageEvent(type, pageNumber);
		}
		
	}
}