package com.videoswipe.view.component 
{
		import flash.text.Font;
		import flash.text.TextFormat;
	/**
	 * ...
	 * @author 
	 */
	public class TF 
	{
		[Embed(source='assets/CENAN___.ttf'
		,fontFamily  ='CENA'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		//,unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E'
		//,unicodeRange='U+0020,U+003A-U+0040,U+0041-U+005A,U+0061-U+007A,U+0030-U+0039,U+002E'
		,unicodeRange='U+0020-007E'
		,embedAsCFF='false'
		)]
		private static const CENAFont:Class;

		[Embed(source='assets/OpenSans-Regular.ttf'
		,fontFamily  ='OpenSans'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		//,unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E'
		//,unicodeRange='U+0020,U+003A-U+0040,U+0041-U+005A,U+0061-U+007A,U+0030-U+0039,U+002E'
		,unicodeRange='U+0020-007E'
		,embedAsCFF='false'
		)]
		private static const OpenSansFont:Class;
		
		[Embed(source='assets/LucidaGrandeBold.ttf'
		,fontFamily  ='LucidaGrandeBold'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		//,unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E'
		//,unicodeRange='U+0020,U+003A-U+0040,U+0041-U+005A,U+0061-U+007A,U+0030-U+0039,U+002E'
		,unicodeRange='U+0020-007E'
		,embedAsCFF='false'
		)]
		private static const LucidaGrandeBold:Class;

		protected static var _defaultFont:String = "Verdana";
		protected static var _openSansFont:String = "OpenSans";
		protected static var _facebookFont:String = "LucidaGrandeBold";
		protected static var _helpSlideFont:String = "CENA";
		protected static var _defaultSize:int = 12;
		protected static var _defaultColor:uint = 0xECECEC;
		protected static var _facebookColor:uint = 0xffffff;	// white text on blue background
		protected static var _helpSlideColor:uint = 0xffffff;
		protected static var _anchorColor:uint = 0xFFB100;
		protected static var _headerSize:int = 16;
		protected static var _smallSize:int = 9;

		public function TF() 
		{
			// static functions this class it never instantiated
		}
		
		public static function registerFonts():void
		{
			Font.registerFont(LucidaGrandeBold);
			Font.registerFont(CENAFont);
			Font.registerFont(OpenSansFont);
		}
		public static function get defaultTF():TextFormat
		{
			return new TextFormat(_defaultFont, _defaultSize, _defaultColor);
		}
		public static function get facebookTF():TextFormat
		{
			return new TextFormat(_facebookFont, _defaultSize, _facebookColor);
		}
		public static function get helpSlideTF():TextFormat
		{
			return new TextFormat(_helpSlideFont, _defaultSize, _helpSlideColor);
		}
		public static function get openSansTF():TextFormat
		{
			return new TextFormat( _openSansFont, _defaultSize, _defaultColor );
		}
		public static function get anchorTF():TextFormat
		{
			var _d:TextFormat = defaultTF;
			_d.color = _anchorColor;
			_d.underline = true;
			return _d;
		}
		public function get headerTF():TextFormat
		{
			var _d:TextFormat = defaultTF;
			_d.size = _headerSize;
			return _d;
		}
		
		public static function get defaultFont():String
		{
			return _defaultFont;
		}
		public static function get defaultSize():int
		{
			return _defaultSize;
		}
		public static function get defaultColour():uint
		{
			return _defaultColor;
		}
		public static function get anchorColour():uint
		{
			return _anchorColor;
		}
		public static function get headerSize():int
		{
			return _headerSize;
		}
		public static function get smallSize():int
		{
			return _smallSize;
		}
	}

}