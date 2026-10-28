/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class CurrentPageChangedEvent extends Event
	{
		public static const PAGE_CHANGED:String = "onCurrPageChanged";
		public var pageNum:Number;
		public var prevPageNum:Number;
		public var interactive:Boolean=false;
		
		public function CurrentPageChangedEvent(type:String,p:Number,pp:Number,inter:Boolean=false){
			super(type);
			pageNum=p;
			prevPageNum=pp;
			interactive=inter;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new CurrentPageChangedEvent(type, pageNum,prevPageNum);
		}
		
	}
}