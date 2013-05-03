/* 
Copyright 2009 Erik Engström

This file is part of FlexPaper.

FlexPaper is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

FlexPaper is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FlexPaper.  If not, see <http://www.gnu.org/licenses/>.	
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
		
		public var minNormX:Number;
		public var minNormY:Number;
		public var maxNormX:Number;
		public var maxNormY:Number;
		
		public var isSearchMarker:Boolean = false;
		public var flagged:Boolean = false;
		public var isDragging:Boolean = false;
		
		public function ShapeMarker()
		{
		}		
	}
}