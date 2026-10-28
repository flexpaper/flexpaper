/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class DocumentLoadedEvent extends Event
	{
		public static const DOCUMENT_LOADED:String = "onDocumentLoaded";
		
		public var totalPages:Number;
		
		public function DocumentLoadedEvent(type:String,p:Number){
			super(type);
			totalPages=p;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new DocumentLoadedEvent(type, totalPages);
		}
		
	}
}