package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.view.components.CreateEditApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class CreateEditApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateEditApplicationViewMediator";
		
		private var applicationVO : ApplicationVO;
		
		public function CreateEditApplicationViewMediator(viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get createEditApplicationView() : CreateEditApplicationView
		{
			return viewComponent as CreateEditApplicationView;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW:
				{
					applicationVO = body as ApplicationVO;
					
					break;
				}
					
			}
			commitProperties();
		}
		
		private function commitProperties() : void
		{
			if ( applicationVO )
			{
				createEditApplicationView.txtapplicationName.text = applicationVO.name;
				createEditApplicationView.txtapplicationDescription.text = applicationVO.description;
			}
			
		}
		
		override public function onRegister() : void
		{
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			createEditApplicationView.addEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			facade.registerMediator( new IconChooserMediator( createEditApplicationView.iconChooser ) );
		}
		
		private function removeHandlers() : void
		{
			createEditApplicationView.removeEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			facade.removeMediator( IconChooserMediator.NAME );
		}
		
		private function saveInformationHandler( event : ApplicationManagerWindowEvent ) : void
		{
			if ( applicationVO )
			{
				var newApplicationName : String = createEditApplicationView.txtapplicationName.text;
				
				if ( newApplicationName == "" )
					return;
				
				var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
				
				if ( newApplicationName != applicationVO.name )
					applicationInformationVO.name = newApplicationName;
				
				var newApplicationDescription : String = createEditApplicationView.txtapplicationDescription.text;
				
				if ( newApplicationDescription != applicationVO.description )
					applicationInformationVO.description = newApplicationDescription;
				
				sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
					applicationInformationVO: applicationInformationVO } );
			}
			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_CHANGE_VIEW );
		}
		
		
	}
}