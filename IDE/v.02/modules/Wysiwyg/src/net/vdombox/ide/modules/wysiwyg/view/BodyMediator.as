package net.vdombox.ide.modules.edition.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.edition.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		private function get body() : Body
		{
			return viewComponent as Body;
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, body_creationCompleteHandler );
		}

		private function body_creationCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new TypeAccordionMediator( body.typeAccordion ) );
		}
	}
}