/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class InternalLinkClickedEvent extends Event
	{
		public var pagenumber:int;
		public static const INTERNALLINK_CLICKED:String = "onInternalLinkClicked";
		
		public function InternalLinkClickedEvent(type:String,lpagenumber:int)
		{
			super(type);
			pagenumber=lpagenumber;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new InternalLinkClickedEvent(type, pagenumber);
		}
	}
}