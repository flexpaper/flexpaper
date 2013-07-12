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


package com.devaldi.controls.flexpaper.utils
{
	import com.devaldi.controls.flexpaper.resources.MenuIcons;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	
	public class FlexPaperCursorManager {
		public static const AUTO:String					= MouseCursor.AUTO;
		public static const GRAB:String 				= "handGrab";
		public static const GRABBING:String 			= "handGrabbing";				
		public static const TEXT_SELECT_CURSOR:String   = "textSelectCursor";
		public static const ADDELEMENT_CURSOR:String 	= "addElementCursor";
		public static const RESIZE_HORIZONTAL_CURSOR:String 				= "resizeHorizontallyCursor";
		public static const RESIZE_VERTICAL_CURSOR:String 					= "resizeVerticallyCursor";
		public static const RESIZE_VERTICAL_HORIZONTAL_CURSOR:String 		= "resizeVerticallyHorizontallyCursor";
		
		[Embed('assets/cursor-addelement.png')]
		public static const CURSOR_ADDELEMENT_IMAGE:Class;
		
		[Embed('assets/horizontal_size_cursor.gif')]
		public static const CURSOR_RESIZE_HORIZONTAL_IMAGE:Class;
		
		[Embed('assets/vertical_size_cursor.gif')]
		public static const CURSOR_RESIZE_VERTICAL_IMAGE:Class;		
		
		[Embed('assets/horizontal_vertical_size_cursor.png')]
		public static const CURSOR_RESIZE_VERTICAL_HORIZONTAL_IMAGE:Class;		
		
		public function CursorManager() { 
			
		}
		
		public static function init():void {
			initCursors();
		}
		
		private static function initCursors():void {
			var vector:Vector.<int> = new Vector.<int>();

			var c1:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c1[0] = new MenuIcons.GRAB().bitmapData;
			var mcd1:MouseCursorData = new MouseCursorData();
			mcd1.hotSpot = new Point(0,0);
			mcd1.data = c1;
			Mouse.registerCursor(GRAB, mcd1);
			
			var c2:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c2[0] = new MenuIcons.GRABBING().bitmapData;
			var mcd2:MouseCursorData = new MouseCursorData();
			mcd2.hotSpot = new Point(0,0);
			mcd2.data = c2;
			Mouse.registerCursor(GRABBING, mcd2);
			
			var c3:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c3[0] = new MenuIcons.TEXT_SELECT_CURSOR().bitmapData;
			var mcd3:MouseCursorData = new MouseCursorData();
			mcd3.hotSpot = new Point(0,0);
			mcd3.data = c3;
			Mouse.registerCursor(TEXT_SELECT_CURSOR, mcd3);
			
			var c4:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c4[0] = new CURSOR_ADDELEMENT_IMAGE().bitmapData;
			var mcd4:MouseCursorData = new MouseCursorData();
			mcd4.hotSpot = new Point(8,8);
			mcd4.data = c4;
			Mouse.registerCursor(ADDELEMENT_CURSOR, mcd4);
			
			
			var c6:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c6[0] = new CURSOR_RESIZE_HORIZONTAL_IMAGE().bitmapData;
			var mcd6:MouseCursorData = new MouseCursorData();
			mcd6.hotSpot = new Point(8,8);
			mcd6.data = c6;
			Mouse.registerCursor(RESIZE_HORIZONTAL_CURSOR, mcd6);
			
			var c5:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c5[0] = new CURSOR_RESIZE_VERTICAL_IMAGE().bitmapData;
			var mcd5:MouseCursorData = new MouseCursorData();
			mcd5.hotSpot = new Point(8,8);
			mcd5.data = c5;
			Mouse.registerCursor(RESIZE_VERTICAL_CURSOR, mcd5);
			
			var c5:Vector.<BitmapData> = new Vector.<BitmapData>(1,true);
			c5[0] = new CURSOR_RESIZE_VERTICAL_HORIZONTAL_IMAGE().bitmapData;
			var mcd5:MouseCursorData = new MouseCursorData();
			mcd5.hotSpot = new Point(8,8);
			mcd5.data = c5;
			Mouse.registerCursor(RESIZE_VERTICAL_HORIZONTAL_CURSOR, mcd5);
			
		}
	}
}