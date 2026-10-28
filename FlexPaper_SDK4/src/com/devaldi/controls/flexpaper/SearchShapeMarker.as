/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.controls.flexpaper
{
	public class SearchShapeMarker extends ShapeMarker
	{
		public var searchPhrase:String = "";
		
		public function SearchShapeMarker()
		{
			super.isSearchMarker = true;
		}
	}
}