package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ContainersPanelEvent;
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

		private var selectedPageVO : PageVO;

		public function get containersPanel() : ContainersPanel
		{
			return viewComponent as ContainersPanel;
		}

		override public function onRegister() : void
		{
			addHandlers();

			sendNotification( ApplicationFacade.GET_TYPES );
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.TYPES_GETTED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			interests.push( ApplicationFacade.STRUCTURE_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.TYPES_GETTED:
				{
					types = body as Array;

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					selectedPageVO = body as PageVO;

					sendNotification( ApplicationFacade.GET_STRUCTURE, { pageVO: selectedPageVO } );

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					var objectVO : ObjectVO = body as ObjectVO;
					var objectID : String;

					if( objectVO )
						objectID = objectVO.id;
					
					if( containersPanel.selectedObjectID != objectID )
						containersPanel.selectedObjectID = objectID;
						
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
					containersPanel.selectedObjectID = selectedPageVO.id;
					
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

			var typeVO : TypeVO = getTypeByID( selectedItem.@typeID )

			if ( selectedItem.name() == "object" )
				selectedObject = new ObjectVO( selectedItem.@id, selectedPageVO, typeVO );
			
			sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );
		}
	}
}