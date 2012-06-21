package net.vdombox.object_editor.model.proxy
{
	import flash.net.SharedObject;
	
	import net.vdombox.object_editor.model.vo.ConnectInfoVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ConnectToServerProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ConnectToServerProxy";
		
		public function ConnectToServerProxy()
		{
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "connectData" );
		}
		
		public function get connectInformation() : ConnectInfoVO
		{
			return new ConnectInfoVO( shObjData.data["host"] as String, shObjData.data["user"] as String, shObjData.data["password"] as String );
		}
		
		public function set connectInformation( connectInfoVO : ConnectInfoVO ) : void
		{
			shObjData.data["host"] = connectInfoVO.serverAddress;
			shObjData.data["user"] = connectInfoVO.userName;
			shObjData.data["password"] = connectInfoVO.password;
		}
	}
}