package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.view.components.Arrow;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;

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

		public var selectedPage : PageVO;

		public var treeElements : Object;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		public function createTreeElements( pages : Array, structureElements : Array ) : void
		{
			this.pages = pages;

			structure = structureElements;

			var pageVO : PageVO;
			var treeElement : TreeElement;

			for each ( pageVO in pages )
			{
				treeElement = new TreeElement();

				treeElements[ pageVO.id ] = treeElement;

				body.main.addElement( treeElement );

				sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement,
									  pageVO: pageVO, structureElementVO: getStructureElement( pageVO ) } );
			}
		}

		public function createArrows( linkages : Array ) : void
		{
			var linkageVO : LinkageVO;

			var arrow : Arrow;

			for each ( linkageVO in linkages )
			{
				arrow = new Arrow();

				body.main.addElement( arrow );

				sendNotification( ApplicationFacade.ARROW_CREATED, { viewComponent: arrow, linkageVO: linkageVO } );
			}
		}

		override public function onRegister() : void
		{
			addEventListeners();

			treeElements = {};
		}

		override public function onRemove() : void
		{
			removeEventListeners();

			treeElements = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

//			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
//			interests.push( ApplicationFacade.APPLICATION_STRUCTURE_GETTED );
//			interests.push( ApplicationFacade.PAGES_GETTED );
//			interests.push( ApplicationFacade.SELECTED_PAGE_GETTED );
//			interests.push( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );
//			interests.push( ApplicationFacade.CREATE_PAGE_REQUEST );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

//			switch ( messageName )
//			{
//				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
//				{
//					selectedApplication = messageBody as ApplicationVO;
//
//					sendNotification( ApplicationFacade.GET_PAGES, selectedApplication );
//
//					break;
//				}
//
//				case ApplicationFacade.PAGES_GETTED:
//				{
//					pages = messageBody as Array;
//
//					sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, selectedApplication );
//
//					break;
//				}
//
//				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
//				{
//					structure = messageBody as Array;
//
//					var treeElement : TreeElementz;
//					var pageVO : PageVO;
//
//					for each ( pageVO in pages )
//					{
//						treeElement = new TreeElementz();
//						
//						treeElements[ pageVO.id ] = treeElement;
//						
//						body.main.addElement( treeElement );
//
//						sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED,
//										  { viewComponent: treeElement, pageVO: pageVO, structureObjectVO: getStructureObject( pageVO ) } );
//					}
//
//					for each ( var structureLevelVO : StructureLevelVO in structure )
//					{
//						
//					}
//					
//					sendNotification( ApplicationFacade.GET_SELECTED_PAGE, selectedApplication );
//
//					break;
//				}
//
//				case ApplicationFacade.SELECTED_PAGE_GETTED:
//				{
//					var newSelectedPage : PageVO = messageBody as PageVO;
//
//					if ( !newSelectedPage )
//						newSelectedPage = getPageVOByID( selectedApplication.indexPageID );
//
//					if ( newSelectedPage != selectedPage )
//					{
//						selectedPage = newSelectedPage;
//
//						sendNotification( ApplicationFacade.GET_TYPE, { typeID: selectedPage.typeID, recipientID: mediatorName } );
//					}
//
//					break;
//				}
//
//				case ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName:
//				{
//					sendNotification( ApplicationFacade.SELECTED_PAGE_CHANGED, { pageVO: selectedPage, typeVO: messageBody } );
//
//					break;
//				}
//
//				case ApplicationFacade.CREATE_PAGE_REQUEST:
//				{
//					var createPageWindow : CreatePageWindow = new CreatePageWindow();
//
//					sendNotification( ApplicationFacade.OPEN_WINDOW, { content: createPageWindow, title: "Create Page", isModal: true } );
//					sendNotification( ApplicationFacade.CREATE_PAGE_WINDOW_CREATED, createPageWindow );
//
//					break;
//				}
//			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function removeEventListeners() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function getStructureElement( pageVO : PageVO ) : StructureElementVO
		{
			var result : StructureElementVO;

			for each ( var structureElementVO : StructureElementVO in structure )
			{
				if ( structureElementVO.id == pageVO.id )
				{
					result = structureElementVO;
					break;
				}
			}

			return result;
		}

		private function getPageVOByID( pageID : String ) : PageVO
		{
			var result : PageVO;

			for each ( var pageVO : PageVO in pages )
			{
				if ( pageVO.id == pageID )
				{
					result = pageVO;
					break;
				}
			}

			return result;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.BODY_CREATED, body );
		}
	}
}