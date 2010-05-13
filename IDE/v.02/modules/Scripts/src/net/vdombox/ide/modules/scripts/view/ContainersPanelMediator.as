package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ContainersPanelEvent;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	import net.vdombox.ide.modules.scripts.view.components.ContainersPanel;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ContainersPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ContainersPanelMediator";

		public function ContainersPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var types : Array;

		private var currentPageVO : PageVO;
		private var currentObjectVO : ObjectVO;

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		private var isPageChanged : Boolean;
		private var isObjectChanged : Boolean;

		public function get containersPanel() : ContainersPanel
		{
			return viewComponent as ContainersPanel;
		}

		override public function onRegister() : void
		{
			isActive = false;

			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.TYPES_GETTED );
			interests.push( ApplicationFacade.STRUCTURE_GETTED );

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_TYPES );
					}

					break;
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.TYPES_GETTED:
				{
					types = body as Array;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					commitProperties();

					break;
				}

				case ApplicationFacade.STRUCTURE_GETTED:
				{
					var structure : XML = body as XML;
					var typeVO : TypeVO;

					var objects : XMLList = structure..object;

					var i : uint;

					for ( i = 0; i < objects.length(); i++ )
					{
						typeVO = getTypeByID( objects[ i ].@typeID );
						if ( typeVO.container == 1 )
						{
							delete objects[ i ];
							i--;
						}
					}

					containersPanel.structure = structure;
					containersPanel.validateNow();

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			containersPanel.addEventListener( ContainersPanelEvent.CONTAINER_CHANGED, containerChangedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			containersPanel.removeEventListener( ContainersPanelEvent.CONTAINER_CHANGED, containerChangedHandler );
		}

		private function commitProperties() : void
		{

			if ( ( sessionProxy.selectedPage && !currentPageVO ) ||
				( sessionProxy.selectedPage && currentPageVO && sessionProxy.selectedPage.id != currentPageVO.id ) )
			{
				currentPageVO = sessionProxy.selectedPage;
				currentObjectVO = null;
				
				sendNotification( ApplicationFacade.GET_STRUCTURE, { pageVO: currentPageVO } );
				
				return;
			}
			else if( !sessionProxy.selectedPage )
			{
				if ( currentPageVO )
					currentPageVO = null;

				currentObjectVO = null;
				containersPanel.structure = null;
				
				return;
			}
			
			if( ( sessionProxy.selectedObject && !currentObjectVO ) ||
				( sessionProxy.selectedObject && currentObjectVO && sessionProxy.selectedObject.id != currentObjectVO.id ) )
			{
				currentObjectVO = sessionProxy.selectedObject;
				containersPanel.selectedObjectID = currentObjectVO.id;
			}
			else if( !sessionProxy.selectedObject )
			{
				if( currentObjectVO )
					currentObjectVO = null;
				
				containersPanel.selectedObjectID = "";
			}
		}

		private function clearData() : void
		{
			currentPageVO = null;
			currentObjectVO = null;
			
			containersPanel.structure = null;
		}

		private function getTypeByID( typeID : String ) : TypeVO
		{
			var result : TypeVO;
			var typeVO : TypeVO;

			for each ( typeVO in types )
			{
				if ( typeVO.id == typeID )
				{
					result = typeVO;
					break;
				}
			}

			return result;
		}

		private function containerChangedHandler( event : ContainersPanelEvent ) : void
		{
			var selectedItem : XML = containersPanel.selectedItem;
			var selectedObject : ObjectVO;
			
			var typeVO : TypeVO;

			if( !selectedItem )
				return;
			
			 typeVO = getTypeByID( selectedItem.@typeID )

			if ( selectedItem.name() == "object" )
			{
				selectedObject = new ObjectVO( sessionProxy.selectedPage, typeVO );
				selectedObject.setID( selectedItem.@id );
			}

			sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );
		}
	}
}