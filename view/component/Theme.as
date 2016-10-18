package com.videoswipe.view.component 
{
	/**
	 * (c) Ben Silburn
	 * A simple class for persisting the colour scheme used in the app
	 */
	public class Theme 
	{
		private static var _GLASSTINT:int = 0x282828;
		private static var _EDGETINT:int = 0x000000;
		private static var _HIGHLIGHTTINT:int = 0x535353;
		private static var _TEXTSTANDARD:int = 0xececec;
		private static var _TEXTHIGHLIGHT:int = 0xFFB100;
		private static var _TEXTFACEBOOKFILL:int = 0x5B74A8;	// 0x5B74A8 is taken from a button on facebook
		private static var _TEXTFACEBOOKEDGE:int = 0x29447E;
		private static var _TEXTFACEBOOKMOUSEOVER:int = 0x8Ba4d8;
		private static var _BACKGROUND:int = 0x686868;
		private static var _GLASSALPHA:Number = 0.8;
		
		public function Theme() 
		{
			// static class never instantiated
		}
		static public function get GLASSTINT():int 
		{
			return _GLASSTINT;
		}
		
		static public function get EDGETINT():int 
		{
			return _EDGETINT;
		}
		
		static public function get HIGHLIGHTTINT():int 
		{
			return _HIGHLIGHTTINT;
		}
		
		static public function get BACKGROUND():int 
		{
			return _BACKGROUND;
		}
		
		static public function get GLASSALPHA():Number 
		{
			return _GLASSALPHA;
		}
		
		static public function get TEXTSTANDARD():int 
		{
			return _TEXTSTANDARD;
		}
		
		static public function get TEXTHIGHLIGHT():int 
		{
			return _TEXTHIGHLIGHT;
		}
		
		static public function get TEXTFACEBOOKFILL():int 
		{
			return _TEXTFACEBOOKFILL;
		}
		
		static public function get TEXTFACEBOOKEDGE():int 
		{
			return _TEXTFACEBOOKEDGE;
		}
		
		static public function get TEXTFACEBOOKMOUSEOVER():int 
		{
			return _TEXTFACEBOOKMOUSEOVER;
		}
	}

}