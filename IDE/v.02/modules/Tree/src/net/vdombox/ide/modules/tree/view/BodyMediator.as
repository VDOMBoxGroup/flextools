package net.vdombox.ide.modules.tree.view
{
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Group;
	import spark.effects.Move;
	import spark.effects.easing.EaseInOutBase;

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

		public var shadowLinkageVO : LinkageVO;

		public var selectedTreeLevelVO : TreeLevelVO;

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
			interests.push( ApplicationFacade.AUTO_SPACING_REQUEST );
			interests.push( ApplicationFacade.CREATE_LINKAGE_REQUEST );
			interests.push( ApplicationFacade.SELECTED_TREE_LEVEL_CHANGED );

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

				case ApplicationFacade.SELECTED_TREE_LEVEL_CHANGED:
				{
					selectedTreeLevelVO = messageBody as TreeLevelVO;
					break;
				}

				case ApplicationFacade.AUTO_SPACING_REQUEST:
				{
					sortElements();
					break;
				}

				case ApplicationFacade.CREATE_LINKAGE_REQUEST:
				{
					var linkage : Linkage = new Linkage();

					shadowLinkageVO = new LinkageVO();

					var sourceTreeElementVO : TreeElementVO = messageBody as TreeElementVO;
					var targetTreeElementVO : TreeElementVO = new TreeElementVO( sourceTreeElementVO.pageVO );

					shadowLinkageVO.source = sourceTreeElementVO;
					shadowLinkageVO.target = targetTreeElementVO;
					shadowLinkageVO.level = selectedTreeLevelVO;

					linkage.linkageVO = shadowLinkageVO;

					body.linkagesContainer.addElement( linkage );
					body.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler )

					break;
				}
			}
		}

		private function mouseMoveHandler( event : MouseEvent ) : void
		{
			var viewport : Group = body.scroller.viewport as Group;
			
			if( viewport.contentMouseX < viewport.contentWidth - 10 )
				shadowLinkageVO.target.left = viewport.contentMouseX;
			else
				shadowLinkageVO.target.left = viewport.contentWidth - 10;
			
			shadowLinkageVO.target.top = body.linkagesContainer.mouseY;
			
			if( viewport.mouseX > viewport.width - 100 && viewport.horizontalScrollPosition < body.scroller.horizontalScrollBar.maximum )
				viewport.horizontalScrollPosition += 5;
			if( viewport.mouseX < viewport.horizontalScrollPosition + 100 && viewport.horizontalScrollPosition > 0 )
				viewport.horizontalScrollPosition -= 5;
			
			
		}

		public function sortElements() : void
		{
			var elements : Array = getTreeElements();
			var linkages : Array = getLinkages();

			var specialObject : Object = extractLinkagelessElements( elements, linkages );

			var depthArray : Array = [];
			var currentDepth : uint = 0;

			var currentDepthArray : Array;

			var sortObject : SortObject;

			if ( specialObject.parentless.length == 0 )
			{
				sortObject = new SortObject();
				sortObject.element = elements[ 0 ];
				currentDepthArray = [ sortObject ];
			}
			else
			{
				currentDepthArray = specialObject.parentless;
			}

			depthArray[ currentDepth ] = currentDepthArray;

			for each ( sortObject in currentDepthArray )
			{
				placeChildren( sortObject, currentDepth + 1, depthArray, elements, linkages );
			}

			if ( specialObject.linkageless.length > 0 )
				depthArray[ depthArray.length ] = specialObject.linkageless;


			var xPosition : uint;
			var yPosition : uint;

			var i : uint;
			var j : uint;

			for ( i = 0; i < depthArray.length; i++ )
			{
				currentDepthArray = depthArray[ i ];
				currentDepth = i;

				xPosition = 0;

				for ( j = 0; j < currentDepthArray.length; j++ )
				{
					sortObject = currentDepthArray[ j ];

					if ( sortObject.parent && sortObject.parent.xPosition > xPosition )
					{
						sortObject.xPosition = sortObject.parent.xPosition;
						xPosition += sortObject.parent.xPosition - xPosition;
					}

					sortObject.xPosition = xPosition;
					sortObject.yPosition = i;

					xPosition += sortObject.children.length > 0 ? sortObject.children.length : 1;
				}
			}

			var move : Move;

			for ( i = 0; i < depthArray.length; i++ )
			{
				currentDepthArray = depthArray[ i ];
				currentDepth = i;

				for ( j = 0; j < currentDepthArray.length; j++ )
				{
					sortObject = currentDepthArray[ j ];

					move = new Move( sortObject.element )

					move.duration = 1200;
					move.easer = new EaseInOutBase();

					move.xFrom = sortObject.element.x;
					move.xTo = sortObject.xPosition * 220;

					move.yFrom = sortObject.element.y;
					move.yTo = sortObject.yPosition * 140;

					move.stop();
					move.play();
				}
			}
		}

		private function placeChildren( sortObject : SortObject, currentDepth : uint, depthArray : Array, elements : Array, linkages : Array ) : void
		{
			var children : Array = extractChildren( sortObject.element, elements, linkages );
			var childSortObject : SortObject;

			if ( children.length == 0 )
				return;

			if ( !depthArray[ currentDepth ] )
				depthArray[ currentDepth ] = [];

			depthArray[ currentDepth ] = depthArray[ currentDepth ].concat( children );
			sortObject.children = children;

			for each ( childSortObject in children )
			{
				childSortObject.parent = sortObject;
				placeChildren( childSortObject, currentDepth + 1, depthArray, elements, linkages );
			}
		}

		private function extractChildren( sourceElement : TreeElement, elements : Array, linkages : Array ) : Array
		{
			var targetElement : TreeElement;
			var linkage : Linkage;

			var result : Array = [];
			var sortObject : SortObject;

			for ( var i : uint = 0; i < elements.length; i++ )
			{
				targetElement = elements[ i ];

				for each ( linkage in linkages )
				{
					if ( linkage.linkageVO.source == sourceElement.treeElementVO && linkage.linkageVO.target == targetElement.treeElementVO )
					{
						sortObject = new SortObject();
						sortObject.element = targetElement;

						result.push( sortObject );

						elements.splice( i, 1 );
						i--;

						break;
					}
				}
			}

			return result;
		}

		private function extractLinkagelessElements( elements : Array, linkages : Array ) : Object
		{
			var treeElement : TreeElement;
			var linkage : Linkage;
			var isTarget : Boolean;
			var isSource : Boolean;

			var parentless : Array = [];
			var linkageless : Array = [];
			var sortObject : SortObject;

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
					}
				}

				if ( !isTarget )
				{
					sortObject = new SortObject();
					sortObject.element = treeElement;

					if ( !isSource )
						linkageless.push( sortObject );
					else
						parentless.push( sortObject );
				}
			}

			var affectedElements : Array = linkageless.concat( parentless );
			var index : int;

			for each ( sortObject in affectedElements )
			{
				index = elements.indexOf( sortObject.element );

				if ( index != -1 )
					elements.splice( index, 1 );
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
				linkage = body.linkagesContainer.getElementAt( i );

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

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.BODY_CREATED, body );
		}
	}
}

import net.vdombox.ide.modules.tree.view.components.TreeElement;

class SortObject
{
	public var element : TreeElement;

	public var xPosition : uint;

	public var yPosition : uint;

	public var parent : SortObject;

	public var children : Array = [];
}
