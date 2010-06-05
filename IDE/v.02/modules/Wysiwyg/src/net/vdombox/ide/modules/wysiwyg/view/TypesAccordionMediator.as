package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import mx.containers.Accordion;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.TypesProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypesCategory;
	
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
		
		private var categories : Array = [];

		private var isActive : Boolean;
		
		public function get typesAccordion() : Accordion
		{
			return viewComponent as Accordion;
		}

		override public function onRegister() : void
		{
			isActive = false;
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
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
						
						showTypes();
						
						break;
					}
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;
					
					clearData();
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			typesAccordion.addEventListener( "TypeRendererCreated", typeRendererCreatedHandler, true, 0, false );
		}

		private function removeHandlers() : void
		{
			typesAccordion.removeEventListener( "TypeRendererCreated", typeRendererCreatedHandler, true );
		}

		private function clearData() : void
		{
			typesAccordion.removeAllChildren();
			categories = [];
		}
		
		private function showTypes() : void
		{
			var types : Array = typesProxy.types;
			
			var type : TypeVO;
			var category : TypesCategory;
			
			var label : Label;
			
			for ( var i : int = 0; i < types.length; i++ )
			{
				type = types[ i ] as TypeVO;
				
				category = insertCategory( type.category );
				
				category.addType( type );
			}
		}
		
		private function insertCategory( categoryName : String ) : TypesCategory
		{
			var currentCategory : TypesCategory;

			if ( !categories[ categoryName ] )
			{
				currentCategory = new TypesCategory();

				categories[ categoryName ] = currentCategory;

				currentCategory.label = categoryName;

				typesAccordion.addChild( currentCategory );
			}
			else
			{
				currentCategory = categories[ categoryName ];
			}

			return currentCategory;
		}

		private function typeRendererCreatedHandler( event : Event ) : void
		{
			var typeItemRenderer : TypeItemRenderer = event.target as TypeItemRenderer;

			var typeVO : TypeVO = typeItemRenderer.data as TypeVO;

			var resourceVO : ResourceVO = new ResourceVO( typeVO.id );
			resourceVO.setID( typeVO.iconID );

			typeItemRenderer.resourceVO = resourceVO;

			sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
		}
	}
}