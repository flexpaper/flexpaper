/*
Copyright 2009 Erik Engström
 
This file is part of FlexPaper.

FlexPaper is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FlexPaper is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FlexPaper.  If not, see <http://www.gnu.org/licenses/>.	
*/

package com.devaldi.controls
{
import flash.geom.*;
import flash.utils.getDefinitionByName;
import mx.containers.Canvas;

/**
 * ZoomCanvas; Provides basic center zooming functionality.
 *             Use CenteringEnabled(true/false) to turn on and off.  
 */
public class ZoomCanvas extends Canvas {
  
	  public var CenteringEnabled:Boolean = false;
	  
	  public function ZoomCanvas() {
	   super();
	  }
	  
	  override protected function createChildren():void {
		super.createChildren();
	  }
		
	  override public function validateDisplayList():void{
		   
		   var centerPercentX:Number = 0;
		   var centerPercentY:Number = 0;
		   
		   if (maxHorizontalScrollPosition > 0) {
				centerPercentX = horizontalScrollPosition / maxHorizontalScrollPosition;
		   } else {
				centerPercentX = 0.5;
		   }
		   
		   if (maxVerticalScrollPosition > 0) {
				centerPercentY = verticalScrollPosition / maxVerticalScrollPosition;
		   } else {
				centerPercentY = 0.5;
		   }
		   
		   super.validateDisplayList();
			   if(CenteringEnabled){
			   
			   if (maxHorizontalScrollPosition > 0) {
					var newHScrollPosition:Number = maxHorizontalScrollPosition * centerPercentX;
					newHScrollPosition = newHScrollPosition > 0 ? newHScrollPosition : 0;
					newHScrollPosition = newHScrollPosition < maxHorizontalScrollPosition ? newHScrollPosition : maxHorizontalScrollPosition;
					horizontalScrollPosition = newHScrollPosition;
			   }
			   
			   if (maxVerticalScrollPosition > 0) {
					var newVScrollPosition:Number = maxVerticalScrollPosition * centerPercentY;
					newVScrollPosition = newVScrollPosition > 0 ? newVScrollPosition : 0;
					newVScrollPosition = newVScrollPosition < maxVerticalScrollPosition ?  newVScrollPosition : maxVerticalScrollPosition;
					verticalScrollPosition = newVScrollPosition;
			   }
	 		}
		}
	}
}