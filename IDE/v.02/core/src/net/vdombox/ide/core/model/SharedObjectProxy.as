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
		private var i : int;
		private var hostVO : HostVO;

		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "userData" );
		}
		
		public function get selectedHost() : int
		{
			return shObjData.data.selectHost ? int (shObjData.data.selectHost as String) : -1;
		}
		
		public function set selectedHost( value : int ) : void
		{
			shObjData.data.selectHost = value.toString();
		}

		public function get hosts() : ArrayCollection
		{
			var hostList : ArrayCollection = new ArrayCollection();
			i = 0;
			while ( shObjData.data["host" + i.toString()] )
			{
				var host : String = shObjData.data["host" + i.toString()] as String;
				var user : String = shObjData.data["user" + i.toString()] as String;
				var password : String = shObjData.data["password" + i.toString()] as String;
				var local : LocaleVO = new LocaleVO( shObjData.data["localcode" + i.toString()] as String, shObjData.data["localdescription" + i.toString()] as String );
				
				hostVO = new HostVO( host, user, password, local);
				hostList.addItem( hostVO );
				
				i++;
	
			}
			return hostList;
		}
		
		public function equalHost( hostValue : HostVO ) : HostVO
		{
			i = 0;
			while ( shObjData.data["host" + i.toString()] )
			{
				if ( hostValue.host ==  shObjData.data["host" + i.toString()] as String &&
					hostValue.user ==  shObjData.data["user" + i.toString()] as String &&
					hostValue.password ==  shObjData.data["password" + i.toString()] as String &&
					hostValue.local.code ==  shObjData.data["localcode" + i.toString()] as String)
				{
					var host : String = shObjData.data["host" + i.toString()] as String;
					var user : String = shObjData.data["user" + i.toString()] as String;
					var password : String = shObjData.data["password" + i.toString()] as String;
					var local : LocaleVO = new LocaleVO( shObjData.data["localcode" + i.toString()] as String, shObjData.data["localdescription" + i.toString()] as String );
					
					hostVO = new HostVO( host, user, password, local);
					return hostVO;
				}		
				i++;
			}
			return null;
		}
		
		public function getHost( index : Number ) : HostVO
		{
			var host : String = shObjData.data["host" + index.toString()] as String;
			var user : String = shObjData.data["user" + index.toString()] as String;
			var password : String = shObjData.data["password" + index.toString()] as String;
			var local : LocaleVO = new LocaleVO( shObjData.data["localcode" + i.toString()] as String, shObjData.data["localdescription" + i.toString()] as String );
					
			hostVO = new HostVO( host, user, password, local);
			return hostVO;
		}
		
		public function setLocal( index : Number, localVO : LocaleVO ) : void
		{
			shObjData.data["localcode" + index.toString()] = localVO.code
			shObjData.data["localdescription" + index.toString()] = localVO.description;
		}

		public function setHost( value : HostVO ) : void
		{
			i = 0;
			while ( shObjData.data["host" + i.toString()] )
			{
				if ( shObjData.data["host" + i.toString()] == value.host )
				{
					shObjData.data["user" + i.toString()] = value.user;
					shObjData.data["password" + i.toString()] = value.password;
					shObjData.data["localcode" + i.toString()] = value.local.code;
					shObjData.data["localdescription" + i.toString()] = value.local.description;
					shObjData.data.selectHost = i.toString();
					return;
				}
				i++;
			}
			
			shObjData.data["host" + i.toString()] = value.host;
			shObjData.data["user" + i.toString()] = value.user;
			shObjData.data["password" + i.toString()] = value.password;
			shObjData.data["localcode" + i.toString()] = value.local.code;
			shObjData.data["localdescription" + i.toString()] = value.local.description;
			shObjData.data.selectHost = i.toString();
		}
		
		public function removeHost( name : String ) : void
		{
			i = 0;
			var decNeed : Boolean = false;
			
			while ( shObjData.data["host" + i.toString()] )
			{
				if ( decNeed )
				{
					shObjData.data["host" + (i - 1).toString()] = shObjData.data["host" + i.toString()];
					shObjData.data["user" + (i - 1).toString()] = shObjData.data["user" + i.toString()];
					shObjData.data["password" + (i - 1).toString()] = shObjData.data["password" + i.toString()] ;
					shObjData.data["localcode" + (i - 1).toString()] = shObjData.data["localcode" + i.toString()] ;
					shObjData.data["localdescription" + (i - 1).toString()] = shObjData.data["localdescription" + i.toString()] ;
				}
				
				else if ( shObjData.data["host" + i.toString()] == name )
				{
					delete shObjData.data["host" + i.toString()];
					delete shObjData.data["user" + i.toString()];
					delete shObjData.data["password" + i.toString()];
					delete shObjData.data["localcode" + i.toString()];
					delete shObjData.data["localdescription" + i.toString()];
					if ( shObjData.data.selectHost == i.toString() )
						shObjData.data.selectHost = -1;
					decNeed = true;
				}
				i++;
			}
			
			if ( decNeed )
			{
				i--;
				delete shObjData.data["host" + i.toString()];
				delete shObjData.data["user" + i.toString()];
				delete shObjData.data["password" + i.toString()];
				delete shObjData.data["localcode" + i.toString()];
				delete shObjData.data["localdescription" + i.toString()];
			}
		}

	}
}