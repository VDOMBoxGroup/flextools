package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.model.vo.HostVO;
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
			var tempVO : HostVO = loginViewMediator.selectedHost;
			var password : String;
			
			var hostname : String = loginViewMediator.hostname;
			if ( hostname.substr( 0, 7) == "http://" )
				hostname = hostname.substring( 7, hostname.length );
			
			
			
			if ( tempVO )
			{
				if ( loginViewMediator.selectedLanguage && loginViewMediator.selectedHost.local.code != loginViewMediator.selectedLanguage.code )
				{
					sharedObjectProxy.setLocal( loginViewMediator.selectedHost, loginViewMediator.selectedLanguage );
				}
				
				if ( tempVO.password != loginViewMediator.password )
					password = MD5Utils.encrypt( loginViewMediator.password );
				else
					password = tempVO.password;
			}
			else
			{
				password = MD5Utils.encrypt( loginViewMediator.password );
			}
			
			hostVO = new HostVO( hostname, loginViewMediator.username,password , loginViewMediator.selectedLanguage );
			hostVO = sharedObjectProxy.equalHost( hostVO );
			
				
			if ( hostVO )
			{
				sharedObjectProxy.selectedHost = tempVO.host;
			}
			else
			{
				hostVO = new HostVO( hostname, loginViewMediator.username, password, loginViewMediator.selectedLanguage );

			}
			
			if ( loginViewMediator.needSave )
				hostVO.save = true;
			
			serverProxy.connect( hostVO );
		}
	}
}