package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Accordion;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.TypeItemRendererEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
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

//		private const STANDART_CATEGORIES : Array = [ "usual", "standard", "form", "table", "database", "debug" ];

//		private const USUAL_ELEMENTS : Array = [ "button", "copy", "image", "richtext" ];
		
		private var sessionProxy : SessionProxy;
		private var typesProxy : TypesProxy;
		private var userTypesProxy : UserTypesProxy;

		private var isActive : Boolean;
		
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
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );
			
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
						
						toolboxPanel.userTypes = userTypesProxy.getTypes();
						toolboxPanel.types = typesProxy.types;
						
						break;
					}
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;
					
					toolboxPanel.clearData();
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			
			typesAccordion.addEventListener( FlexEvent.DATA_CHANGE, typeRendererCreatedHandler, true );
			typesAccordion.addEventListener( TypeItemRendererEvent.ADD_IN_USER_CATIGORY, addInUserCategory, true );
			typesAccordion.addEventListener( TypeItemRendererEvent.DELET_IN_USER_CATIGORY, delFromUserCategory, true );
		}

		private function removeHandlers() : void
		{
			typesAccordion.removeEventListener( FlexEvent.DATA_CHANGE, typeRendererCreatedHandler, true);
			typesAccordion.removeEventListener( TypeItemRendererEvent.ADD_IN_USER_CATIGORY, addInUserCategory, true );
			typesAccordion.removeEventListener( TypeItemRendererEvent.DELET_IN_USER_CATIGORY, delFromUserCategory, true );
		}

		private function typeRendererCreatedHandler( event : FlexEvent ) : void
		{
			var typeItemRenderer : TypeItemRenderer = event.target as TypeItemRenderer;

			var typeVO : TypeVO = typeItemRenderer.data as TypeVO;

			var resourceVO : ResourceVO = new ResourceVO( typeVO.id );
			resourceVO.setID( typeVO.iconID );

			typeItemRenderer.resourceVO = resourceVO;

			sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
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
	}
}