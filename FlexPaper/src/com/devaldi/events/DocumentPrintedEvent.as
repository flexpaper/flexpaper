/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class DocumentPrintedEvent extends Event
	{
		public static const DOCUMENT_PRINTED:String = "onDocumentPrinted";
		
		public function DocumentPrintedEvent(type:String){
			super(type);
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new DocumentPrintedEvent(type);
		}
	}
}