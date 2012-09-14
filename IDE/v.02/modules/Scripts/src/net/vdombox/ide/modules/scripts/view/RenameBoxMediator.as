package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.modules.scripts.view.components.RenameBox;
	import net.vdombox.ide.modules.scripts.view.components.ScriptArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class RenameBoxMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "RenameBoxMediator";
		
		public function RenameBoxMediator( viewComponent : ScriptArea )
		{
			super( NAME, viewComponent );
		}
		
		public function get scriptArea() : ScriptArea
		{
			return viewComponent as ScriptArea;
		}
		
		public function get renameBox() : RenameBox
		{
			return scriptArea.renameBox;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			//interests.push( Notifications.OPEN_FIND_SCRIPT );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				/*case Notifications.OPEN_FIND_SCRIPT:
				{
					if ( scriptArea.currentState != "find" )
					{
						scriptArea.currentState = "find";
						
						if ( findBox.currentState == "global" )
							findBox.currentState = "find"
					}
					else
						findBox.findText.setFocus();
					
					break;
				}
					*/
			}
		}
	}
}