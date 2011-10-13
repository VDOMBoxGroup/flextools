package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.ide.core.model.vo.HostVO;
	import net.vdombox.ide.core.model.vo.LocaleVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 *  ResourcesProxy is wrapper on SharedObject. 
	 * Used for save <i>hostame, login and password</i>
	 * @see  flash.net.SharedObject
	 * @author Alexey Andreev
	 * 
	 */
	public class SharedObjectProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SharedObjectProxy";

		public function SharedObjectProxy()
		{
			super( NAME, {} );
		}

		private var shObjData : Object;
		private var selObjData : Object;
		private var i : int;
		private var hostVO : HostVO;

		override public function onRegister() : void
		{
			selObjData = SharedObject.getLocal( "userData" );
		}
		
		public function get selectedHost() : int
		{
			return selObjData.data.selectHost ? int (selObjData.data.selectHost as String) : -1;
		}
		
		public function set selectedHost( value : int ) : void
		{
			selObjData.data.selectHost = value.toString();
		}

		public function get hosts() : ArrayCollection
		{
			var hostList : ArrayCollection = new ArrayCollection();
			i = 0;
			shObjData = SharedObject.getLocal( i.toString() );
			for ( i = 0; shObjData.data.host; )
			{
				var host : String = shObjData.data.host as String;
				var user : String = shObjData.data.user as String;
				var password : String = shObjData.data.password as String;
				var local : LocaleVO = new LocaleVO( shObjData.data.local as String, "" );
				
				hostVO = new HostVO( host, user, password, local);
				hostList.addItem( hostVO );
				
				shObjData = SharedObject.getLocal( (++i).toString() );
	
			}
			return hostList;
		}
		
		public function equalHost( hostValue : HostVO ) : HostVO
		{
			i = 0;
			shObjData = SharedObject.getLocal( i.toString() );
			for ( i = 0; shObjData.data.host;)
			{
				if ( hostValue.host ==  shObjData.data.host as String &&
					hostValue.user ==  shObjData.data.user as String &&
					hostValue.password ==  shObjData.data.password as String &&
					hostValue.local.code ==  shObjData.data.local as String)
				{
					var host : String = shObjData.data.host as String;
					var user : String = shObjData.data.user as String;
					var password : String = shObjData.data.password as String;
					var local : LocaleVO = new LocaleVO( shObjData.data.host as String, "" );
					
					hostVO = new HostVO( host, user, password, local);
					return hostVO;
				}		
				shObjData = SharedObject.getLocal( (++i).toString() );
			}
			return null;
		}
		
		public function getHost( index : Number ) : HostVO
		{
			shObjData = SharedObject.getLocal( index.toString() );
			var host : String = shObjData.data.host as String;
			var user : String = shObjData.data.user as String;
			var password : String = shObjData.data.password as String;
			var local : LocaleVO = new LocaleVO( shObjData.data.host as String, "" );
					
			hostVO = new HostVO( host, user, password, local);
			return hostVO;
		}

		public function setHost( value : HostVO ) : void
		{
			i = 0;
			shObjData = SharedObject.getLocal( i.toString() );
			for ( i = 0; shObjData.data.host; )
			{
				if ( shObjData.data.host == value.host )
				{
					shObjData.data.user = value.user;
					shObjData.data.password = value.password;
					selObjData.data.selectHost = i.toString();
					return;
				}
				shObjData = SharedObject.getLocal( (++i).toString() );
			}
			
			shObjData.data.host = value.host;
			shObjData.data.user = value.user;
			shObjData.data.password = value.password;
			shObjData.data.local = value.local.code;
			selObjData.data.selectHost = i.toString();
		}

	/*	public function get password() : String
		{
			return shObjData.data.password ? shObjData.data.password : "";;
		}

		public function set password( value : String ) : void
		{
			shObjData.data.password = value;
		}

		public function get hostname() : String
		{
			return shObjData.data.hostname ? shObjData.data.hostname : "";
		}

		public function set hostname( value : String ) : void
		{
			shObjData.data.hostname = value;
		}

		public function get localeCode() : String
		{
			return shObjData.data.localeCode ? shObjData.data.localeCode : "";
		}

		public function set localeCode( value : String ) : void
		{
			shObjData.data.localeCode = value;
		}*/
	}
}