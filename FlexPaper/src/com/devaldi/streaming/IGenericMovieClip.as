/* 
Copyright 2026 Devaldi Ltd

This file is part of FlowPaper, formerly known as FlexPaper.

Licensed under the MIT License. 
See LICENSE file in the project root for full license information.	
*/
package com.devaldi.streaming
{
	public interface IGenericMovieClip
	{
		function gotoAndStop(frame:int):void;
		function stop():void;
		function get width():Number;
		function get height():Number;
	}
}