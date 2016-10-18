package com.videoswipe.model.vo 
{
	import com.videoswipe.model.VideoMessageProxy;
	/**
	 * ...
	 * @author  Ben Silburn
	 * 
	 * VideoItemVO
	 * a generic class for holding all data for a video item
	 * it is provider-independent meaning it can be used for all video providers, it stores the name of the provider so
	 * anyone using this class will know where to retrieve the actual video
	 * designed to be extended by the concrete classes for each provider (these will also set the provider var)
	 */
	public class PlaylistItemVO extends VideoItemVO
	{
		private var _videoMessages:Vector.<VideoMessageVO>;
		
		public function PlaylistItemVO( _x:XML = null ) 
		{
			super(_x);
			_videoMessages = new Vector.<VideoMessageVO>;
		}
		
		public function addVideoMessage( _v:VideoMessageVO ):void
		{
			_videoMessages.push( _v );
		}
		public function deleteVideoMessage( _v:VideoMessageVO ):void
		{
			trace("VideoItemVO:: deleteVideoMessage: TODO!" );
		}
		
		public function get videoMessages():Vector.<VideoMessageVO> 
		{
			return _videoMessages;
		}
	}

}