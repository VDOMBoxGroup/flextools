package net.vdombox.editors
{
	import net.vdombox.ide.common.model._vo.LibraryVO;

	public class HashLibrary
	{
		private var _libraryVO : LibraryVO;

		public var members : Object;


		public function HashLibrary( libVO : LibraryVO )
		{
			_libraryVO = libVO;
		}

		public function get libraryVO() : LibraryVO
		{
			return _libraryVO;
		}

		public function get name() : String
		{
			return _libraryVO.name;
		}

	}
}
