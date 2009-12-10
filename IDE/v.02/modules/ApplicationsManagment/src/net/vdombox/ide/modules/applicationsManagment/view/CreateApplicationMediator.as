package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.applicationsManagment.view.components.CreateApplication;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class CreateApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateApplicationMediator";
		
		public function CreateApplicationMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		override public function onRegister() : void
		{
			createApplication.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function get createApplication() : CreateApplication
		{
			return viewComponent as CreateApplication
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			var d : * = "";
		}
	}
}