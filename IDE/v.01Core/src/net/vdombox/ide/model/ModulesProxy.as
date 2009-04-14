package net.vdombox.ide.model
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ModulesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ModulesProxy";

		private static const MODULES_DIR : String = "app:/modules/";

		private static const MODULES_XML : XML =
			<modules>
				<category name="editing">
					<module path=""/>
					<module path=""/>
				</category>
				<category name="language">
					<module path=""/>
					<module path=""/>
				</category>
				<category name="some">
				</category>
			</modules>

		public function ModulesProxy( data : Object = null )
		{
			super( NAME, data );
			init();
		}
		
		private var _categories : XMLList;
		
		public function get categories() : XMLList
		{
			return _categories;
		}
		
		public function getModulesList( categoryName : String ) : XMLList
		{
			return new XMLList( MODULES_XML.category.(@name == categoryName).module );
		}
		
		private function init() : void
		{	
			_categories = new XMLList();
			
			for each( var category : XML in MODULES_XML.* )
			{
				_categories += <category name={category.@name} />
			}
		}
	}
}