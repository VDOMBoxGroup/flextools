package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.containers.Accordion;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.events.TypeItemRendererEvent;
	import net.vdombox.ide.modules.wysiwyg.model.UserTypesProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypesCategory;
	import net.vdombox.ide.modules.wysiwyg.view.components.panels.ToolBoxPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Label;

	public class TypesAccordionMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TypesAccordionMediator";

		public function TypesAccordionMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var statesProxy : StatesProxy;
		private var typesProxy : TypesProxy;
		private var userTypesProxy : UserTypesProxy;

		private var isActive : Boolean;
		
		private var zeroPoint : Point = new Point( 0, 0 );
		
		public function get toolboxPanel() : ToolBoxPanel
		{
			return viewComponent as ToolBoxPanel;
		}
		
		public function get typesAccordion() : Accordion
		{
			return toolboxPanel.typesAccordion;
		}

		override public function onRegister() : void
		{
			isActive = false;
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			userTypesProxy = facade.retrieveProxy( UserTypesProxy.NAME) as UserTypesProxy;
			
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
			
			toolboxPanel.clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;
			
			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						
						toolboxPanel.userTypes = userTypesProxy.getTypes();
						toolboxPanel.types = typesProxy.types;
						
						break;
					}
				}
					
				case Notifications.BODY_STOP:
				{
					isActive = false;
					
					toolboxPanel.clearData();
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			
			typesAccordion.addEventListener( FlexEvent.DATA_CHANGE, typeRendererCreatedHandler, true);
			typesAccordion.addEventListener( TypeItemRendererEvent.ADD_IN_USER_CATIGORY, addInUserCategory, true );
			typesAccordion.addEventListener( TypeItemRendererEvent.DELET_IN_USER_CATIGORY, delFromUserCategory, true );
			typesAccordion.addEventListener( TypeItemRendererEvent.DOUBLE_CLICK, createNewObjectHandler, true, 0 , true );
		}

		private function removeHandlers() : void
		{
			typesAccordion.removeEventListener( FlexEvent.DATA_CHANGE, typeRendererCreatedHandler, true);
			typesAccordion.removeEventListener( TypeItemRendererEvent.ADD_IN_USER_CATIGORY, addInUserCategory, true );
			typesAccordion.removeEventListener( TypeItemRendererEvent.DELET_IN_USER_CATIGORY, delFromUserCategory, true );
			typesAccordion.removeEventListener( TypeItemRendererEvent.DOUBLE_CLICK, createNewObjectHandler, true );
		}

		private function typeRendererCreatedHandler( event : FlexEvent ) : void
		{
			var typeItemRenderer : TypeItemRenderer = event.target as TypeItemRenderer;

			var typeVO : TypeVO = typeItemRenderer.data as TypeVO;

			var resourceVO : ResourceVO = new ResourceVO( typeVO.id );
			resourceVO.setID( typeVO.iconID );

			typeItemRenderer.resourceVO = resourceVO;

			sendNotification( Notifications.LOAD_RESOURCE, resourceVO );
		}
		
		private function addInUserCategory( event : TypeItemRendererEvent ) : void
		{
			var typeRenderer : TypeItemRenderer = event.target as TypeItemRenderer;
			if ( !typeRenderer )
				return;
			
			userTypesProxy.addTypeId( typeRenderer.typeVO.id );
			
			toolboxPanel.updateUserCategory();
		}
		
		private function delFromUserCategory( event : TypeItemRendererEvent ) : void
		{
			var typeRenderer : TypeItemRenderer = event.target as TypeItemRenderer;
			if ( !typeRenderer )
				return;
			
			userTypesProxy.removeTypeId( typeRenderer.typeVO.id );
			
			toolboxPanel.updateUserCategory();
		}
		
		private function createNewObjectHandler( event : TypeItemRendererEvent ) : void
		{
			var typeRenderer : TypeItemRenderer = event.target as TypeItemRenderer;
			if ( !typeRenderer )
				return;
			
			var vdomObjectVO : IVDOMObjectVO;
			if ( statesProxy.selectedObject )
				vdomObjectVO = statesProxy.selectedObject;
			else
				vdomObjectVO = statesProxy.selectedPage;
			
			sendNotification( Notifications.CREATE_OBJECT_REQUEST, { vdomObjectVO: vdomObjectVO, typeVO: typeRenderer.typeVO, point: zeroPoint } )
		}
	}
}