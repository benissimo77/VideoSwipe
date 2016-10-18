package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.SearchVO;
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	import fl.events.ComponentEvent;
	import fl.managers.FocusManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * All visual elements related to searching
	 * Ben Silburn 2012 
	 */
	public class SearchInputView extends Sprite
	{
		private const WIDTH:int = 400;
		private const HEIGHT:int = 480;
		private const DEFAULTSEARCHTEXT:String = "Search YouTube...";
	

		private var _searchVO:SearchVO;	// cache local copy of the search object
		private var _searchInput:TextInput;
		private var _searchButton:FacebookButton;
		private var _categorySelect:ComboBox;
		private var _standardFeedsSelect:ComboBox;
		private var _timeSelect:ComboBox;
		
		public function SearchInputView() 
		{
			this.name = "searchInputView";
			initView();
			searchVO = new SearchVO();
			addListeners();
		}
		
		// initView - draw all elements of searchView
		private function initView():void
		{
			_searchInput = new TextInput();
			_searchInput.name = "input";
			_searchInput.height = 24;
			_searchInput.width = 240;
			//_searchInput.autoSize = TextFieldAutoSize.NONE;
			//_searchInput.type = TextFieldType.INPUT;
			//_searchInput.size = 22;
			//_searchInput.border = true;
			addChild(_searchInput);
			
			_searchButton = new FacebookButton("default", "SEARCH", 60, 24, false);
			_searchButton.name = "searchButton";
			_searchButton.x = 242;
			addChild(_searchButton);
			
			_standardFeedsSelect = new ComboBox();
			var _standardFeeds:Array = new Array();
			_standardFeeds.push( { label:"Any type...", data:"" } );
			_standardFeeds.push( { label:"Most recent", data:"most_recent" } );
			_standardFeeds.push( { label:"Most viewed", data:"most_viewed" } );
			_standardFeeds.push( { label:"Top rated", data:"top_rated" } );
			_standardFeeds.push( { label:"Most discussed", data:"most_discussed" } );
			_standardFeeds.push( { label:"Top favourites", data:"top_favorites" } );
			_standardFeeds.push( { label:"Most linked", data:"most_linked" } );
			_standardFeeds.push( { label:"Recently featured", data:"recently_featured" } );
			_standardFeeds.push( { label:"Most responded", data:"most_responded" } );
			_standardFeedsSelect.dataProvider = new DataProvider( _standardFeeds );
			_standardFeedsSelect.move(0, 40);
			//addChild(_standardFeedsSelect);

			_categorySelect = new ComboBox();
			var _categories:Array = new Array();
			_categories.push( { label:"Any category...", data:"" } );
			_categories.push( { label:"Autos & Vehicles", data:"Autos" } );
			_categories.push( { label:"Comedy", data:"Comedy" } );
			_categories.push( { label:"Education", data:"Education" } );
			_categories.push( { label:"Entertainment", data:"Entertainment" } );
			_categories.push( { label:"Film & Animation", data:"Film" } );
			_categories.push( { label:"Howto & Style", data:"Howto" } );
			_categories.push( { label:"Music", data:"Music" } );
			_categories.push( { label:"News & Politics", data:"News" } );
			_categories.push( { label:"People & Blogs", data:"People" } );
			_categories.push( { label:"Pets & Animals", data:"Pets" } );
			_categories.push( { label:"Science & Tech", data:"Science" } );
			_categories.push( { label:"Sports", data:"Sports" } );
			_categories.push( { label:"Travel & Events", data:"Travel" } );
			_categorySelect.dataProvider = new DataProvider(_categories);
			_categorySelect.move(108, 40);
			//addChild(_categorySelect);

			_timeSelect = new ComboBox();
			var _times:Array = new Array();
			_times.push( { label:"Any time...", data:"" } );
			_times.push( { label:"Today", data:"today" } );
			_times.push( { label:"This week", data:"this_week" } );
			_times.push( { label:"This month", data:"this_month" } );
			_timeSelect.dataProvider = new DataProvider(_times);
			_timeSelect.move(216, 40);
			//addChild(_timeSelect);
		}

		private function addListeners():void
		{
			_searchInput.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			//_searchInput.addEventListener(TextEvent.TEXT_INPUT, beginSearch);
			//_searchInput.addEventListener(ComponentEvent.ENTER, beginSearch);
			_searchButton.addEventListener(MouseEvent.CLICK, beginSearch);
			//_standardFeedsSelect.addEventListener(Event.CHANGE, beginSearch);
			//_categorySelect.addEventListener(Event.CHANGE, beginSearch);
			//_timeSelect.addEventListener(Event.CHANGE, beginSearch);
		}

		// we need a key handler here to stop the event bubbling up and being caught by the stage
		private function keyHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == 13) {
				beginSearch();
			}
			e.stopPropagation();
		}
		private function beginSearch(e:Event = null):void
		{
			updateVO();
			dispatchEvent( new Event("beginSearch", true, false) );
		}
		private function updateVO():void
		{
			_searchVO.searchText = (_searchInput.text == DEFAULTSEARCHTEXT) ? "" : _searchInput.text;
			_searchVO.standardFeed = _standardFeedsSelect.selectedItem ? _standardFeedsSelect.selectedItem.data : "";
			_searchVO.category = _categorySelect.selectedItem ? _categorySelect.selectedItem.data : "";
			_searchVO.timeperiod = _timeSelect.selectedItem ? _timeSelect.selectedItem.data : "";
		}

		public function get searchVO():SearchVO
		{
			return _searchVO;
		}
		public function get searchText():String
		{
			return _searchVO.searchText;
		}
		public function set searchVO(_s:SearchVO):void
		{
			_searchVO = _s;
			_searchInput.text = _s.searchText;
			//_standardFeedsSelect.selectedItem.data = _s.standardFeed
			//_categorySelect.selectedItem.data = _s.category;
			//_timeSelect.selectedItem.data = _s.timeperiod;
		}
	}

}