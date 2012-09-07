package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.LoginViewEvent;
	import net.vdombox.ide.core.model.LocalesProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.model.vo.HostVO;
	import net.vdombox.ide.core.model.vo.LocaleVO;
	import net.vdombox.ide.core.view.components.LoginView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class LoginViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginView";

		public function LoginViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var localeProxy : LocalesProxy;

		private var sharedObjectProxy : SharedObjectProxy;
		
		public var selectedHost : HostVO;
		
		public var selectedHostIndex : int;

		public function get username() : String
		{
			return loginView.username;
		}
		
		public function get password() : String
		{
			return loginView.password;
		}
		
		public function get hostname() : String
		{
			return loginView.host.textInput.text;
		}
		
		public function get needSave() : Boolean
		{
			return  loginView.saveButton.currentState == "save" ;
		}
		
		override public function onRegister() : void
		{
			
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;

			addHandlers();
			
			try
			{
				validateProperties();
			}
			catch ( e : Error )
			{
			}
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SUBMIN_CLICK );
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.SUBMIN_CLICK:
				{
					submit();
					
					break;
				}
			}
		}
		
		private function get loginView() : LoginView
		{
			return viewComponent as LoginView;
		}

		private function addHandlers() : void
		{
			loginView.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
			
			loginView.addEventListener( FlexEvent.SHOW, showHandler, false, 0, true);
			
			loginView.addEventListener( LoginViewEvent.SUBMIT, submitHandler, false, 0, true );

			loginView.addEventListener( LoginViewEvent.LANGUAGE_CHANGED, languageChangedHandler, false, 0, true );
			
			loginView.addEventListener( LoginViewEvent.DELETE_CLICK, deleteHostHandler, false, 0, true );
			
			loginView.user.addEventListener( Event.CHANGE, usernameChangeHandler , false, 0, true);
			
			loginView.host.addEventListener( FlexEvent.CREATION_COMPLETE, createCompleteHostHandler , false, 0, true);
			
		}

		private function removeHandlers() : void
		{
		
			loginView.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			
			loginView.removeEventListener( FlexEvent.SHOW, showHandler);
			
			loginView.removeEventListener( LoginViewEvent.SUBMIT, submitHandler );

			loginView.removeEventListener( LoginViewEvent.LANGUAGE_CHANGED, languageChangedHandler );
			
			loginView.removeEventListener( LoginViewEvent.DELETE_CLICK, deleteHostHandler );
			
			loginView.host.removeEventListener( Event.CHANGE, setLoginInformation);
			
			loginView.user.removeEventListener( Event.CHANGE, usernameChangeHandler );
			
			loginView.host.removeEventListener( FlexEvent.CREATION_COMPLETE, createCompleteHostHandler );
		}
		
		private function createCompleteHostHandler( event : FlexEvent ) : void
		{
			
			loginView.host.textInput.addEventListener( Event.CHANGE, hostnameChangeHandler, false, 0, true );
			
		}
		
		private function showHandler( event : FlexEvent ): void
		{
			validateProperties();
		}
			
		private function usernameChangeHandler( event : Event ) : void
		{
			if ( selectedHost )
			{
				if ( loginView.username != selectedHost.user || loginView.host.textInput.text != selectedHost.host )
					loginView.password = "";
				else
					loginView.password = selectedHost.password;
			}
		}
		
		private function hostnameChangeHandler( event : Event ) : void
		{
			if ( selectedHost )
			{
				if ( loginView.host.textInput.text != selectedHost.host || loginView.username != selectedHost.user)
				{
					loginView.password = "";
					loginView.saveButton.currentState = "notsave";
				}
				else
				{
					loginView.password = selectedHost.password;
					if ( selectedHost.password == "" )
						loginView.saveButton.currentState = "notsave";
					else
						loginView.saveButton.currentState = "save";
				}
			}
		}
		
		private function setLoginInformation( event : Event ) : void
		{
			if ( loginView.host.selectedItem is HostVO )
			{
				selectedHost = loginView.host.selectedItem as HostVO ; 
			
				loginView.username = selectedHost.user;
				
				loginView.password = selectedHost.password;
				
				loginView.password = selectedHost.password;
				
				localeProxy.changeLocale( selectedHost.local );
				
				loginView.selectedLanguage = localeProxy.currentLocale;
				
				selectedHostIndex = loginView.host.selectedIndex;
				
				if ( selectedHost.password == "" )
					loginView.saveButton.currentState = "notsave";
				else
					loginView.saveButton.currentState = "save";
			}
		}
		
		private function delSelectedHost( event : Event ) : void
		{
			selectedHost = null;
			selectedHostIndex = -1;
		}

		private function addedToStageHandler( event : Event ) : void
		{
			validateProperties();
		}
		private function validateProperties( ) : void
		{
			var hostVO :  HostVO;
			
			loginView.host.dataProvider = sharedObjectProxy.hosts;
			selectedHost = null;
			selectedHostIndex = -1;
			
			if ( sharedObjectProxy.lastHost && sharedObjectProxy.lastHost.host != ""  )
			{
				var flag : Boolean = false;
				
				for each ( var h : HostVO in loginView.host.dataProvider )
				{
					if ( h.host ==  sharedObjectProxy.lastHost.host )
					{
						flag = true;
						loginView.host.selectedItem = h;
						selectedHost = h;
						break;
					}
				}
				
				if ( !flag )
				{
					selectedHost = sharedObjectProxy.lastHost;
					loginView.host.dataProvider.addItem( selectedHost );
					loginView.host.selectedItem = selectedHost;
				}
			}
			else if ( sharedObjectProxy.selectedHost != -1 )
			{
				loginView.host.selectedIndex = sharedObjectProxy.selectedHost;
				selectedHost = loginView.host.selectedItem as HostVO;
				selectedHostIndex = sharedObjectProxy.selectedHost;
			}
			
			if ( selectedHost )
			{
				loginView.username = selectedHost.user;

				loginView.hostname = selectedHost.host;

				loginView.password = selectedHost.password;
				
				if ( selectedHost.password == "" )
					loginView.saveButton.currentState = "notsave";
				else
					loginView.saveButton.currentState = "save";
				
				localeProxy.changeLocale( selectedHost.local );
			}
			else
			{
				loginView.username = "";
				
				loginView.hostname = "";
				
				loginView.password = "";
				
				loginView.saveButton.currentState = "notsave";
			}
			
			loginView.host.addEventListener( Event.CHANGE, setLoginInformation);

			loginView.languages = new ArrayList( localeProxy.locales );
			
			loginView.selectedLanguage = localeProxy.currentLocale;
		}

		private function languageChangedHandler( event : Event ) : void
		{
			if( loginView.selectedLanguage is LocaleVO )
			{
				sendNotification( ApplicationFacade.CHANGE_LOCALE, loginView.selectedLanguage );
			}
		}
		
		public function get selectedLanguage() : LocaleVO
		{
			return loginView.selectedLanguage;
		}	

		private function submitHandler( event : Event ) : void
		{
			submit();
		}

		private function submit() : void
		{
			if ( selectedHost && (loginView.host.textInput.text != selectedHost.host || loginView.username != selectedHost.user 
			|| loginView.password != selectedHost.password )  )
			{
				selectedHost = null;
				selectedHostIndex = -1;
			}
			sendNotification( ApplicationFacade.REQUEST_FOR_SIGNUP );
		}
		
		private function deleteHostHandler( event : LoginViewEvent ): void
		{
			sharedObjectProxy.removeHost( loginView.host.textInput.text );
			validateProperties();
		}
	}
}