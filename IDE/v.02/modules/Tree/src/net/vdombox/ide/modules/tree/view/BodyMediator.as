package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
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

//		public var treeElements : Array;
//		public var arrows : Array;

		public var selectedTreeElement : TreeElementVO;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		public function createTreeElements( treeElements : Array ) : void
		{
//			this.treeElements = treeElements;

			body.treeElementsContainer.removeAllElements();
			
			var treeElement : TreeElement;
			var treeElementVO : TreeElementVO;

			for each ( treeElementVO in treeElements )
			{
				treeElement = new TreeElement();

//				treeElements[ treeElementVO.id ] = treeElement;

				body.treeElementsContainer.addElement( treeElement );

				sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement, treeElementVO: treeElementVO } );
			}
		}

		public function createLinkages( linkages : Array ) : void
		{
			body.linkagesContainer.removeAllElements();
			
			var linkageVO : LinkageVO;

			var linkage : Linkage;

			for each ( linkageVO in linkages )
			{
				linkage = new Linkage();

//				arrows.push( arrow );
				body.linkagesContainer.addElement( linkage );

				sendNotification( ApplicationFacade.LINKAGE_CREATED, { viewComponent: linkage, linkageVO: linkageVO } );
			}
		}

		override public function onRegister() : void
		{
			addHandlers();

//			treeElements = {};
//			arrows = [];
		}

		override public function onRemove() : void
		{
			removeHandlers();

//			treeElements = null;
//			arrows = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.PAGE_DELETED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

			switch ( messageName )
			{
				case ApplicationFacade.PAGE_DELETED:
				{
					var pageVO : PageVO = messageBody.pageVO;
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

//		private function getStructureElement( pageVO : PageVO ) : TreeElementVO
//		{
//			var result : TreeElementVO;
//			var treeElementVO : TreeElementVO
//
//			for each ( treeElementVO in structure )
//			{
//				if ( treeElementVO.id == pageVO.id )
//				{
//					result = treeElementVO;
//					break;
//				}
//			}
//
//			return result;
//		}

//		private function getPageVOByID( pageID : String ) : PageVO
//		{
//			var result : PageVO;
//
//			for each ( var pageVO : PageVO in pages )
//			{
//				if ( pageVO.id == pageID )
//				{
//					result = pageVO;
//					break;
//				}
//			}
//
//			return result;
//		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.BODY_CREATED, body );
		}
	}
}