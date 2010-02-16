package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ApplicationVO;
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
			scriptEditor.enabled = false;
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED );
			interests.push( ApplicationFacade.SELECTED_LIBRARY_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					var selectedApplicationVO : ApplicationVO = body as ApplicationVO;
					
					scriptEditor.syntax = selectedApplicationVO.scriptingLanguage;
					
					break;
				}
					
				case ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED:
				{
				}
					
				case ApplicationFacade.SELECTED_LIBRARY_CHANGED:
				{
					if( body )
					{
						scriptEditor.enabled = true;
						scriptEditor.script = body.script;
					}
					
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