package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.model.vo.HostVO;
	import net.vdombox.ide.core.view.InitialWindowMediator;
	import net.vdombox.ide.core.view.LoginViewMediator;
	import net.vdombox.utils.MD5Utils;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RequestForSignupCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var loginViewMediator : LoginViewMediator = facade.retrieveMediator( LoginViewMediator.NAME ) as LoginViewMediator;
			var sharedObjectProxy : SharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			var hostVO : HostVO;
			if ( loginViewMediator.selectedHost )
			{
				if ( loginViewMediator.selectedHost.local.code != loginViewMediator.selectedLanguage.code )
				{
					sharedObjectProxy.setLocal( loginViewMediator.selectedHostIndex, loginViewMediator.selectedLanguage );
					loginViewMediator.selectedHost = new HostVO( loginViewMediator.selectedHost.host, loginViewMediator.selectedHost.user, loginViewMediator.selectedHost.password, loginViewMediator.selectedLanguage );
				}
				hostVO = sharedObjectProxy.equalHost( loginViewMediator.selectedHost );
			}
			else
			{
				hostVO = new HostVO( loginViewMediator.hostname, loginViewMediator.username, MD5Utils.encrypt( loginViewMediator.password ), loginViewMediator.selectedLanguage );
				hostVO = sharedObjectProxy.equalHost( hostVO );
			}
				
				
			if ( hostVO )
			{
				sharedObjectProxy.selectedHost = loginViewMediator.selectedHostIndex;
			}
			else
			{
				hostVO = new HostVO( loginViewMediator.hostname, loginViewMediator.username, MD5Utils.encrypt( loginViewMediator.password ), loginViewMediator.selectedLanguage );
				sharedObjectProxy.setHost( hostVO );
			}
				
			
			serverProxy.connect();
		}
	}
}