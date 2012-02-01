package net.vdombox.ide.modules.wysiwyg.view
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.AttributeDescriptionVO;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.panels.HelpPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class HelpPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "HelpPanelMediator";
		
		public function HelpPanelMediator( viewComponent : HelpPanel )
		{
			super( NAME, viewComponent );
		}
		
		private var statesProxy : StatesProxy;
		
		private var isActive : Boolean;
		
		public function get helpPanel() : HelpPanel
		{
			return viewComponent as HelpPanel;
		}
		
		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			isActive = false;
			
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
			
			interests.push( ApplicationFacade.CURRENT_ATTRIBUTE_CHANGED );
			
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
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						
						break;
					}
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;
					
					clearData();
					
					break;
				}
					
				case ApplicationFacade.CURRENT_ATTRIBUTE_CHANGED:
				{
					Alert
					var currentAttribute : Object = body as Object;
					var attributeDescription : AttributeDescriptionVO;
					
					if( currentAttribute && currentAttribute.hasOwnProperty( "attributeDescriptionVO" ) && currentAttribute.attributeDescriptionVO )
					{
						attributeDescription = currentAttribute.attributeDescriptionVO;
						helpPanel.text = attributeDescription.help;
					}
					else
					{
						helpPanel.text = "";
					}
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
		}
		
		private function removeHandlers() : void
		{
		}
		
		private function clearData() : void
		{
			helpPanel.text = "";
		}
	}
}