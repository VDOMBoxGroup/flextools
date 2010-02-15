package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptEditorMediator";
		
		public function ScriptEditorMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public function get scriptEditor() : ScriptEditor
		{
			return viewComponent as ScriptEditor;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED:
				{
					if( body )
						scriptEditor.script = body.script;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{

		}

		private function removeHandlers() : void
		{

		}
	}
}