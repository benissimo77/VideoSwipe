package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.SearchVO;
	import flash.events.Event;
	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class SearchView extends GlassSprite
	{
		private var _searchText:EditableTextField;
		private var _searchButton:FacebookButton;
		private var _searchVO:SearchVO;
		
		public function SearchView() 
		{
			super();
			_searchVO = new SearchVO();
			initView();
		}
		
		private function initView():void
		{
			_searchText = new EditableTextField();
			_searchText.width = 180;
			_searchText.height = 24;
			_searchText.useBorder = true;
			_searchText.borderColor = 0x111111;
			_searchText.defaultText = "Search YouTube...";
			_searchText.addEventListener( Event.COMPLETE, beginSearch );
			addChild(_searchText);
			
			_searchButton = new FacebookButton( "facebook", "SEARCH", 60, 24, false );
			_searchButton.x = 184;
			_searchButton.y = 0;
			addChild(_searchButton);
		}

		private function beginSearch(e:Event):void
		{
			e.stopPropagation();
			_searchVO.searchText = _searchText.text;
			dispatchEvent( new Event("beginSearch", true, false) );
		}
		
		public function get searchVO():SearchVO 
		{
			return _searchVO;
		}
	}

}