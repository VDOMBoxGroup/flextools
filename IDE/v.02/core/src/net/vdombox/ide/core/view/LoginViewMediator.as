package net.vdombox.ide.core.view
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.LocalesProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.model.vo.LocaleVO;
	import net.vdombox.ide.core.view.components.LoginView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class LoginViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginView";
		
		public function LoginViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var localeProxy : LocalesProxy;
		
		private var sharedObjectProxy : SharedObjectProxy;
		
		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;
			
			addEventListeners();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.MODULES_LOADED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				
			}
		}
		
		private function get loginView() : LoginView
		{
			return viewComponent as LoginView;
		}
		
		private function addEventListeners() : void
		{
			loginView.addEventListener( FlexEvent.SHOW, showHandler );
			
			loginView.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			loginView.selectLang.addEventListener( ListEvent.CHANGE, selectLang_changeHandler );
			loginView.submitButton.addEventListener( MouseEvent.CLICK, submitButton_clickHandler );
		}
		
		private function setupLanguageList() : void
		{
			var languageList : Array = localeProxy.locales;
			loginView.selectLang.labelField = "description"
			loginView.selectLang.dataProvider = languageList;
			loginView.selectLang.selectedItem = localeProxy.currentLocale;
		}
		
		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == 13 )
				submit();
		}
		
		private function showHandler( event : FlexEvent ) : void
		{
			loginView.username.text = sharedObjectProxy.username;
			loginView.username.appendText( "" ); //FIXME убрать эту конструкцию непонятную, иначе не рефрешит поле.
			loginView.hostname.text = sharedObjectProxy.hostname;
			loginView.hostname.appendText( "" );
			
			setupLanguageList();
		}
		
		/*private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( event.target is Button || event.target is RichEditableText || event.target.parent is ComboBox )
				return;
			
			loginView.nativeWindow.startMove();
			
			event.stopImmediatePropagation();
		}*/
		
		private function selectLang_changeHandler( event : ListEvent ) : void
		{
			var selectedItem : LocaleVO = event.currentTarget.selectedItem as LocaleVO;
			sendNotification( ApplicationFacade.CHANGE_LOCALE, selectedItem );
		}
		
		
		
		private function submit() : void
		{
			var loginFormData : Object = {};
			loginFormData.username = loginView.username.text;
			loginFormData.password = loginView.password.text;
			loginFormData.hostname = loginView.hostname.text;
			
			sharedObjectProxy.username = loginView.username.text;
			sharedObjectProxy.hostname = loginView.hostname.text;
			
			sendNotification( ApplicationFacade.PROCESS_USER_INPUT, loginFormData );
		}
		
		private function submitButton_clickHandler( event : MouseEvent ) : void
		{
			submit();
		}
	}
}