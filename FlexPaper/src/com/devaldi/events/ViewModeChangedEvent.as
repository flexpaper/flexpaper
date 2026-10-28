/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;

	public class ViewModeChangedEvent extends Event
	{
		public static const VIEWMODE_CHANGED:String = "onViewModeChanged";
		public var viewMode:String;
		
		public function ViewModeChangedEvent(type:String,viewmode:String)
		{
			super(type);
			viewMode = viewmode;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new ViewModeChangedEvent(type, viewMode);
		}
	}
}