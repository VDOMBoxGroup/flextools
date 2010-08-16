/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.thread
{
	import flash.events.Event;

	public class ThreadEvent extends Event
	{
		public static const THREAD_READY:String = 'threadReady';
		public static const PROGRESS:String = 'progress';
		
		
		public var thread:IThread;
		
		public function ThreadEvent(type:String, thread:IThread)
		{
			this.thread = thread;
			super(type, false, false);
		}
		
	}
}