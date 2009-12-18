package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	import net.vdombox.ide.common.vo.ApplicationPropertiesVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.events.EditApplicationViewEvent;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;
	import net.vdombox.ide.modules.applicationsManagment.view.components.EditApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class EditApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EditApplicationViewMediator";

		public function EditApplicationViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private const ACTIONS_TEMPLATE : String = "Actions for {0}";

		private const PO_TEMPLATE : String = "PAGES: {0}\nOBJECTS: {1}";

		private var settings : SettingsVO;

		private var applications : Array;

		private var applicationsChanged : Boolean;

		private var selectedApplication : ApplicationVO;

		private var selectedApplicationChanged : Boolean;

		override public function onRegister() : void
		{
			addEventListeners();

			applicationsList.itemRenderer = new ClassFactory( ApplicationItemRenderer );

			sendNotification( ApplicationFacade.GET_SETTINGS, NAME );
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.APPLICATIONS_LIST_GETTED );
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );

			interests.push( NAME + "/" + ApplicationFacade.SETTINGS_GETTED );
			interests.push( ApplicationFacade.SETTINGS_CHANGED );
			interests.push( ApplicationFacade.APPLICATION_EDITED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			switch ( notification.getName())
			{
				case ApplicationFacade.APPLICATIONS_LIST_GETTED:
				{
					applications = notification.getBody() as Array;
					applicationsChanged = true;

					break;
				}

				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					var newSelectedApplication : ApplicationVO = notification.getBody() as ApplicationVO;

					if ( newSelectedApplication && newSelectedApplication == selectedApplication )
						return;

					selectedApplication = newSelectedApplication;
					selectedApplicationChanged = true;

					break;
				}

				case NAME + "/" + ApplicationFacade.SETTINGS_GETTED:
				{
				}

				case ApplicationFacade.SETTINGS_CHANGED:
				{
					settings = body as SettingsVO;

					break;
				}
				
				case ApplicationFacade.APPLICATION_EDITED:
				{
					var applicationVO : ApplicationVO = body as ApplicationVO;
					
					if ( applicationVO === selectedApplication )
						refreshApplicationProperties();
					
					break;
				}
			}

			commitProperties();
		}

		private function get editApplicationView() : EditApplicationView
		{
			return viewComponent as EditApplicationView;
		}

		private function get applicationsList() : List
		{
			return editApplicationView.applicationsList;
		}

		private function addEventListeners() : void
		{
			editApplicationView.addEventListener( EditApplicationViewEvent.APPLICATION_NAME_CHANGED, applicationNameChangedHandler )

			applicationsList.addEventListener( ApplicationItemRenderer.RENDERER_CREATED, applicationItemRenderer_rendererCreatedHandler, true );

			applicationsList.addEventListener( IndexChangeEvent.CHANGE, applicationsList_changeHandler );
		}

		private function commitProperties() : void
		{
			if ( applicationsChanged )
			{
				applicationsChanged = false;

				applicationsList.dataProvider = new ArrayList( applications );
			}

			if ( selectedApplicationChanged )
			{
				selectedApplicationChanged = false;

				if ( selectedApplication )
				{
					applicationsList.selectedItem = selectedApplication;
					
					refreshApplicationProperties();

					if ( settings && settings.saveLastApplication && settings.lastApplicationID != selectedApplication.id )
					{
						settings.lastApplicationID = selectedApplication.id

						sendNotification( ApplicationFacade.SET_SETTINGS, settings );
					}
				}
				else
				{
					if ( !settings || !settings.saveLastApplication || !settings.lastApplicationID || !applications )
						return;

					for ( var i : int = 0; i < applications.length; i++ )
					{
						if ( applications[ i ].id == settings.lastApplicationID )
						{
							sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, applications[ i ]);
							return;
						}
					}
				}
			}
		}
		
		private function refreshApplicationProperties() : void
		{
			editApplicationView.applicationName.text = selectedApplication.name;
			editApplicationView.actionsForLabel.text = StringUtil.substitute( ACTIONS_TEMPLATE, selectedApplication.name );
			editApplicationView.counts.text = StringUtil.substitute( PO_TEMPLATE, selectedApplication.numberOfPages, selectedApplication.numberOfObjects )
			editApplicationView.applicationDescription.text = selectedApplication.description;
		}
		
		private function applicationNameChangedHandler( event : EditApplicationViewEvent ) : void
		{
			var newApplicationName : String = editApplicationView.newApplicationName.text;

			if ( newApplicationName && newApplicationName == selectedApplication.name )
				return;

			var applicationProperties : ApplicationPropertiesVO = new ApplicationPropertiesVO;
			applicationProperties.name = newApplicationName;

			sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: selectedApplication, applicationPropertiesVO: applicationProperties });
		}

		private function applicationItemRenderer_rendererCreatedHandler( event : Event ) : void
		{
			var renderer : ApplicationItemRenderer = event.target as ApplicationItemRenderer;

			var mediator : ApplicationItemRendererMediator = new ApplicationItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}

		private function applicationsList_changeHandler( event : IndexChangeEvent ) : void
		{
			var newSelectedApplication : ApplicationVO;

			if ( event.newIndex != -1 )
				newSelectedApplication = applications[ event.newIndex ] as ApplicationVO;

			if ( selectedApplication != newSelectedApplication )
			{
				selectedApplication = newSelectedApplication;
				selectedApplicationChanged = true;
				commitProperties();
			}
		}
	}
}