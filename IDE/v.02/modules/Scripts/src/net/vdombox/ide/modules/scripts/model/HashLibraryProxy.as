package net.vdombox.ide.modules.scripts.model
{
	import net.vdombox.editors.HashLibrary;
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class HashLibraryProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "HashLibraryProxy";
		
		private var _hashLibraryArray : HashLibraryArray;
		
		public function HashLibraryProxy()
		{
		}

		public function get hashLibrary():HashLibrary
		{
			return _hashLibraryArray;
		}
		
		public function setLibrary( libraries : Array ) : void
		{
			var library : LibraryVO;
			
			for each ( library in libraries )
			{
				var hashLibrary : HashLibrary = new HashLibrary( library.name );
				
			}
		}

	}
}