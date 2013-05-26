package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.ide.core.model.vo.HostVO;
	import net.vdombox.ide.core.model.vo.LocaleVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	import net.vdombox.ide.common.model.LogProxy;

	/**
	 * ResourcesProxy is wrapper on SharedObject.
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

		private function get strI() : String
		{
			return i.toString();
		}

		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "userData" );
		}

		public function get selectedHost() : String
		{
			return shObjData.data.selectHost ? shObjData.data.selectHost as String : "";
		}

		public function set selectedHost( value : String ) : void
		{
			shObjData.data.selectHost = value;
		}

		private function buildHost() : HostVO
		{
			var host : String = shObjData.data[ "host" + strI ] as String;
			var user : String = shObjData.data[ "user" + strI ] as String;
			var password : String = shObjData.data[ "password" + strI ] as String;
			var local : LocaleVO = new LocaleVO( shObjData.data[ "localcode" + strI ] as String, shObjData.data[ "localdescription" + strI ] as String );

			return new HostVO( host, user, password, local );
		}

		public function get hosts() : ArrayCollection
		{
			var hostList : Array = new Array();
			i = 0;
			while ( shObjData.data[ "host" + i.toString() ] )
			{
				hostVO = buildHost();
				hostList.push( hostVO );

				i++;
			}

			hostList.sortOn( "host" );

			return new ArrayCollection( hostList );
		}

		public function equalHost( hostValue : HostVO ) : HostVO
		{
			i = 0;
			while ( shObjData.data[ "host" + i.toString() ] )
			{
				if ( hostValue.host == shObjData.data[ "host" + strI ] as String && hostValue.user == shObjData.data[ "user" + strI ] as String && hostValue.password == shObjData.data[ "password" + strI ] as String && hostValue.local.code == shObjData.data[ "localcode" + strI ] as String )
				{
					hostVO = buildHost();
					return hostVO;
				}
				i++;
			}
			return null;
		}

		public function getHost( index : Number ) : HostVO
		{
			i = index;
			hostVO = buildHost();
			return hostVO;
		}

		public function setLocal( hostVO : HostVO, localVO : LocaleVO ) : void
		{
			i = 0;
			while ( shObjData.data[ "host" + strI ] )
			{
				if ( shObjData.data[ "host" + strI ] == hostVO.host )
				{
					shObjData.data[ "localcode" + strI ] = localVO.code
					shObjData.data[ "localdescription" + strI ] = localVO.description;
					return;
				}
				i++;
			}


		}

		public function setHost( value : HostVO ) : void
		{
			i = 0;
			while ( shObjData.data[ "host" + strI ] )
			{
				if ( shObjData.data[ "host" + strI ] == value.host )
				{
					setValue();
					return;
				}
				i++;
			}

			setValue();

			function setValue() : void
			{
				shObjData.data[ "host" + strI ] = value.host;
				shObjData.data[ "user" + strI ] = value.user;
				shObjData.data[ "password" + strI ] = value.password;
				if ( value.local )
				{
					shObjData.data[ "localcode" + strI ] = value.local.code;
					shObjData.data[ "localdescription" + strI ] = value.local.description;
				}
				shObjData.data.selectHost = value.host;
			}
		}

		public function removeHost( name : String ) : void
		{
			i = 0;
			var decNeed : Boolean = false;

			while ( shObjData.data[ "host" + i.toString() ] )
			{
				if ( decNeed )
				{
					shObjData.data[ "host" + ( i - 1 ).toString() ] = shObjData.data[ "host" + strI ];
					shObjData.data[ "user" + ( i - 1 ).toString() ] = shObjData.data[ "user" + strI ];
					shObjData.data[ "password" + ( i - 1 ).toString() ] = shObjData.data[ "password" + strI ];
					shObjData.data[ "localcode" + ( i - 1 ).toString() ] = shObjData.data[ "localcode" + strI ];
					shObjData.data[ "localdescription" + ( i - 1 ).toString() ] = shObjData.data[ "localdescription" + strI ];
				}

				else if ( shObjData.data[ "host" + strI ] == name )
				{
					removeValue();

					if ( shObjData.data.selectHost == name )
						shObjData.data.selectHost = "";
					decNeed = true;
				}
				i++;
			}

			if ( decNeed )
			{
				i--;
				removeValue();
			}

			function removeValue() : void
			{
				delete shObjData.data[ "host" + strI ];
				delete shObjData.data[ "user" + strI ];
				delete shObjData.data[ "password" + strI ];
				delete shObjData.data[ "localcode" + strI ];
				delete shObjData.data[ "localdescription" + strI ];
			}
		}

		public function set lastHost( value : HostVO ) : void
		{
			if ( !value )
			{
				delete shObjData.data[ "lasthost" ];
				return;
			}

			shObjData.data[ "lasthost" ] = value.host;
			shObjData.data[ "lastuser" ] = value.user;
			shObjData.data[ "lastpassword" ] = value.password;
			shObjData.data[ "lastlocalcode" ] = value.local.code;
			shObjData.data[ "lastlocaldescription" ] = value.local.description;
		}

		public function get lastHost() : HostVO
		{
			if ( shObjData.data[ "lasthost" ] )
			{
				var host : String = shObjData.data[ "lasthost" ] as String;
				var user : String = shObjData.data[ "lastuser" ] as String;
				var password : String = shObjData.data[ "lastpassword" ] as String;
				var local : LocaleVO = new LocaleVO( shObjData.data[ "lastlocalcode" ] as String, shObjData.data[ "lastlocaldescription" ] as String );

				return new HostVO( host, user, password, local );
			}
			else
			{
				return null;
			}

		}

		public function clearLastHost() : void
		{
			shObjData.data[ "lasthost" ] = null;
		}

	}
}
