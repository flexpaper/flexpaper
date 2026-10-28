/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.events
{
	import flash.events.Event;
	
	public class SearchAbstractsDownloadedEvent extends Event
	{
		public static const SEARCHABSTRACT_DOWNLOADED:String = "onSearchAbstractsDownloaded";
		public var endIndex:Number;
		public var searchText:String = "";
		
		public function SearchAbstractsDownloadedEvent(type:String,s:Number, st:String){
			super(type);
			endIndex=s;
			searchText=st;
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new SearchAbstractsDownloadedEvent(type, endIndex, searchText);
		}
		
	}
}