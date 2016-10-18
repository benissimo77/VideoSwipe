/*
   Simple Command - PureMVC
 */
package com.videoswipe.controller
{
	import com.videoswipe.ApplicationFacade;
	import com.videoswipe.model.vo.FeedVO;
	import com.videoswipe.model.vo.VideoVO;
	import com.videoswipe.view.VideoMediator;
	import com.videoswipe.view.VideoItemView;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * SimpleCommand
	 */
	public class FeedResultCommand extends SimpleCommand
	{
		
		override public function execute(note:INotification):void
		{
			
			trace("FeedResultCommand:: hello.");
			var feed:FeedVO = note.getBody() as FeedVO;
			var video:VideoVO = feed.firstVideo;
			
			// items used in the youTube example shot:
			// http://code.google.com/apis/youtube/2.0/developers_guide_protocol_displaying_list_of_videos.html
			
			// 1. title for the result set
			trace("Feed title:", feed.title);
			
			// 2. range of videos in the feed
			trace("Range:", feed.startIndex, "-", feed.itemsPerPage, "of", feed.totalResults);
			
			// 3. drop-down - ignore
			
			// 4. thumbnail
			trace("Video thumbnailURL:", video.thumbnailURL);
			
			// 5. video title (different from title???)
			trace("Video title:", video.videoTitle);
			
			// 6. publish details
			trace("Published:", video.published);
			trace("Author name:", video.authorName);
			trace("Views:", video.views);
			trace("Rating:", video.rating);
			trace("Num likes:", video.numlikes);
			trace("Duration:", video.duration);
			trace("Category:", video.category);
			
			// Extra
			trace("VideoID:", video.videoID);
			
			/*
			 * below code works well, but consider using FeedView instead...
			var videos:Vector.<VideoVO> = feed.videos;
			for each (video in videos)
			{
				var v:VideoItemView = new VideoItemView(video);
				sendNotification(ApplicationFacade.ADDVIDEOITEM, v);
			}
			*/
		}
	
	}
}