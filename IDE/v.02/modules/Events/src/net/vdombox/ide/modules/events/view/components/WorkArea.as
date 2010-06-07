package net.vdombox.ide.modules.events.view.components
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.DragSource;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.utils.NameUtil;
	
	import net.vdombox.ide.common.vo.ApplicationEventsVO;
	import net.vdombox.ide.common.vo.ClientActionVO;
	import net.vdombox.ide.common.vo.EventVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.ide.modules.events.events.WorkAreaEvent;
	import net.vdombox.ide.modules.events.view.skins.WorkAreaSkin;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.SkinnableContainer;
	import spark.skins.spark.PanelSkin;

	public class WorkArea extends SkinnableContainer
	{
		public function WorkArea()
		{
			setStyle( "skinClass", WorkAreaSkin );
			
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );

			addEventListener( ElementEvent.CREATE_LINKAGE, element_createLinkageHandler, true, 0, true );
			addEventListener( ElementEvent.DELETE, element_deleteHandler, true, 0, true );
			addEventListener( ElementEvent.MOVED, element_movedHandler, true, 0, true );
			addEventListener( ElementEvent.STATE_CHANGED, element_stateChangedHandler, true, 0, true );
			addEventListener( ElementEvent.DELETE_LINKAGE, linkage_deleteLinkageHandler, true, 0, true );
		}

		[SkinPart]
		public var workLayers : Group;

		[SkinPart]
		public var linkagesLayer : Group;

		[SkinPart]
		public var saveButton : WorkAreaButton;
		
		[SkinPart]
		public var undoButton : WorkAreaButton;
		
		private var applicationEventsVO : ApplicationEventsVO;

		private var shadowLinkage : Linkage;
		private var shadowActionElement : ActionElement;
		private var shadowActionVO : ClientActionVO;

		private var clientActionElements : Object;
		private var serverActionElements : Object;
		
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
			else
			{
				skin.currentState = "normal";
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
			
			var actionVO : Object;
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
			
			skin.currentState = "unsaved";
		}

		private function createClientAction( clientActionVO : ClientActionVO, coordinates : Point ) : void
		{
			// if action created before do nothing
			var aviableClientActionVO : ClientActionVO;

			if( applicationEventsVO && applicationEventsVO.clientActions )
			{
				for each ( aviableClientActionVO in applicationEventsVO.clientActions )
				{
					if ( aviableClientActionVO.name == clientActionVO.name )
						return;
				}
			}

			clientActionVO.left = coordinates.x;
			clientActionVO.top = coordinates.y;

			applicationEventsVO.clientActions.push( clientActionVO );

			var actionElement : ActionElement = new ActionElement();
			actionElement.data = clientActionVO;

			addElement( actionElement );
			
			skin.currentState = "unsaved";
		}

		private function createServerAction( serverActionVO : ServerActionVO, coordinates : Point ) : void
		{
			// if action created before do nothing
			
			if ( serverActionElements && serverActionElements.hasOwnProperty( serverActionVO.id ) )
				return;
			
			serverActionVO.left = coordinates.x;
			serverActionVO.top = coordinates.y;

			var actionElement : ActionElement = new ActionElement();
			actionElement.data = serverActionVO;
			
			if( !serverActionElements )
				serverActionElements = {};
				
			serverActionElements[ serverActionVO.id ] = actionElement; 
			addElement( actionElement );
			
			skin.currentState = "unsaved";
		}

		private function deleteEventElement( eventElement : EventElement ) : void
		{
			var events : Array = applicationEventsVO.events;

			var eventVO : EventVO = eventElement.data;
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
			
			skin.currentState = "unsaved";
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
					if ( clientActions[ i ].name == actionVO.name )
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
						actions[ j ].name == actionVO.name )
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
			
			skin.currentState = "unsaved";
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

			var coordinates : Point = new Point( event.localX, event.localY );

			if ( newElementVO is EventVO )
				createEvent( newElementVO as EventVO, coordinates );
			else if ( newElementVO is ClientActionVO )
				createClientAction( newElementVO as ClientActionVO, coordinates );
			else if ( newElementVO is ServerActionVO )
				createServerAction( newElementVO as ServerActionVO, coordinates );
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
			shadowActionVO.left = linkagesLayer.contentMouseX;
			shadowActionVO.top = linkagesLayer.contentMouseY;
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
			var eventVO : EventVO;
			var actionVO : Object;

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
								aviableActionVO.name == actionVO.name )
							{
								isAviable = true;
								break;
							}
						}

						if ( !isAviable )
						{
							eventObject.actions.push( actionVO );
							skin.currentState = "unsaved";
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

		private function saveButton_clickHandler( event : MouseEvent ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.SAVE ) );
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

			shadowLinkage.alpha = 0.4;

			shadowLinkage.source = eventElement;
			shadowLinkage.target = shadowActionElement;

			linkagesLayer.addElement( shadowLinkage );

			addShadowHandlers();
		}

		private function element_deleteHandler( event : ElementEvent ) : void
		{
			if ( event.target is EventElement )
				deleteEventElement( event.target as EventElement );
			else if ( event.target is ActionElement )
				deleteActionElement( event.target as ActionElement );

			//TODO: сделать нормально
			skin.currentState = "unsaved";
		}

		private function element_movedHandler( event : ElementEvent ) : void
		{
			skin.currentState = "unsaved";
		}

		private function element_stateChangedHandler( event : ElementEvent ) : void
		{
			skin.currentState = "unsaved";
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
		
			skin.currentState = "unsaved";
			
			if( linkage.parent == linkagesLayer )
				linkagesLayer.removeElement( linkage );
		}

	}
}