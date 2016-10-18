package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class PlaylistEvent extends Event 
	{
		public static const PLAYPLAYLISTITEM:String = "playPlaylistItem";
		public static const MOVEPLAYLISTITEM:String = "movePlaylistItem";
		public static const PLAYLISTTITLECHANGED:String = "playlistTitleChanged";
		
		private var _itemVO:VideoItemVO;
		private var _position:int;
		
		public function PlaylistEvent(type:String, vo:VideoItemVO=null, position:int=0, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_itemVO = vo;
			_position = position;
		} 
		
		public override function clone():Event 
		{ 
			return new PlaylistEvent(type, itemVO, position, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PlaylistEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get itemVO():VideoItemVO 
		{
			return _itemVO;
		}
		
		public function get position():int 
		{
			return _position;
		}
		
	}
	
}