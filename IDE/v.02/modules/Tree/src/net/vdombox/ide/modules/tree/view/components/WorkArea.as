package net.vdombox.ide.modules.tree.view.components
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.net.sendToURL;
	
	import net.vdombox.ide.common.view.components.button.WorkAreaButton;
	import net.vdombox.ide.modules.tree.events.LinkageEvent;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.events.WorkAreaEvent;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;
	import net.vdombox.ide.modules.tree.view.skins.WorkAreaSkin;
	
	import spark.components.Group;
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	import spark.effects.Move;
	import spark.effects.easing.EaseInOutBase;

	public class WorkArea extends SkinnableContainer
	{
		public function WorkArea()
		{
			super();			
			
			setStyle( "skinClass", WorkAreaSkin );

			addEventListener( WorkAreaEvent.AUTO_SPACING, autoSpacingHandler, false, 0, true );

			addEventListener( WorkAreaEvent.COLLAPSE_ALL, collapseAllHandler, false, 0, true );
			addEventListener( WorkAreaEvent.EXPAND_ALL, expandAllHandler, false, 0, true );

			addEventListener( TreeElementEvent.MOVED, treeElement_movedHandler, true, 0, true );
			addEventListener( TreeElementEvent.STATE_CHANGED, treeElement_stateChangedHandler, true, 0, true );
			
			addEventListener( TreeElementEvent.CREATE_LINKAGE, treeElement_createLinkageHandler, true, 0, true );
			addEventListener( TreeElementEvent.DELETE_LINKAGE, treeElement_deleteLinkageHandler, true, 0, true );
			
			addEventListener( TreeElementEvent.DELETE, treeElement_deleteHandler, true, 0, true );
		}

		[SkinPart( required="true" )]
		public var linkagesLayer : Group;

		[SkinPart( required="true" )]
		public var scroller : Scroller;

		[SkinPart]
		public var saveButton : WorkAreaButton;

		[SkinPart]
		public var undoButton : WorkAreaButton;

		[Bindable]
		public var isAllExpanded : Boolean;

		[Bindable]
		public var isAllCollapsed : Boolean;

		[Bindable]
		public var isSignatureShowed : Boolean;

		private var isStatePropertyChanged : Boolean;

		/**
		 * for save current treeElement?
		 * treeElementsObject[ treeElementVO.id ] = treeElement;
		 */		
		private var treeElementsObject : Object;
		private var linkagesObject : Object;

		private var shadowLinkage : Linkage;
		private var shadowLinkageVO : LinkageVO;
		private var shadowTargetTreeElementVO : TreeElementVO;

		private var _selectedTreeLevelVO : TreeLevelVO;

//		private var selectedTreeLevelVO : TreeLevelVO;

		/**
		 * @return Array of TreeElementVO. 
		 */		
		public function get treeElements() : Array
		{
			var result : Array = [];
			
			var numTreeElements : int = numElements;
			var currentTreeElement : TreeElement;
			
			for ( var i : int = 0; i < numTreeElements; i++ )
			{
				currentTreeElement = getElementAt( i ) as TreeElement;
				
				if( currentTreeElement && currentTreeElement.treeElementVO )
				{
					result.push( currentTreeElement.treeElementVO );
				}
			}
			
			return result;
		}
		
		/**
		 * @param treeElements - Array of treeElementVO. 
		 */		
		public function set treeElements( treeElements : Array ) : void
		{
			var treeElement : TreeElement;
			var treeElementVO : TreeElementVO;

			var oldElements : Object = treeElementsObject ? treeElementsObject : {};
			var newElements : Object = {};

			if ( !treeElements )
				skin.currentState = "disabled";
			else
				skin.currentState = "normal";

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

				treeElement.treeElementVO = treeElementVO;

				addElement( treeElement );

//				sendNotification( ApplicationFacade.TREE_ELEMENT_CREATED, { viewComponent: treeElement, treeElementVO: treeElementVO } );
			}

			for each ( treeElement in oldElements )
			{
				removeElement( treeElement );
			}

			treeElementsObject = newElements;

			isStatePropertyChanged = true;
			isSignatureShowed = false;

			invalidateProperties();
		}

		public function get linkages() : Array
		{
			var result : Array = [];
			
			var numLinkages : int = linkagesLayer.numElements;
			var currentLinkage : Linkage;
			
			for ( var i : int = 0; i < numLinkages; i++ )
			{
				currentLinkage = linkagesLayer.getElementAt( i ) as Linkage;
				
				if( currentLinkage && currentLinkage.linkageVO )
				{
					result.push( currentLinkage.linkageVO );
				}
			}
			
			return result;
		}
		
		public function set linkages( linkages : Array ) : void
		{
			var linkage : Linkage;
			var linkageVO : LinkageVO;

			var oldLinkages : Object = linkagesObject ? linkagesObject : {};
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

				linkage.linkageVO = linkageVO;

				linkagesLayer.addElement( linkage );
			}

			for each ( linkage in oldLinkages)
			{
				if( linkage && linkage.parent && linkage.parent == linkagesLayer )
					linkagesLayer.removeElement( linkage );
			}

			linkagesObject = newLinkages;

			if ( !treeElements )
				skin.currentState = "disabled";
			else
				skin.currentState = "normal";
			
			isSignatureShowed = false;
			isStatePropertyChanged = true;
			
			invalidateProperties();
		}

		public function set selectedTreeLevelVO( value : TreeLevelVO ) : void
		{
			_selectedTreeLevelVO = value;
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

		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );

			if ( instance == saveButton )
			{
				saveButton.addEventListener( MouseEvent.CLICK, saveButton_clickHandler );
			}
			else if ( instance == undoButton )
			{
				undoButton.addEventListener( MouseEvent.CLICK, undoButton_clickHandler );
			}
		}

		override protected function commitProperties() : void
		{
			super.commitProperties();

			if ( isStatePropertyChanged )
			{
				var haveExpanded : Boolean;
				var haveCollapsed : Boolean;

				isStatePropertyChanged = false;

				var numTreeElements : int = numElements;
				var treeElement : TreeElement;

				for ( var i : int = 0; i < numTreeElements; i++ )
				{
					treeElement = getElementAt( i ) as TreeElement;

					if ( !treeElement || !treeElement.treeElementVO )
						continue;

					if ( treeElement.treeElementVO.state )
						haveExpanded = true;
					else
						haveCollapsed = true;
				}

				if ( haveExpanded && !haveCollapsed )
				{
					isAllExpanded = true;
					isAllCollapsed = false;
				}
				else if ( !haveExpanded && haveCollapsed )
				{
					isAllExpanded = false;
					isAllCollapsed = true;
				}
				else
				{
					isAllExpanded = false;
					isAllCollapsed = false;
				}
			}
		}

		private function getTreeElementFromParent( object : DisplayObjectContainer ) : TreeElement
		{
			var parent : DisplayObjectContainer = object.parent as DisplayObjectContainer;
			var result : TreeElement;

			while ( parent )
			{
				if ( parent is TreeElement )
				{
					result = parent as TreeElement;
					break;
				}
				else if ( parent is WorkArea )
				{
					break;
				}

				parent = parent.parent as DisplayObjectContainer;
			}

			return result;
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

		/** 
		 * @return Array of TreeElements.
		 */		
		public function getTreeElements() : Array
		{
			var elements : Array = [];
			var numElements : int = numElements;
			var treeElement : Object;

			for ( var i : uint = 0; i < numElements; i++ )
			{
				treeElement = getElementAt( i );

				if ( treeElement is TreeElement )
					elements.push( treeElement );
			}

			return elements;
		}

		private function getLinkages() : Array
		{
			var linkages : Array = [];
			var numElements : int = linkagesLayer.numElements;
			var linkage : Object;

			for ( var i : uint = 0; i < numElements; i++ )
			{
				linkage = linkagesLayer.getElementAt( i );

				if ( linkage is Linkage && Linkage( linkage ).visible == true )
					linkages.push( linkage );
			}

			return linkages;
		}

		private function getMaxIndex( source : TreeElementVO, level : TreeLevelVO ) : int
		{
			var numLinkages : int = linkagesLayer.numElements;
			var currentLinkage : Linkage;
			var maxIndex : int = 0;

			for ( var i : int = 0; i < numLinkages; i++ )
			{
				currentLinkage = linkagesLayer.getElementAt( i ) as Linkage;

				if ( currentLinkage.source.id == source.id && currentLinkage.linkageVO.level.level == level.level )
					maxIndex++;
			}

			return maxIndex;
		}

		private function addShadowHandlers() : void
		{
			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, true );

			addEventListener( MouseEvent.CLICK, mouseClickHandler, true );
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, true );

			addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, true );
			addEventListener( MouseEvent.ROLL_OVER, rollOverHandler, true );
		}

		private function removeShadowHandlers() : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler, true );
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, true );

			removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			removeEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, true );
			removeEventListener( MouseEvent.ROLL_OVER, rollOverHandler, true );
		}

		private function autoSpacingHandler( event : WorkAreaEvent ) : void
		{
			sortElements();

			skin.currentState = "unsaved";
		}

		private function collapseAllHandler( event : WorkAreaEvent ) : void
		{
			isAllCollapsed = true;
			isAllExpanded = false;

			skin.currentState = "unsaved";
		}

		private function expandAllHandler( event : WorkAreaEvent ) : void
		{
			isAllCollapsed = false;
			isAllExpanded = true;

			skin.currentState = "unsaved";
		}

		private function treeElement_stateChangedHandler( event : TreeElementEvent ) : void
		{
			isStatePropertyChanged = true;

			invalidateProperties()

			skin.currentState = "unsaved";
		}

		private function treeElement_movedHandler( event : TreeElementEvent ) : void
		{
			skin.currentState = "unsaved";
		}

		private function treeElement_createLinkageHandler( event : TreeElementEvent ) : void
		{
			var sourceTreeElement : TreeElement = event.target as TreeElement;

			if ( !sourceTreeElement )
				return;

			var sourceTreeElementVO : TreeElementVO = sourceTreeElement.treeElementVO as TreeElementVO;

			if ( !sourceTreeElementVO )
				return;

			shadowLinkage = new Linkage();
			shadowLinkageVO = new LinkageVO();

			shadowTargetTreeElementVO = new TreeElementVO( sourceTreeElementVO.pageVO );

			shadowLinkageVO.source = sourceTreeElementVO;
			shadowLinkageVO.target = shadowTargetTreeElementVO;
			shadowLinkageVO.level = _selectedTreeLevelVO;


			shadowLinkage.linkageVO = shadowLinkageVO;

			shadowLinkage.alpha = 0.4;

			linkagesLayer.addElement( shadowLinkage );

			addShadowHandlers();
		}

		private function treeElement_deleteHandler( event : TreeElementEvent ) : void
		{
			var treeElement : TreeElement = event.target as TreeElement;

			if ( treeElement && treeElement.parent == this )
				removeElement( treeElement );

			var currentLinkage : Linkage;

			if ( treeElement.treeElementVO )
			{
				for ( var i : int = 0; i < linkagesLayer.numElements; i++ )
				{
					currentLinkage = linkagesLayer.getElementAt( i ) as Linkage;

					if ( currentLinkage && ( ( currentLinkage.source && currentLinkage.source.id == treeElement.treeElementVO.id ) ||
						( currentLinkage.target && currentLinkage.target.id == treeElement.treeElementVO.id ) ) )
					{
						linkagesLayer.removeElement( currentLinkage );
						i--;
					}
				}
			}

			skin.currentState = "unsaved";
		}

		private function treeElement_deleteLinkageHandler( event : TreeElementEvent ) : void
		{
			var linkage : Linkage = event.target as Linkage;

			if ( linkage && linkage.parent == linkagesLayer )
			{
				linkagesLayer.removeElement( linkage );
				skin.currentState = "unsaved";
			}
		}

		private function saveButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.SAVE ) );
			
			skin.currentState = "normal";
		}

		private function undoButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.UNDO ) );
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();

			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, true );
		}

		private function mouseMoveHandler( event : MouseEvent ) : void
		{
			var viewport : Group = scroller.viewport as Group;

			var visibleWidth : Number = viewport.width;
			var visibleHeight : Number = viewport.height;

			var fullWidth : Number = Math.max( visibleWidth, viewport.contentWidth );
			var fullHeight : Number = Math.max( visibleHeight, viewport.contentHeight );

			if ( viewport.mouseX > visibleWidth - 100 && viewport.horizontalScrollPosition < scroller.horizontalScrollBar.maximum )
				viewport.horizontalScrollPosition += 5;
			if ( viewport.mouseX < viewport.horizontalScrollPosition + 100 && viewport.horizontalScrollPosition > 0 )
				viewport.horizontalScrollPosition -= 5;

			if ( viewport.mouseY > visibleHeight - 100 && viewport.verticalScrollPosition < scroller.verticalScrollBar.maximum )
				viewport.verticalScrollPosition += 5;
			if ( viewport.mouseY < viewport.verticalScrollPosition + 100 && viewport.verticalScrollPosition > 0 )
				viewport.verticalScrollPosition -= 5;

			if ( viewport.contentMouseX < fullWidth - 10 )
				shadowTargetTreeElementVO.left = linkagesLayer.contentMouseX;
			else
				shadowTargetTreeElementVO.left = fullWidth - 10;

			if ( viewport.contentMouseY < fullHeight - 20 )
				shadowTargetTreeElementVO.top = linkagesLayer.contentMouseY;
			else
				shadowTargetTreeElementVO.top = fullHeight - 20;
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			var treeElement : TreeElement = getTreeElementFromParent( event.target as DisplayObjectContainer );

			if ( treeElement )
			{
				if ( shadowLinkageVO.source != treeElement.treeElementVO && shadowLinkageVO.target != treeElement.treeElementVO )
				{
					shadowLinkageVO.target = treeElement.treeElementVO;
					shadowLinkage.alpha = 1;
				}
			}
			else
			{
				shadowLinkageVO.target = shadowTargetTreeElementVO;
				shadowLinkage.alpha = 0.4;
			}

			shadowLinkage.linkageVO = shadowLinkageVO;

			event.stopImmediatePropagation();
		}

		private function rollOverHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();

			removeEventListener( MouseEvent.CLICK, mouseClickHandler, true );
		}

		private function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			var treeElement : TreeElement = getTreeElementFromParent( event.target as DisplayObjectContainer );

			if ( !treeElement )
			{
				removeEventListener( MouseEvent.CLICK, mouseClickHandler, true );
				removeShadowHandlers();

				if ( shadowLinkage && shadowLinkage.parent == linkagesLayer )
					linkagesLayer.removeElement( shadowLinkage );
			}
			else
			{
				stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler, true );
			}
		}

		private function stage_mouseUpHandler( event : MouseEvent ) : void
		{
			if ( shadowLinkage && shadowLinkage.parent == linkagesLayer )
				linkagesLayer.removeElement( shadowLinkage );

			var newSourceTreeElementVO : TreeElementVO;
			var newTargetTreeElementVO : TreeElementVO;
			var newTreeLevelVO : TreeLevelVO;

			var isLinkageCorrected : Boolean = false;

			try
			{
				newSourceTreeElementVO = shadowLinkage.source;
				newTargetTreeElementVO = shadowLinkage.target;
				newTreeLevelVO = shadowLinkageVO.level;
			}
			catch ( error : Error )
			{
			}

			var numLinkages : int = linkagesLayer.numChildren;

			var currentLinkage : Linkage;

			if ( newSourceTreeElementVO && newTargetTreeElementVO && newTreeLevelVO && newSourceTreeElementVO.id != newTargetTreeElementVO.id )
			{
				isLinkageCorrected = true;
				for ( var i : int = 0; i < numLinkages; i++ )
				{
					currentLinkage = linkagesLayer.getElementAt( i ) as Linkage;

					if ( currentLinkage && currentLinkage.target && currentLinkage.linkageVO && currentLinkage.source &&
						currentLinkage.target.id == newTargetTreeElementVO.id &&
						currentLinkage.source.id == newSourceTreeElementVO.id && currentLinkage.linkageVO.level.level == newTreeLevelVO.level )
					{
						isLinkageCorrected = false;
						break;
					}
				}
			}

			if ( isLinkageCorrected )
			{
				var linkage : Linkage = new Linkage();
				var linkageVO : LinkageVO = new LinkageVO();

				linkageVO.source = newSourceTreeElementVO;
				linkageVO.target = newTargetTreeElementVO;
				linkageVO.level = newTreeLevelVO;

				linkageVO.index = getMaxIndex( newSourceTreeElementVO, newTreeLevelVO );

				linkage.linkageVO = linkageVO;

				if ( isSignatureShowed )
					linkage.signatureVisible = true;

				linkagesLayer.addElement( linkage );
				skin.currentState = "unsaved";
			}


			shadowLinkageVO = null;
			shadowLinkage = null;
			shadowTargetTreeElementVO = null;

			removeShadowHandlers();
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