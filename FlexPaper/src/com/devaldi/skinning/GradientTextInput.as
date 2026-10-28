/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/

package com.devaldi.skinning 
{
	import flash.events.Event;
	import flash.filters.*;
	
	import mx.controls.TextInput;
	import mx.events.*;
	
	public class GradientTextInput extends mx.controls.TextInput
	{
		public function GradientTextInput()
		{
			super();
		}
		
		override public function set enabled(value:Boolean):void{
			super.enabled = value;
			enableHandler(null);
		}		
		
		private function enableHandler(event:Event):void
		{
			// define the color filter
			var matrix:Array = new Array();
			
			if (!enabled)
			{
				matrix = matrix.concat([0.31, 0.61, 0.08, 0, 0]); 	// red
				matrix = matrix.concat([0.31, 0.61, 0.08, 0, 0]); 	// green
				matrix = matrix.concat([0.31, 0.61, 0.08, 0, 0]); 	// blue
				matrix = matrix.concat([0, 0, 0, 0.3, 0]); 			// alpha
			}
			else
			{
				matrix = matrix.concat([1, 0, 0, 0, 0]); 	// red
				matrix = matrix.concat([0, 1, 0, 0, 0]); 	// green
				matrix = matrix.concat([0, 0, 1, 0, 0]); 	// blue
				matrix = matrix.concat([0, 0, 0, 1, 0]); 	// alpha
			}
			
			var filter:BitmapFilter = new ColorMatrixFilter(matrix);
			
			// apply color filter
			filters = new Array(filter) ;
		}

	}
}