/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class SwfLoadedEvent extends Event
	{
		public static const SWFLOADED:String = "onSwfLoadedEvent";
		public var swfObject:Object;
		
		public function SwfLoadedEvent(type:String,target:Object){
			super(type);
			swfObject=target;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new SwfLoadedEvent(type, swfObject);
		}
		
	}
}