package com.videoswipe.model.vo
{
	/**
	 * HelpFeedbackVO
	 * stores status of the help and feedback slides that this user has seen
	 * prevents giving the same user the same slide multiple times
	 * coordinates sending/receiving data between client and the DB
	 * 
	 */
	public class UserManagerVO 
	{
		public var uid:String;	// the uid of this user (used to determine what they have/haven't seen)
		public var name:String;	// the name of this user (personal!)
		public var helpSlide:int;	// integer represents the help slides seen (binary digits)
		public var feedbackSlide:int;	// integer represents the feedback slides completed (binary digits)
		public var isFacebookUser:Boolean;
		
		public function UserManagerVO( _f:Object=null )
		{
			uid = "";
			name = "";
			helpSlide = 0;
			feedbackSlide = 0;
			isFacebookUser = false;
			if (_f) fillFromObject(_f);
		}
		
		public function fillFromObject(_o:Object):void
		{
			if (_o.name) name = _o.name;
			if (_o.uid) uid = _o.uid;
			if (_o.helpSlide) helpSlide = _o.helpSlide;
			if (_o.feedbackSlide) feedbackSlide = _o.feedbackSlide;
			if (_o.connected) isFacebookUser = true;
		}
		
		
	}

}