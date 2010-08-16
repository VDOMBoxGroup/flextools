/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.thread
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	[Event(name="threadReady", type="ro.victordramba.thread.ThreadEvent")]
	[Event(name="progress", type="ro.victordramba.thread.ThreadEvent")]
	
	public class ThreadsController extends EventDispatcher
	{
		private var sliceTime:int = 100;
		private var uiEvent:Boolean;
		private var stage:Stage;
		private var endUIID:int;
		
		function ThreadsController(stage:Stage)
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onUIEvent, true, 100);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onUIEvent, true, 100);
			this.stage = stage;
		}
		
		private function onUIEvent(e:Event):void
		{
			uiEvent = true;
			clearTimeout(endUIID);
			endUIID = setTimeout(endUIEvent, 200);
		}
		
		private function endUIEvent():void
		{
			uiEvent = false;
		}
		
		private var list:Dictionary = new Dictionary;
		
		public function run(thread:IThread):void
		{
			if (list[thread]) throw new Error('Thread is already running');
			stage.addEventListener(Event.ENTER_FRAME, doFrame);
			list[thread] = thread;
		}
		
		public function kill(thread:IThread):void
		{
			thread.kill();
			delete list[thread];
		}
		
		public function isRunning(thread:IThread):Boolean
		{
			return list[thread] != null;
		}
		
		private function doFrame(e:Event):void
		{
			//debug('doFrame');
			var t0:Number = getTimer();
			var thread:IThread;
			var k:uint;
			//var i:uint = 0;
			var time:int = uiEvent ? 1 : sliceTime;
			do {
				k = 0;
				//i++; 
				for each(thread in list)
				{
					if (thread.runSlice())
					{
						k++;
						dispatchEvent(new ThreadEvent(ThreadEvent.PROGRESS, thread));
					}
					else
					{
						//debug('th ready');
						dispatchEvent(new ThreadEvent(ThreadEvent.PROGRESS, thread));
						dispatchEvent(new ThreadEvent('threadReady', thread));
						delete list[thread];
					}
				}
			} while (getTimer() - t0 < time && k>0);
			
			
			if (k == 0)
				stage.removeEventListener(Event.ENTER_FRAME, doFrame);
			//debug('fr '+i);
		}

	}
}