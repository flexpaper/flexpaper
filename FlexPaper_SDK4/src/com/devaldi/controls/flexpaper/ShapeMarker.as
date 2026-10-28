/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/
	
package com.devaldi.controls.flexpaper
{
	import flash.display.Sprite;
	
	public class ShapeMarker extends Sprite
	{
		public var PageIndex:int = -1;
		public var data:Object = null;
		public var minX:Number;
		public var minY:Number;
		public var maxX:Number;
		public var maxY:Number;
		public var isSearchMarker:Boolean = false;
		public var flagged:Boolean = false;
		
		public function ShapeMarker()
		{
		}		
	}
}