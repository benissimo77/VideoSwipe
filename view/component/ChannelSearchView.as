package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.FeedVO;
	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class ChannelSearchView extends GlassSprite
	{
		private var searchInput:SearchInputView;
		private var youTubeChannelList:ChannelListView;
		
		public const WIDTH:int = 600;
		
		public function ChannelSearchView() 
		{
			super();
			this.name = "channelSearchView";
			initView();
		}
		
		private function initView():void
		{
			searchInput = new SearchInputView();
			youTubeChannelList = new ChannelListView();
			
			addChild(searchInput);
			addChild(youTubeChannelList);
			searchInput.y = 4;
			youTubeChannelList.y = 36;
		}

		override public function redraw():void
		{
			youTubeChannelList.setSize(_width, _height - 36);
		}
		
		public function get channelListView():ChannelListView
		{
			return youTubeChannelList;
		}
		public function get searchInputView():SearchInputView 
		{
			return searchInput;
		}
	}

}