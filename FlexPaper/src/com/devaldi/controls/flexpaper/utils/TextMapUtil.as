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
	
	public class TextMapUtil
	{
		public static function checkUnicodeIntegrity(s:String, search:String=null):String{
			s = ((search!=null&&search.indexOf("fl")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57394),"fl"):s;
			s = ((search!=null&&search.indexOf("fi")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57345),"fi"):s;
			s = ((search!=null&&search.indexOf("fi")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57393),"fi"):s;
			s = ((search!=null&&search.indexOf("fi")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57370),"fi"):s;
			s = ((search!=null&&search.indexOf("f")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57385),"f"):s;
			s = ((search!=null&&search.indexOf("f")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57374),"f"):s;
			s = ((search!=null&&search.indexOf("f")>=0)||search==null)?StringReplaceAll(s,String.fromCharCode(57396),"f"):s;
			
			return s;	
		}
		
		public static function StringReplaceAll( source:String, find:String, replacement:String ) : String
		{
			return source.split( find ).join( replacement );
		}
		
	}
}