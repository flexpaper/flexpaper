/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class ExternalLinkClickedEvent extends Event
	{
		public var link:String;
		public static const EXTERNALLINK_CLICKED:String = "onExternalLinkClicked";
		
		public function ExternalLinkClickedEvent(type:String,llink:String)
		{
			super(type);
			link=llink;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new ExternalLinkClickedEvent(type, link);
		}
	}
}