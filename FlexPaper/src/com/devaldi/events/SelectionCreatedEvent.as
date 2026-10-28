/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class SelectionCreatedEvent extends Event
	{
		public static const SELECTION_CREATED:String = "onSelectionCreated";
		public var text:String;
		
		public function SelectionCreatedEvent(type:String,s:String){
			super(type);
			text=s;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new SelectionCreatedEvent(type, text);
		}
		
	}
}