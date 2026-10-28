/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class CursorModeChangedEvent extends Event
	{
		public static const CURSORMODE_CHANGED:String = "onCursorModeChanged";
		public var cursorMode:String;
		
		public function CursorModeChangedEvent(type:String,cursormode:String)
		{
			super(type);
			cursorMode = cursormode;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new CursorModeChangedEvent(type, cursorMode);
		}
	}
}