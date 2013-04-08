package net.vdombox.ide.common.model._vo
{
	import net.vdombox.ide.common.view.components.VDOMImage;

	/**
	 * The LibraryVO is Visual Object of VDOM Library.
	 * LibraryVO is contained in VDOM Application.
	 */
	public class LibraryVO
	{
		public function LibraryVO( name : String, applicationVO : ApplicationVO )
		{
			_name = name;
			_applicationVO = applicationVO;
		}

		public var script : String;

		[Bindable]
		public var saved : Boolean = true;

		private var _name : String;

		private var _applicationVO : ApplicationVO;

		public var containerName : String;

		public function get name() : String
		{
			return _name;
		}

		public function get applicationVO() : ApplicationVO
		{
			return _applicationVO;
		}

		public function get icon() : Class
		{
			return VDOMImage.LibrariesIcon;
		}
	}
}
