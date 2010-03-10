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

package com.devaldi.streaming
{
	import mx.controls.Image;
	import flash.display.MovieClip;
	
	public class DupImage extends Image
	{
		public var dupIndex:int = 0;
	
		public function DupImage()
		{
		
		}
		
		override public function set source(value:Object):void{
			super.source = value;
			
			if(value!=null && (value is MovieClip) && value.content != null){
				value.content.stop();
			}
		}
		
		public function removeAllChildren():void{
			for(var i:int=0;i<this.numChildren;i++){
				delete(this.removeChildAt(0));
			}
		}
	}
}