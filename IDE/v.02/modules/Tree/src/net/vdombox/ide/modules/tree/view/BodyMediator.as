package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.TreeElementz;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object )
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
			interests.push( ApplicationFacade.PAGES_GETTED );
			interests.push( ApplicationFacade.SELECTED_PAGE_GETTED );

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
					selectedApplication = messageBody as ApplicationVO;

					sendNotification( ApplicationFacade.GET_PAGES, selectedApplication );

					break;
				}

				case ApplicationFacade.PAGES_GETTED:
				{
					pages = messageBody as Array;

					sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, selectedApplication );

					break;
				}

				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
				{
					structure = messageBody as Array;

					var treeElement : TreeElementz;
					var pageVO : PageVO;

					for each ( pageVO in pages )
					{
						treeElement = new TreeElementz();
						body.main.addElement( treeElement );
						
						sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement,
											  pageVO: pageVO, structureObjectVO: getStructureObject( pageVO ) } );
					}

					sendNotification( ApplicationFacade.GET_SELECTED_PAGE, selectedApplication );

					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function getStructureObject( pageVO : PageVO ) : StructureObjectVO
		{
			var result : StructureObjectVO;

			for each ( var structureObjectVO : StructureObjectVO in structure )
			{
				if ( structureObjectVO.id == pageVO.id )
				{
					result = structureObjectVO;
					break;
				}
			}

			return result;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
		}
	}
}