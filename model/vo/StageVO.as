package com.videoswipe.model.vo 
{
	import com.videoswipe.view.component.NetConnectionView;
	import com.videoswipe.view.component.SearchView;
	/**
	 * ...
	 * @author 
	 */
	public class StageVO 
	{
		private var _ncView:NetConnectionView;
		private var _searchView:SearchView;
		
		public function StageVO() 
		{}
		
		public function get ncView():NetConnectionView 
		{
			return _ncView;
		}
		
		public function set ncView(value:NetConnectionView):void 
		{
			_ncView = value;
		}
		
		public function get searchView():SearchView 
		{
			return _searchView;
		}
		
		public function set searchView(value:SearchView):void 
		{
			_searchView = value;
		}
		
	}

}