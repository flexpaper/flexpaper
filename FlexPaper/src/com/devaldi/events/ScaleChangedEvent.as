/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class ScaleChangedEvent extends Event
	{
		public static const SCALE_CHANGED:String = "onScaleChanged";
		public var scale:Number;
		
		public function ScaleChangedEvent(type:String,s:Number){
			super(type);
			scale=s;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new ScaleChangedEvent(type, scale);
		}
		
	}
}