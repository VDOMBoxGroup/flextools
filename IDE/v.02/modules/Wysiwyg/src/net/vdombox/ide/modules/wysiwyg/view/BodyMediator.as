package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public var selectedApplication : ApplicationVO;

		private var created : Boolean = false;
		
		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.MODULE_SELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					selectedApplication = notification.getBody() as ApplicationVO;
					sendNotification( ApplicationFacade.GET_PAGES, notification.getBody());
					
					break;
				}
					
				case ApplicationFacade.MODULE_SELECTED:
				{
					if( created ) 
						sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
					
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function commitProperties() : void
		{

		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			addEventListeners();

			created = true;
			
			facade.registerMediator( new TypesAccordionMediator( body.typesAccordion ) );

			facade.registerMediator( new ObjectsTreePanelMediator( body.objectsTreePanel ) );
			
			facade.registerMediator( new ObjectAttributesPanelMediator( body.objectAttributesPanel ) );

			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
		}
	}
}