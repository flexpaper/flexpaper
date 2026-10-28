/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import com.devaldi.controls.flexpaper.ShapeMarker;
	import flash.events.Event;
	
	public class InteractionElementEditedEvent extends Event
	{
		public static const INTERACTIONELEMENT_EDITED:String = "onInteractionElementEdited";
		public var Marker:ShapeMarker;
		
		public function InteractionElementEditedEvent(type:String,sm:ShapeMarker){
			Marker = sm;
			super(type);
		}
		
		override public function clone():Event {
			return new InteractionElementEditedEvent(type, Marker);
		}
	}
}