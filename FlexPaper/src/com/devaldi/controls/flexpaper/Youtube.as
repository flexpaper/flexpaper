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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
        
	public class Youtube extends Canvas 
	{
		[Bindable]
		private var _loader:Loader = new Loader(); 
        private var _player:Object;  
        private var _videoId:String;
		private var _state:int = -1;
        private var _chromeless:Boolean = false;
		private var _viewer:Viewer;
		
        public function Youtube(v:Viewer)
        { 
        	super();
			
			_viewer = v;
			
			if(!_viewer.DesignMode){
				Security.allowDomain("www.youtube.com");
	        	Security.allowDomain("video-stats.video.google.com");
			}
			
			if(_chromeless){
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderInit);
				_loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
	  
				//add loader to our component
				this.width = 480;this.height = 270;
				var uic:UIComponent = new UIComponent();
				uic.addChild(_loader);
				addChild(uic);
			}
        }
		
		//get movie state
		public function get loader():Loader
		{
			return _loader;
		}
   
		//get movie state
		public function get state():int
		{
			return _state;
		}

		//set youtube video ID
        public function set videoId(v:String):void
        {
        	_videoId = v;
			
			if(!_chromeless){
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderInit);
				_loader.load(new URLRequest("http://www.youtube.com/v/"+_videoId+"?version=3&modestbranding=1&showinfo=0&rel=0&autohide=0"));
				this.width = 480;this.height = 270;
				var uic:UIComponent = new UIComponent();
				uic.addChild(_loader);
				addChild(uic);
			}
        }
 
		//stop movie
 		public function stop():void
 		{
			if ( _player != null )
 				_player.stopVideo();
 		}
 
		//play movie
 		public function play():void
 		{
			if ( _player != null )
 				_player.playVideo();
 		}
 		
		//pause movie
 		public function pause():void
 		{
			if ( _player != null )
 				_player.pauseVideo();
 		}
 		
		//mute movie
 		public function mute():void
 		{
			if ( _player != null )
 				_player.mute();
 		}
 
		//unmute movie
 		public function unMute():void
 		{
			if ( _player != null )
 			 _player.unMute();
 		}
		
		//check if the sound it's muted
		public function isMuted():Boolean
		{
			return _player.isMuted();
		}
		
		//get sound volume
		public function getVolume():Number
		{
			return _player.getVolume();
		}
		
		//set sound volume (0-100);
		public function setVolume(v:Number):void
		{
			_player.setVolume(v);
		}
 		
		//seek to second
 		public function seekTo(v:Number):void
 		{
			if ( _player != null )
 				_player.seekTo(v,true)
 		}
  
		//total movie duration in seconds
 		public function getDuration():int
		{
			if ( _player != null )
				return int(_player.getDuration());
			else
				return -1;	
		} 
		
		//current movie second
		public function getCurrentTime():int
		{
			if ( _player != null )
				return int(_player.getCurrentTime());
			else
				return -1;	
		}
		
		//set events for our movie
		private function onLoaderInit(event:Event):void {
		     
		    _loader.content.addEventListener("onReady", onPlayerReady);
		    _loader.content.addEventListener("onError", onPlayerError);
		    _loader.content.addEventListener("onStateChange", onPlayerStateChange);
		    _loader.content.addEventListener("onPlaybackQualityChange",  onVideoPlaybackQualityChange);
		}
		
		private function onPlayerReady(event:Event):void {
		     trace("player ready:", Object(event).data);
		
		    _player = _loader.content;
		    _player.loadVideoById(_videoId);
		    _player.setSize(480,270);   
		}
		
		private function onPlayerError(event:Event):void {
		    // Event.data contains the event parameter, which is the error code
		    trace("player error:", Object(event).data);
		}
		
		private function onPlayerStateChange(event:Event):void {
		    // Event.data contains the event parameter, which is the new player state
			_state = int(Object(event).data);
		}
		
		private function onVideoPlaybackQualityChange(event:Event):void {
		    // Event.data contains the event parameter, which is the new video quality
		    trace("video quality:", Object(event).data);
		} 
	}
}