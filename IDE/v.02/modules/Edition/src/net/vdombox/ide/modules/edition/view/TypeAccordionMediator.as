package net.vdombox.ide.modules.edition.view
{
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	import net.vdombox.ide.modules.edition.view.components.TypeAccordion;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TypeAccordionMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TypeAccordionMediator";

		public function TypeAccordionMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.TYPES_GETTED );

			return interests;
		}

		override public function onRegister() : void
		{
			sendNotification( ApplicationFacade.GET_TYPES );
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.TYPES_GETTED:
				{
					var d : * = "";
				}
			}
		}

		private function get body() : TypeAccordion
		{
			return viewComponent as TypeAccordion;
		}
	}
}