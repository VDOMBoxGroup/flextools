package net.vdombox.ide.modules.scripts.model
{
	import net.vdombox.editors.HashLibrary;
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class HashLibraryProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "HashLibraryProxy";
		
		public static const HASH_LIBRARIES_CHANGE : String = "hashLibrariesChange";
		
		private var _hashLibraryArray : HashLibraryArray;
		
		public function HashLibraryProxy()
		{
			super( NAME );
		}

		public function get hashLibraries():HashLibraryArray
		{
			return _hashLibraryArray;
		}
		
		public function setLibraries( libraries : Array ) : void
		{
			_hashLibraryArray = new HashLibraryArray();
			var library : LibraryVO;
			
			for each ( library in libraries )
				_hashLibraryArray.Add( new HashLibrary( library ) );
				
			sendNotification( HASH_LIBRARIES_CHANGE );
		}
		
		public function getLibrariesName() : Vector.<String>
		{
			return _hashLibraryArray.getLibrariesName()();
		}

	}
}