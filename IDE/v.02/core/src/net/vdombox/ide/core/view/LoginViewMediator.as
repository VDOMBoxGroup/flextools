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
		
		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;

			addHandlers();
		}

//		override public function listNotificationInterests() : Array
//		{
//			var interests : Array = super.listNotificationInterests();
//			
//			return interests;
//		}
//
//		override public function handleNotification( notification : INotification ) : void
//		{
//		}
		
		private function get loginView() : LoginView
		{
			return viewComponent as LoginView;
		}

		private function addHandlers() : void
		{
			loginView.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);

			loginView.addEventListener( LoginViewEvent.SUBMIT, submitHandler, false, 0, true );
			
			loginView.addEventListener( LoginViewEvent.SUBMIT, submitHandler, false, 0, true );

			loginView.addEventListener( LoginViewEvent.LANGUAGE_CHANGED, languageChangedHandler, false, 0, true );
			
			loginView.user.addEventListener( Event.CHANGE, usernameChangeHandler );
		}

		private function removeHandlers() : void
		{
			loginView.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );

			loginView.removeEventListener( LoginViewEvent.SUBMIT, submitHandler );

			loginView.removeEventListener( LoginViewEvent.LANGUAGE_CHANGED, languageChangedHandler );
			
			loginView.host.removeEventListener( Event.CHANGE, setLoginInformation);
			
			loginView.user.removeEventListener( Event.CHANGE, usernameChangeHandler );
		}
		
		private function usernameChangeHandler( event : Event ) : void
		{
			if ( loginView.username != selectedHost.user )
				loginView.password = "";
			else
				loginView.password = selectedHost.password;
		}
		
		private function setLoginInformation( event : Event ) : void
		{
			if ( loginView.host.selectedItem is HostVO )
			{
				selectedHost = loginView.host.selectedItem as HostVO ; 
			
				loginView.username = selectedHost.user;
				
				loginView.password = selectedHost.password;
				
				selectedHostIndex = loginView.host.selectedIndex;
			}
		}
		
		private function delSelectedHost( event : Event ) : void
		{
			selectedHost = null;
			selectedHostIndex = -1;
		}

		private function addedToStageHandler( event : Event ) : void
		{
			
			var hostVO :  HostVO;
			
			loginView.host.dataProvider = sharedObjectProxy.hosts;
			selectedHost = null;
			selectedHostIndex = -1;
			
			if ( sharedObjectProxy.selectedHost != -1 )
			{
				loginView.host.selectedIndex = sharedObjectProxy.selectedHost;
				selectedHost = loginView.host.selectedItem as HostVO;
				selectedHostIndex = sharedObjectProxy.selectedHost;
			}
			
			loginView.host.addEventListener( Event.CHANGE, setLoginInformation);
			
			if ( selectedHost )
			{
				loginView.username = selectedHost.user;

				loginView.hostname = selectedHost.host;

				loginView.password = selectedHost.password;
			}
			else
			{
				loginView.username = "";
				
				loginView.hostname = "";
				
				loginView.password = "";
			}

			loginView.languages = new ArrayList( localeProxy.locales );
			
			loginView.selectedLanguage = localeProxy.currentLocale;
		}

		private function languageChangedHandler( event : Event ) : void
		{
			if( loginView.selectedLanguage is LocaleVO )
				sendNotification( ApplicationFacade.CHANGE_LOCALE, loginView.selectedLanguage );
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
			|| loginView.password != selectedHost.password ) )
			{
				selectedHost = null;
				selectedHostIndex = -1;
			}
			sendNotification( ApplicationFacade.REQUEST_FOR_SIGNUP );
		}
	}
}