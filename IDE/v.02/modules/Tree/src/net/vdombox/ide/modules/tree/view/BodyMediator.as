package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent :Object )
		{
			super( NAME, viewComponent );
		}

		public var selectedApplication : ApplicationVO;

		public var pages : Array;

		public var structure : Array;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.APPLICATION_STRUCTURE_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

			switch ( messageName )
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					selectedApplication = body as ApplicationVO;

					sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, messageBody );
					break;
				}

				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
				{
					structure = messageBody as Array;

					var treeElement : TreeElement;

					for ( var i : int = 0; i < structure.length; i++ )
					{
						treeElement = new TreeElement();
						body.main.addElement( treeElement );
						sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement,
											  structureObjectVO: structure[ i ] } );
					}

					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
		}
	}
}