package com.videoswipe.model.vo 
{
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
	public class ChannelVO
	{
		public var provider:String;
		public var thumbnailURL:String;
		public var channelTitle:String;
		public var channelDescription:String;
		public var updated:String;
		public var views:Number;
		public var numlikes:String;
		public var channelID:String;
		
		public function ChannelVO( xml:XML = null ) 
		{ }
		
		public function fillFromObject(_o:Object):void
		{
			for (var i:String in _o) {
				this[i] = _o[i];
			}
		}
	}

}