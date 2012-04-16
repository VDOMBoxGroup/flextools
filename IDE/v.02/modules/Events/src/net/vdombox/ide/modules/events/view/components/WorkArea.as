package net.vdombox.ide.modules.events.view.components
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.DragSource;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.utils.NameUtil;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model._vo.ApplicationEventsVO;
	import net.vdombox.ide.common.model._vo.ClientActionVO;
	import net.vdombox.ide.common.model._vo.EventVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.VDOMScroller;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.button.WorkAreaButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.ide.modules.events.events.WorkAreaEvent;
	import net.vdombox.ide.modules.events.view.skins.WorkAreaSkin;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.SkinnableContainer;
	import spark.components.TextInput;
	import spark.skins.spark.PanelSkin;

	public class WorkArea extends SkinnableContainer
	{
		public function WorkArea()
		{
			setStyle( "skinClass", WorkAreaSkin );
			
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );

			addEventListener( ElementEvent.CREATE_LINKAGE, element_createLinkageHandler, true, 0, true );
			addEventListener( ElementEvent.DELETE, element_deleteHandler, true, 0, true );
			addEventListener( ElementEvent.MOVE, moveElementHandler, true, 0, true );
			addEventListener( ElementEvent.MOVED, unsaveHandler, true, 0, true );
			addEventListener( ElementEvent.STATE_CHANGED, unsaveHandler, true, 0, true );
			addEventListener( ElementEvent.PARAMETER_EDIT, unsaveHandler, true, 0, true );
			addEventListener( ElementEvent.DELETE_LINKAGE, linkage_deleteLinkageHandler, true, 0, true );
			
			addEventListener( ElementEvent.CLICK, elementClickHandler, true, 0, true );
			addEventListener( ElementEvent.MULTI_SELECTED, elementMultiSelectedHandler, true, 0, true );
			addEventListener( ElementEvent.MULTI_SELECT_MOVED, elementMultiSelectMovedHandler, true, 0, true );
		}

		[SkinPart]
		public var workLayers : Group;
		
		[SkinPart]
		public var scaleGroup : Group;

		[SkinPart]
		public var linkagesLayer : Group;
		
		[SkinPart]
		public var saveButton : WorkAreaButton;

		[SkinPart]
		public var redoButton : WorkAreaButton;
		
		[SkinPart]
		public var undoButton : WorkAreaButton;
		
		[SkinPart]
		public var showHiddenElements : CheckBox;
		
		[SkinPart]
		public var _showElementsView : DropDownList;
		
		[SkinPart]
		public var pageName : TextInput;
		
		[SkinPart]
		public var scroller : VDOMScroller;
		
		
		private var applicationEventsVO : ApplicationEventsVO;

		private var shadowLinkage : Linkage;
		private var shadowActionElement : ActionElement;
		private var shadowActionVO : ClientActionVO;

		private var clientActionElements : Object;
		private var serverActionElements : Object;
		
		private var multiSelectElements : Object;
		
		public function get showElementsView() : String
		{
			return _showElementsView.selectedItem as String;
		}
		
		public function set showElementsView( value : String ) : void
		{
			_showElementsView.selectedItem = value;
			if ( value != "Active" && value != "Active + Embedded" )
				_showElementsView.selectedItem = "Full View";
		}
			
		public function get dataProvider() : ApplicationEventsVO
		{
			return applicationEventsVO;
		}
		
		public function set dataProvider( value : ApplicationEventsVO ) : void
		{
			applicationEventsVO = value;

			removeAllElements();
			linkagesLayer.removeAllElements();

			if( !applicationEventsVO )
			{
				skin.currentState = "disabled";
				return;
			}
			
			addClientActions();
			
			addEvents();
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded( partName, instance );
			
			if( instance == saveButton )
			{
				saveButton.addEventListener( MouseEvent.CLICK, saveButton_clickHandler );
			}
			else if( instance == redoButton )
			{
				redoButton.addEventListener( MouseEvent.CLICK, redoButton_clickHandler );
			}
			else if( instance == undoButton )
			{
				undoButton.addEventListener( MouseEvent.CLICK, undoButton_clickHandler );
			}
		}
		
		private function addClientActions() : void
		{
			var clientActionVO : ClientActionVO;
			var actionElement : ActionElement;

			clientActionElements = {};
			
			for each ( clientActionVO in applicationEventsVO.clientActions )
			{
				actionElement = new ActionElement();
				clientActionElements[ clientActionVO.id ] = actionElement;
				
				actionElement.data = clientActionVO;
				
				addElement( actionElement );
			}
		}
		
		private function addEvents() : void
		{
			var eventObject : Object;
			var eventVO : EventVO;
			var eventElement : EventElement;
			
			var actionVO : IEventBaseVO;
			var actionElement : ActionElement;
			
			var linkage : Linkage;
			
			serverActionElements = {};
			
			for each ( eventObject in applicationEventsVO.events )
			{
				eventElement = new EventElement();
				eventElement.data = eventObject.eventVO;
				
				for each ( actionVO in eventObject.actions )
				{
					if( actionVO is ClientActionVO && clientActionElements[ actionVO.id ] )
					{
						actionElement = clientActionElements[ actionVO.id ] as ActionElement;
					}
					else if( actionVO is ServerActionVO )
					{
						actionVO = getServerActionVOByID( actionVO.id );
						
						if( actionVO )
						{
							if( serverActionElements[ actionVO.id ] )
							{
								actionElement = serverActionElements[ actionVO.id ];
							}
							else
							{
								actionElement = new ActionElement();
								
								serverActionElements[ actionVO.id ] = actionElement;
								
								actionElement.data = actionVO;
								
								addElement( actionElement );
							}
						}
					}
					
					if ( actionElement )
					{
						linkage = new Linkage();
						linkage.source = eventElement;
						linkage.target = actionElement;
						
						//TODO: The linkagesLayer can be created later, and in this moment equal null;
						linkagesLayer.addElement( linkage );
					}
				}
				
				addElement( eventElement );
			}
		}
		
		private function getServerActionVOByID( serverActionID : String ) : ServerActionVO
		{
			var result : ServerActionVO;
			var serverActionVO : ServerActionVO;
			
			if( !applicationEventsVO )
				return null;
			
			for each( serverActionVO in applicationEventsVO.serverActions )
			{
				if( serverActionVO.id == serverActionID )
				{
					result = serverActionVO;
					break;
				}
			}
			
			return result;
		}
		
		private function createEvent( eventVO : EventVO, coordinates : Point ) : void
		{
			// if event created before do nothing
			var aviableEvent : Object;
			
			for each ( aviableEvent in applicationEventsVO.events )
			{
				if ( aviableEvent.eventVO.objectID == eventVO.objectID && aviableEvent.eventVO.name == eventVO.name )
					return;
			}
			
			eventVO.left = coordinates.x;
			eventVO.top = coordinates.y;

			// push new eventVO into applicationEventsVO
			var eventObject : Object = { eventVO: eventVO, actions: [] };
			applicationEventsVO.events.push( eventObject );

			// add new eventElement to WorkArea
			var eventElement : EventElement = new EventElement();
			eventElement.data = eventVO;

			addElement( eventElement );
		}

		private function createClientAction( clientActionVO : ClientActionVO, coordinates : Point ) : void
		{
			// if action created before do nothing
			var aviableClientActionVO : ClientActionVO;

			/*if( applicationEventsVO && applicationEventsVO.clientActions )
			{
				for each ( aviableClientActionVO in applicationEventsVO.clientActions )
				{
					if ( aviableClientActionVO.name == clientActionVO.name )
						return;
				}
			}*/
			
			var newClientActionVO : ClientActionVO = clientActionVO.copy();
			

			newClientActionVO.left = coordinates.x;
			newClientActionVO.top = coordinates.y;

			applicationEventsVO.clientActions.push( newClientActionVO );

			var actionElement : ActionElement = new ActionElement();
			actionElement.data = newClientActionVO;

			addElement( actionElement );
		}

		private function createServerAction( serverActionVO : ServerActionVO, coordinates : Point ) : void
		{
			// if action created before do nothing
			
			if ( serverActionElements && serverActionElements.hasOwnProperty( serverActionVO.id ) )
				return;
			
			serverActionVO = applicationEventsVO.getServetActionByID( serverActionVO.id );
			if ( !serverActionVO )
				return;
			
			serverActionVO.left = coordinates.x;
			serverActionVO.top = coordinates.y;

			var actionElement : ActionElement = new ActionElement();
			actionElement.data = serverActionVO;
			
			if( !serverActionElements )
				serverActionElements = {};
				
			serverActionElements[ serverActionVO.id ] = actionElement; 
			addElement( actionElement );
		}

		private function deleteEventElement( eventElement : EventElement ) : void
		{
			var events : Array = applicationEventsVO.events;

			var eventVO : EventVO = eventElement.data as EventVO;
			var eventObject : Object;

			var i : uint;

			if ( !eventVO )
				return;

			var aviableEventVO : EventVO;

			for ( i = 0; i < events.length; i++ )
			{
				aviableEventVO = events[ i ].eventVO;

				if ( aviableEventVO.objectID == eventVO.objectID && aviableEventVO.name == eventVO.name )
					events.splice( i, 1 );
			}

			var linkage : Linkage;

			for ( i = 0; i < linkagesLayer.numElements; i++ )
			{
				linkage = linkagesLayer.getElementAt( i ) as Linkage;

				if ( linkage && linkage.source == eventElement )
				{
					linkagesLayer.removeElement( linkage );
					i--;
				}
			}

			if ( eventElement.owner == this )
				removeElement( eventElement );
		}

		private function deleteActionElement( actionElement : ActionElement ) : void
		{
			var i : uint;
			var j : uint;

			var linkage : Linkage;

			var events : Array = applicationEventsVO.events;
			var clientActions : Array = applicationEventsVO.clientActions;

			var actionVO : Object = actionElement.data;

			//Удаление action из соответствующего массива
			if ( actionVO is ClientActionVO )
			{
				for ( i = 0; i < clientActions.length; i++ )
				{
					if ( clientActions[ i ].name == actionVO.name && clientActions[ i ].objectID == actionVO.objectID 
					&& clientActions[ i ].id == actionVO.id)
						clientActions.splice( i, 1 );
				}
				
				delete clientActionElements[ actionVO.id ];
			}

			if ( actionVO is ServerActionVO )
				delete serverActionElements[ actionVO.id ];
			
			//Удаление ссылок из events на удаленный action 
			var actions : Array;

			for ( i = 0; i < events.length; i++ )
			{
				actions = events[ i ].actions;

				for ( j = 0; j < actions.length; j++ )
				{
					if ( NameUtil.getUnqualifiedClassName( actions[ j ] ) == NameUtil.getUnqualifiedClassName( actionVO ) &&
						actions[ j ].name == actionVO.name && actions[ j ].objectID == actionVO.objectID && actions[ j ].id == actionVO.id)
						actions.splice( j, 1 );
				}
			}

			//Удаление linkages на удаленный action
			for ( i = 0; i < linkagesLayer.numElements; i++ )
			{
				linkage = linkagesLayer.getElementAt( i ) as Linkage;

				if ( linkage && linkage.target == actionElement )
				{
					linkagesLayer.removeElement( linkage );
					i--;
				}
			}

			//Удаление actionElement
			if ( actionElement.owner == this )
				removeElement( actionElement );
		}

		private function getActionElementFromParent( object : DisplayObjectContainer ) : ActionElement
		{
			var parent : DisplayObjectContainer = object.parent as DisplayObjectContainer;
			var result : ActionElement;

			while ( parent )
			{
				if ( parent is ActionElement )
				{
					result = parent as ActionElement;
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

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			skin.currentState = "disabled";
			
			workLayers.addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
			workLayers.addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );
		}

		private function dragEnterHandler( event : DragEvent ) : void
		{
			DragManager.acceptDragDrop( workLayers );
		}

		private function dragDropHandler( event : DragEvent ) : void
		{
			var dragSource : DragSource = event.dragSource;
			var newElementVO : Object = dragSource.dataForFormat( "elementVO" );

			var coordinates : Point = new Point( event.localX + scroller.viewport.horizontalScrollPosition , event.localY + scroller.viewport.verticalScrollPosition );

			if ( newElementVO is EventVO )
				createEvent( newElementVO as EventVO, coordinates );
			else if ( newElementVO is ClientActionVO )
				createClientAction( newElementVO as ClientActionVO, coordinates );
			else if ( newElementVO is ServerActionVO )
				createServerAction( newElementVO as ServerActionVO, coordinates );
			
			unsaveHandler();
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();

			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, true );
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();

			removeEventListener( MouseEvent.CLICK, mouseClickHandler, true );
		}

		private function mouseMoveHandler( event : MouseEvent ) : void
		{
			shadowActionElement.x = linkagesLayer.contentMouseX;
			shadowActionElement.y = linkagesLayer.contentMouseY;
			
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			var actionElement : ActionElement = getActionElementFromParent( event.target as DisplayObjectContainer );

			if ( actionElement )
			{

				shadowLinkage.target = actionElement;
				shadowLinkage.alpha = 1;

			}
			else
			{
				shadowLinkage.target = shadowActionElement;
				shadowLinkage.alpha = 0.4;
			}

			event.stopImmediatePropagation();
		}

		private function rollOverHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
		}

		private function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			var actionElement : ActionElement = getActionElementFromParent( event.target as DisplayObjectContainer );

			if ( !actionElement )
			{
				removeEventListener( MouseEvent.CLICK, mouseClickHandler, true );
				removeShadowHandlers();

				if ( shadowLinkage && shadowLinkage.parent == linkagesLayer )
					linkagesLayer.removeElement( shadowLinkage );

//				shadowLinkage = null;
			}
			else
				stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler, true );
		}

		private function stage_mouseUpHandler( event : MouseEvent ) : void
		{
			var eventVO : IEventBaseVO;
			var actionVO : IEventBaseVO;

			try
			{
				eventVO = shadowLinkage.source.data;
				actionVO = shadowLinkage.target.data;
			}
			catch ( error : Error )
			{
			}

			var eventObject : Object;
			var aviableActionVO : Object;
			var isAviable : Boolean;

			if ( eventVO && actionVO )
			{
				for each ( eventObject in applicationEventsVO.events )
				{
					if ( eventObject.eventVO == eventVO )
					{
						isAviable = false;

						for each ( aviableActionVO in eventObject.actions )
						{
							if ( NameUtil.getUnqualifiedClassName( aviableActionVO ) == NameUtil.getUnqualifiedClassName( actionVO ) &&
								aviableActionVO.name == actionVO.name && aviableActionVO.objectID == actionVO.objectID )
							{
								isAviable = true;
								removeEventListener( MouseEvent.CLICK, mouseClickHandler, true );
								removeShadowHandlers();
									
								if ( shadowLinkage && shadowLinkage.parent == linkagesLayer )
										linkagesLayer.removeElement( shadowLinkage );

								break;
							}
						}

						if ( !isAviable )
						{
							eventObject.actions.push( actionVO );
							unsaveHandler();
						}

						break;
					}
				}
			}
			else
			{
				if ( shadowLinkage && shadowLinkage.parent == linkagesLayer )
					linkagesLayer.removeElement( shadowLinkage );
			}

			shadowLinkage = null;
			shadowActionElement = null;

			removeShadowHandlers();
		}
		
		private var point : Point;
		private var temp : Number;
		private var element : BaseElement;
		private var offsetX : Number;
		private var offsetY : Number;
		
		private var dx : int;
		private var dy : int;
		
		private var verticalScrollPosition : int;
		private var horizontalScrollPosition : int;
		
		private function changeSizeGroupToBottom( event : Event ) : void
		{
			element.moveElement( 0, dy );
			temp = element.y + offsetY - scroller.height / scaleGroup.scaleX;
			
			if ( temp > verticalScrollPosition )
				scroller.verticalScrollBar.viewport.verticalScrollPosition = temp;
			else
				removeEventListener( Event.ENTER_FRAME, changeSizeGroupToBottom );
		}
		
		private function changeSizeGroupToRight( event : Event ) : void
		{
			element.moveElement( dx, 0 );
			temp = ( element.x + offsetX ) - scroller.width / scaleGroup.scaleX;
			
			if ( temp > horizontalScrollPosition )
				scroller.horizontalScrollBar.viewport.horizontalScrollPosition = temp;
			else
				removeEventListener( Event.ENTER_FRAME, changeSizeGroupToRight );
		}
		
		private function changeSizeGroupToTop( event : Event ) : void
		{
			element.moveElement( 0, dy );
			
			if ( element.y + offsetY < verticalScrollPosition )
				scroller.verticalScrollBar.viewport.verticalScrollPosition = element.y + offsetY;
			else
				removeEventListener( Event.ENTER_FRAME, changeSizeGroupToTop );
		}
		
		private function changeSizeGroupToLeft( event : Event ) : void
		{
			element.moveElement( dx, 0 );
			
			if ( element.x + offsetX  < horizontalScrollPosition )
				scroller.horizontalScrollBar.viewport.horizontalScrollPosition =element.x + offsetX;
			else
				removeEventListener( Event.ENTER_FRAME, changeSizeGroupToLeft );
		}
			
		private function moveElementHandler( event : ElementEvent ) : void
		{
			element = event.target as BaseElement;
			
			offsetX = event.object.x;
			offsetY = event.object.y;
			
			dx = event.object.dx;
			dy = event.object.dy;
			
			verticalScrollPosition = scroller.verticalScrollBar.viewport.verticalScrollPosition;
			horizontalScrollPosition = scroller.horizontalScrollBar.viewport.horizontalScrollPosition;
			
			if ( verticalScrollPosition + ( element.y - verticalScrollPosition + offsetY ) * scaleGroup.scaleX > verticalScrollPosition + scroller.height )
				addEventListener( Event.ENTER_FRAME, changeSizeGroupToBottom, false, 0, true );
			
			if ( horizontalScrollPosition + ( element.x - horizontalScrollPosition + offsetX ) * scaleGroup.scaleX > horizontalScrollPosition + scroller.width )
				addEventListener( Event.ENTER_FRAME, changeSizeGroupToRight, false, 0, true );
			
			if ( element.y + offsetY < verticalScrollPosition )
				addEventListener( Event.ENTER_FRAME, changeSizeGroupToTop, false, 0, true );
			
			if ( element.x + offsetX  < horizontalScrollPosition )
				addEventListener( Event.ENTER_FRAME, changeSizeGroupToLeft, false, 0, true );
		}
		
		private function unsaveHandler( event : ElementEvent = null ) : void
		{
			skin.currentState = 'unsaved';
			
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.SET_MESSAGE ) );
		}
		
		private function saveButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.SAVE ) );
		}
		
		private function redoButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.REDO ) );
		}
		
		private function undoButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.UNDO ) );
		}
		
		private function element_createLinkageHandler( event : ElementEvent ) : void
		{
			shadowLinkage = new Linkage();

			var eventElement : EventElement = event.target as EventElement;
			shadowActionElement = new ActionElement();
			shadowActionElement.width = 0;

			shadowActionVO = new ClientActionVO();
			shadowActionVO.left = eventElement.x;
			shadowActionVO.top = eventElement.y;

			shadowActionElement.data = shadowActionVO;
			
			shadowActionElement.x = eventElement.x;
			shadowActionElement.y = eventElement.y;

			shadowLinkage.alpha = 0.4;

			shadowLinkage.source = eventElement;
			shadowLinkage.target = shadowActionElement;

			linkagesLayer.addElement( shadowLinkage );
			
			//sendSave();

			addShadowHandlers();
		}
		
		

		private function element_deleteHandler( event : ElementEvent ) : void
		{
			/*Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
			
			var strName : String = "";
			if (event.target is EventElement)
				strName = (event.target as EventElement).data.name;
			else if (event.target is ActionElement)
				strName = (event.target as ActionElement).title;
			
			Alert.Show( resourceManager.getString( 'Wysiwyg_General', 'delete_Renderer' ) + strName + " ?",AlertButton.OK_No, undoButton.parentApplication, deleteHandler);
				
			
			function deleteHandler(_event : CloseEvent) : void
			{
				if (_event.detail == Alert.YES)
				{*/
					if ( event.target is EventElement )
						deleteEventElement( event.target as EventElement );
					else if ( event.target is ActionElement )
						deleteActionElement( event.target as ActionElement );
					
					unsaveHandler();
				/*}
			}*/
		}
		
		private function linkage_deleteLinkageHandler( event : ElementEvent ) : void
		{
			var linkage : Linkage = event.target as Linkage;
			
			if( !linkage )
				return;
			
			var eventObject : Object;
			var actions : Array;
			
			for each ( eventObject in applicationEventsVO.events )
			{
				if( eventObject.eventVO == linkage.source.data )
				{
					actions = eventObject.actions as Array;
					break;
				}
			}
			
			if( !actions || actions.length == 0 )
				return;
			
			var i : uint;
			
			for ( i = 0; i < actions.length; i++ )
			{
				if( actions[ i ] == linkage.target.data )
				{
					actions.splice( i, 1 );
					break;
				}
			}
		
			unsaveHandler();
			
			if( linkage.parent == linkagesLayer )
				linkagesLayer.removeElement( linkage );
		}
		
		private function elementClickHandler( event : ElementEvent ) : void
		{
			var baseElement : BaseElement = event.target as BaseElement;
			
			removeAllSelectedElements();
			
			multiSelectElements = [];
			
			baseElement.selected = true;
			
			multiSelectElements[ baseElement.uniqueName ] = baseElement;
		}
		
		private function elementMultiSelectedHandler( event : ElementEvent ) : void
		{
			var baseElement : BaseElement = event.target as BaseElement;
			
			if ( !baseElement.selected )
			{
				delete multiSelectElements[ baseElement.uniqueName ];
				return;
			}
			
			if ( !multiSelectElements )
				multiSelectElements = [];
			
			multiSelectElements[ baseElement.uniqueName ] = baseElement;
		}
		
		private function elementMultiSelectMovedHandler( event : ElementEvent ) : void
		{
			var dx : int = event.object.dx;
			var dy : int = event.object.dy;
			
			var baseElement : BaseElement;
			var target : BaseElement = event.target as BaseElement;
			
			for each ( baseElement in multiSelectElements )
				if ( !baseElement.hasMoved( dx, dy ) )
					return;
			
			for each ( baseElement in multiSelectElements )
				baseElement.moveTo( dx, dy, target );
		}
		
		
		public function removeAllSelectedElements ( ) : void
		{
			if ( multiSelectElements )
			{
				var element : BaseElement;
				for each ( element in multiSelectElements )
					element.selected = false;
				
				multiSelectElements = null;
			}
		}
		
		public function setMultiSelectInRect ( rectLeft : int, rectTop : int, rectRigth : int, rectBottom : int ) : void
		{
			var count : int = contentGroup.numElements;
			
			var i : int;
			var baseElement : BaseElement;
			
			for ( i = 0; i < count; i++ )
			{
				baseElement = contentGroup.getElementAt( i ) as BaseElement;
				
				if ( baseElement.x + baseElement.width > rectLeft && baseElement.x < rectRigth
					&& baseElement.y + baseElement.height > rectTop && baseElement.y < rectBottom )
				{
					baseElement.selected = true;
					
					if ( !multiSelectElements )
						multiSelectElements = [];
					
					multiSelectElements[ baseElement.uniqueName ] = baseElement;
				}
			}
		}
		
		public function get showHidden():Boolean
		{
			return showHiddenElements.selected;
		}
		
		public function set showHidden( value : Boolean ) : void
		{
			showHiddenElements.selected = value;
		}
		
		public function setVisibleStateForAllLinkages( showHiddedNeed : Boolean = true ) : void
		{
			var i : Number;
			var linkage : Linkage;
			
			for ( i = 0; i < linkagesLayer.numElements; i++ )
			{
				linkage = linkagesLayer.getElementAt( i ) as Linkage;
				
				if ( !linkage )
					return;
				
				if ( showHiddedNeed )
					linkage.setVisibleState( showHidden );
				else
					linkage.setVisibleState( false );
			}
		}
		
		public function setVisibleStateForCurrnetLinkages( itemID : Object ) : void
		{
			var i : Number;
			var linkage : Linkage;
			var baseElement : BaseElement;
			
			
			
			if ( itemID is String )
			{
				var objectID : String = itemID as String;
				
				for ( i = 0; i < linkagesLayer.numElements; i++ )
				{
					linkage = linkagesLayer.getElementAt( i ) as Linkage;
				
					if ( !linkage )
						return;
					
					if ( linkage.source.objectID == objectID && linkage.target.objectID != objectID)
					{
						baseElement = linkage.target;
						baseElement.visible = true;
						baseElement.alpha = 0.3;
						linkage.visible = true;
						linkage.alpha = 0.3;
					}
					else if ( linkage.source.objectID != objectID && linkage.target.objectID == objectID )
					{
						baseElement = linkage.source;
						baseElement.visible = true;
						baseElement.alpha = 0.3;
						linkage.visible = true;
						linkage.alpha = 0.3;
					}
					else
					{
						linkage.setVisibleState( false );	
					}
				}
			}
			else if ( itemID is Array )
			{
				var objectsID : Array = itemID as Array;
				
				for ( i = 0; i < linkagesLayer.numElements; i++ )
				{
					linkage = linkagesLayer.getElementAt( i ) as Linkage;
					
					if ( !linkage )
						return;
					
					if ( findIDinArray( linkage.source.objectID, objectsID) && !findIDinArray( linkage.target.objectID, objectsID ) )
					{
						baseElement = linkage.target;
						baseElement.visible = true;
						baseElement.alpha = 0.3;
						linkage.visible = true;
						linkage.alpha = 0.3;
					}
					else if ( !findIDinArray( linkage.source.objectID, objectsID) && findIDinArray( linkage.target.objectID, objectsID ) )
					{
						baseElement = linkage.source;
						baseElement.visible = true;
						baseElement.alpha = 0.3;
						linkage.visible = true;
						linkage.alpha = 0.3;
					}
					else
					{
						linkage.setVisibleState( false );	
					}
				}
			}
		}
		
		private function findIDinArray( objectID : String, arrayID : Array ) : Boolean
		{
			var itemID : String;
			for each ( itemID in arrayID )
			{
				if ( itemID == objectID)
					return true;
			}
			return false;
		}

	}
}