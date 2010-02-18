package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
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

		public var treeElementsObject : Object;

		public var linkagesObject : Object;

		public var selectedTreeElement : TreeElementVO;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		public function createTreeElements( treeElements : Array ) : void
		{
			var treeElement : TreeElement;
			var treeElementVO : TreeElementVO;

			var oldElements : Object = treeElementsObject;
			var newElements : Object = {};

			for each ( treeElementVO in treeElements )
			{
				if ( oldElements.hasOwnProperty( treeElementVO.id ) )
				{
					newElements[ treeElementVO.id ] = oldElements[ treeElementVO.id ];

					delete oldElements[ treeElementVO.id ];

					continue;
				}

				treeElement = new TreeElement();

				newElements[ treeElementVO.id ] = treeElement;

				body.treeElementsContainer.addElement( treeElement );

				sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement, treeElementVO: treeElementVO } );
			}

			for each ( treeElement in oldElements )
			{
				body.treeElementsContainer.removeElement( treeElement );
			}

			treeElementsObject = newElements;
		}

		public function createLinkages( linkages : Array ) : void
		{
			var linkage : Linkage;
			var linkageVO : LinkageVO;

			var oldLinkages : Object = linkagesObject;
			var newLinkages : Object = {};

			var linkageID : String;

			for each ( linkageVO in linkages )
			{
				linkageID = linkageVO.source.id + "/" + linkageVO.target.id + "/" + linkageVO.level.level;

				if ( oldLinkages.hasOwnProperty( linkageID ) )
				{
					newLinkages[ linkageID ] = oldLinkages[ linkageID ];

					delete oldLinkages[ linkageID ];

					continue;
				}

				linkage = new Linkage();

				newLinkages[ linkageID ] = linkage;

				body.linkagesContainer.addElement( linkage );

				sendNotification( ApplicationFacade.LINKAGE_CREATED, { viewComponent: linkage, linkageVO: linkageVO } );
			}

			for each ( linkage in oldLinkages )
			{
				body.linkagesContainer.removeElement( linkage );
			}

			linkagesObject = newLinkages;
		}

		override public function onRegister() : void
		{
			addHandlers();

			treeElementsObject = {};
			linkagesObject = {};
		}

		override public function onRemove() : void
		{
			removeHandlers();

			treeElementsObject = null;
			linkagesObject = null;
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

		public function sortElements() : void
		{
			var elements : Array = getTreeElements();
			var linkages : Array = getLinkages();

			var specialObject : Object = extractLinkagelessElements( elements, linkages );
		}

		private function extractLinkagelessElements( elements : Array, linkages : Array ) : Object
		{
			var treeElement : TreeElement;
			var linkage : Linkage;
			var isTarget : Boolean;
			var isSource : Boolean;

			var parentless : Array = [];
			var linkageless : Array = [];

			for ( var i : uint = 0; i < elements.length; i++ )
			{
				treeElement = elements[ i ];

				isTarget = false;
				isSource = false;

				for each ( linkage in linkages )
				{
					if ( linkage.linkageVO.target == treeElement.treeElementVO )
					{
						isTarget = true;
						break;
					}
					else if ( linkage.linkageVO.source == treeElement.treeElementVO )
					{
						isSource = true;
						break;
					}
				}

				if ( !isTarget )
				{
					if ( !isSource )
					{
						linkageless.push( treeElement );
					}
					else
					{
						parentless.push( treeElement );
					}

					elements.splice( i, 1 );
					i--;
				}
			}

			return { parentless: parentless, linkageless: linkageless };
		}

		private function getTreeElements() : Array
		{
			var elements : Array = [];
			var numElements : int = body.treeElementsContainer.numElements;
			var treeElement : Object;

			for ( var i : uint = 0; i < numElements; i++ )
			{
				treeElement = body.treeElementsContainer.getElementAt( i );

				if ( treeElement is TreeElement )
					elements.push( treeElement );
			}

			return elements;
		}

		private function getLinkages() : Array
		{
			var linkages : Array = [];
			var numElements : int = body.linkagesContainer.numElements;
			var linkage : Object;

			for ( var i : uint = 0; i < numElements; i++ )
			{
				linkage = body.treeElementsContainer.getElementAt( i );

				if ( linkage is Linkage && Linkage( linkage ).visible == true )
					linkages.push( linkage );
			}

			return linkages;
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