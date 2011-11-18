package net.vdombox.ide.core.controller
{
	import flash.desktop.NativeApplication;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.UpdateMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CloseIDECommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			trace("*** Begin cansel ***");	

			var opened : Array = NativeApplication.nativeApplication.openedWindows;
			
			for ( var i : int = 0; i < opened.length; i++ )
			{
				opened[ i ].close();
			}
			
			var t : Timer = new Timer( 100, 1 );
			
			t.addEventListener( TimerEvent.TIMER, closeNativeAplication );
			
			t.start();
		}


		private function closeNativeAplication( event : TimerEvent ) : void
		{
			var opened : Array = NativeApplication.nativeApplication.openedWindows;

			for ( var i : int = 0; i < opened.length; i++ )
			{
				opened[ i ].close();
			}
			
			trace("*** End cansel ***");
			NativeApplication.nativeApplication.exit();
		}
	}
}
